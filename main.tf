data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

locals {
  name                 = format("%s-notebook", var.name)
  current_aws_account  = data.aws_caller_identity.current.account_id
  current_region       = data.aws_region.current.name
  ssm_parameter_path   = format("/terraform-aws-jupyter-notebook/%s", var.name)
  ssm_parameter_name   = format("%s/%s", local.ssm_parameter_path, "login")
  ssm_parameter_arn    = format("arn:aws:ssm:%s:%s:parameter%s", local.current_region, local.current_aws_account, local.ssm_parameter_name)

  kms_cmk_arns         = length(var.kms_cmk_arns) > 0 ? [0] : []
  s3_read_buckets      = length(var.s3_read_buckets) > 0 ? [0] : []
  s3_write_buckets     = length(var.s3_write_buckets) > 0 ? [0] : []
}

data "aws_iam_policy_document" "policy" {
  # write the ssm parameter
  statement {
    sid = "SSMPutParameter"
    effect = "Allow"
    actions = [
      "ssm:*",
    ]
    resources = [
      local.ssm_parameter_arn
    ]
  }

  # decrypt s3 data encrypted with kms
  dynamic "statement" {
    for_each = local.kms_cmk_arns
    content {
      sid     = "S3KMSKeys"
      effect  = "Allow"
      actions = [
        "kms:Decrypt",
        "kms:DescribeKey",
        "kms:GenerateDataKey"
      ]
      resources = var.kms_cmk_arns
    }
  }

  # s3 read access
  dynamic statement {
    for_each = local.s3_read_buckets
    content {
      sid    = "S3ListBucketForRead"
      effect = "Allow"
      actions = [
        "s3:ListBucket"
      ]
      resources = formatlist("arn:aws:s3:::%s", var.s3_read_buckets)
    }
  }

  dynamic "statement" {
    for_each = local.s3_read_buckets
    content {
      sid       = "S3ReadObject"
      effect    = "Allow"
      actions   = [
        "s3:GetObject"
      ]
      resources = formatlist("arn:aws:s3:::%s/*", var.s3_read_buckets)
    }
  }

  # s3 write access
  dynamic statement {
    for_each = local.s3_write_buckets
    content {
      sid    = "S3ListBucketForWrite"
      effect = "Allow"
      actions = [
        "s3:ListBucket"
      ]
      resources = formatlist("arn:aws:s3:::%s", var.s3_write_buckets)
    }
  }

  dynamic "statement" {
    for_each = local.s3_write_buckets
    content {
      sid       = "S3WriteObject"
      effect    = "Allow"
      actions   = [
        "s3:PutObject",
        "s3:DeleteObject"
      ]
      resources = formatlist("arn:aws:s3:::%s/*", var.s3_write_buckets)
    }
  }
}

data "aws_iam_policy_document" "trust_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_policy" "policy" {
  name_prefix = var.name
  policy      = data.aws_iam_policy_document.policy.json
}
####
resource "aws_iam_role_policy_attachment" "policy_attachment" {
  role       = aws_iam_role.instance.name
  policy_arn = aws_iam_policy.policy.arn
}

resource "aws_iam_role_policy_attachment" "additional_policy_attachments" {
  count = length(var.iam_role_policy_attachments)

  role       = aws_iam_role.instance.name
  policy_arn = var.iam_role_policy_attachments[count.index]
}

resource "aws_iam_role" "instance" {
  name_prefix        = var.name
  description        = "jupyter notebook iam role"
  assume_role_policy = data.aws_iam_policy_document.trust_policy.json
  tags               = var.tags
}

resource "aws_iam_instance_profile" "instance" {
  name_prefix = var.name
  role        = aws_iam_role.instance.name
}

module "sg" {
  source  = "garyellis/security-group/aws"
  version = "0.2.2"

  create_security_group         = true
  description                   = format("%s security group", var.name)
  egress_cidr_rules             = []
  egress_security_group_rules   = []
  ingress_cidr_rules            = []
  ingress_security_group_rules  = []
  name                          = var.name
  tags                          = var.tags
  toggle_allow_all_egress       = true
  toggle_allow_all_ingress      = true
  toggle_self_allow_all_egress  = true
  toggle_self_allow_all_ingress = true
  vpc_id                        = var.vpc_id
}

module "userdata" {
  source  = "garyellis/scripts/cloudinit"
  version = "0.2.6"

  base64_encode          = false
  gzip                   = false
  extra_user_data_script = templatefile("${path.module}/userdata.tmpl", {
    pip_additional_packages    = "",
    ssm_region                 = local.current_region,
    ssm_parameter_name         = local.ssm_parameter_name
  })

  install_http_proxy_env = var.http_proxy == "" ? false : true
  http_proxy             = var.http_proxy
  https_proxy            = var.https_proxy
  no_proxy               = var.no_proxy
}

module "instance" {
  source  = "garyellis/ec2-instance/aws"
  version = "1.3.3"

  count_instances             = 1
  name                        = var.name
  ami_id                      = var.ami_id
  iam_instance_profile        = aws_iam_instance_profile.instance.name
  user_data                   = module.userdata.cloudinit_userdata
  instance_type               = var.instance_type
  disable_api_termination     = var.disable_api_termination
  key_name                    = var.key_name
  associate_public_ip_address = false
  security_group_attachments  = list(module.sg.security_group_id)
  subnet_ids                  = list(var.subnet_id)
  tags                        = var.tags

  root_block_device           = var.root_block_device
  ebs_block_device            = var.ebs_block_device

  instance_auto_recovery_enabled = true
}
