# terraform-aws-jupyter-notebook
Launch a jupyter notebook server ec2 instance.

## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| aws | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| ami\_id | The ami ID. defaults to us-west-2 Anaconda3 2020.02 20200311 (March 19th, 2020) | `string` | `"ami-01f12e05f1db0669b"` | no |
| disable\_api\_termination | protect from accidental ec2 instance termination | `bool` | `false` | no |
| ebs\_block\_device | additional ebs block devices | `list(map(string))` | `[]` | no |
| http\_proxy | the http proxy | `string` | `""` | no |
| https\_proxy | the https proxy | `string` | `""` | no |
| iam\_role\_policy\_attachments | A list of iam policies attached to the ec2 instance role | `list(string)` | `[]` | no |
| instance\_type | the aws instance type | `string` | `"t3.xlarge"` | no |
| key\_name | The ec2 instance keypair name | `string` | `""` | no |
| kms\_cmk\_arns | A list of kms keys the notebook instance can use to perform decrypt operatoons | `list(string)` | `[]` | no |
| name | the name common to all resources created by this module | `string` | n/a | yes |
| no\_proxy | the no proxy list | `string` | `""` | no |
| root\_block\_device | The root ebs device config | `list(map(string))` | <pre>[<br>  {<br>    "delete_on_termination": true,<br>    "encrypted": true,<br>    "volume_size": 100,<br>    "volume_type": "gp2"<br>  }<br>]</pre> | no |
| s3\_read\_buckets | A list of s3 bucket names the notebook instance has read access to | `list(string)` | <pre>[<br>  "secret-ews-poc",<br>  "ews-works"<br>]</pre> | no |
| s3\_write\_buckets | A list of s3 bucket names the notebook instance has write access to | `list(string)` | <pre>[<br>  "arn:aws:s3:::secret-ews-poc",<br>  "arn:aws:s3:::ews-works"<br>]</pre> | no |
| subnet\_id | the ec2 instance subnet | `string` | n/a | yes |
| tags | provide a map of aws tags | `map(string)` | `{}` | no |
| vpc\_id | the ec2 instance vpc id | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| get\_notebook\_server\_url | the notebook server url is an aws cli ssm command to retrieve the notebook server address |
| private\_ip | n/a |
