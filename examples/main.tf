variable "name" {}
variable "key_name" {}
variable "vpc_id" {}
variable "subnet_id" {}
variable "tags" { type = map(string) }

module "jupyter_notebook_instance" {
  source = "../"

  name                        = var.name
  key_name                    = var.key_name
  iam_role_policy_attachments = []
  subnet_id                   = var.subnet_id
  vpc_id                      = var.vpc_id
  tags                        = var.tags

  http_proxy  = "http://squid-proxy.shared-services.ews.works:3128"
  https_proxy = "http://squid-proxy.shared-services.ews.works:3128"
  no_proxy    = "localhost,127.0.0.1,::1,169.254.169.254,169.254.170.2,ews.works"

}

output "private_ip" {
  value = module.jupyter_notebook_instance.private_ip
}

output "get_notebook_server_url" {
  value = module.jupyter_notebook_instance.get_notebook_server_url
}
