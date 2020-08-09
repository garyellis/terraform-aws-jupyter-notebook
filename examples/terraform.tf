terraform {
  backend "s3" {
    bucket = "ews-works"
    key    = "terraform/terraform-aws-jupyter-notebook/examples/terraform.tfstate"
    region = "us-west-2"
  }
}
