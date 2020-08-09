variable "name" {
  description = "the name common to all resources created by this module"
  type        = string
}

variable "ami_id" {
  description = "The ami ID. defaults to us-west-2 Anaconda3 2020.02 20200311 (March 19th, 2020)"
  type        = string
  default     = "ami-01f12e05f1db0669b"
}

variable "subnet_id" {
  description = "the ec2 instance subnet"
  type        = string
}

variable "vpc_id" {
  description = "the ec2 instance vpc id"
  type        = string
}

variable "instance_type" {
  description = "the aws instance type"
  type        = string
  default     = "t3.xlarge"
}

variable "disable_api_termination" {
  description = "protect from accidental ec2 instance termination"
  type        = bool
  default     = false
}

variable "root_block_device" {
  description = "The root ebs device config"
  type = list(map(string))
  default = [
    {
      delete_on_termination = true
      volume_type           = "gp2"
      volume_size           = 100
      encrypted             = true
    }
  ]
}

variable "ebs_block_device" {
  description = "additional ebs block devices"
  type        = list(map(string))
  default     = []
}

variable "key_name" {
  description = "The ec2 instance keypair name"
  type        = string
  default     = ""
}

variable "iam_role_policy_attachments" {
  description = "A list of iam policies attached to the ec2 instance role"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "provide a map of aws tags"
  type        = map(string)
  default     = {}
}

variable "kms_cmk_arns" {
  description = "A list of kms keys the notebook instance can use to perform decrypt operatoons"
  type        = list(string)
  default     = []
}

variable "s3_read_buckets" {
  description = "A list of s3 bucket names the notebook instance has read access to"
  type        = list(string)
  default     = []
}

variable "s3_write_buckets" {
  description = "A list of s3 bucket names the notebook instance has write access to"
  type        = list(string)
  default     = []
}

variable "http_proxy" {
  description = "the http proxy"
  type        = string
  default     = ""
}

variable "https_proxy" {
  description = "the https proxy"
  type        = string
  default     = ""
}

variable "no_proxy" {
  description = "the no proxy list"
  type        = string
  default     = ""
}
