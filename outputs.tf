output "private_ip" {
  value = join("", module.instance.aws_instance_private_ips)
}

# the notebook server url is an aws cli ssm command to retrieve the notebook server address
output "get_notebook_server_url" {
  value = format("aws --region %s ssm get-parameter --name %s --with-decryption", local.current_region, local.ssm_parameter_name)
}
