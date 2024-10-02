# Terraform AWS Secops Ec2 Instance Module
This module provisions a battletested EC2 instance

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->


### Example

```hcl
# Get your assigned vpc
data "aws_vpcs" "vpc" {}

data "aws_vpc" "vpc" {
id = tolist(data.aws_vpcs.vpc.ids)[0]
}

data "aws_subnet_ids" "subnet" {
vpc_id = tolist(data.aws_vpcs.vpc.ids)[0]
filter {
name   = "availabilityZone"
values = ["eu-north-1b"]
}
}

# Example how to get Latest Focal Image Ami
data "aws_ami" "focal" {
executable_users = ["self"]
most_recent      = true
name_regex       = "^Kambi Focal \\d{3}"
owners           = ["self"]
}

module "instance" {

source = "git@github.com:kambi-sports-solutions/tf-terraform-aws-instance-module.git?ref=v0.0.1"

name                          = "test-focal-instance"
ami_id                        = data.aws_ami.focal.id
instance_type                 = "t3.small"
vpc_id                        = data.aws_vpc.vpc.id
subnet_id                     = tolist(data.aws_subnet_ids.subnet.ids)[0]
security_group_ids            = "sg-07bf7639d6b69adbf"
}

```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_ami_id"></a> [ami\_id](#input\_ami\_id) | the ami id as a string | `string` | n/a | yes |
| <a name="input_enable_termination_protection"></a> [enable\_termination\_protection](#input\_enable\_termination\_protection) | (optional) describe your variable | `bool` | `false` | no |
| <a name="input_instance_profile"></a> [instance\_profile](#input\_instance\_profile) | the instance profile to attach | `string` | `null` | no |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | the instance type | `string` | n/a | yes |
| <a name="input_key_name"></a> [key\_name](#input\_key\_name) | instance key pair name | `string` | `null` | no |
| <a name="input_name"></a> [name](#input\_name) | name of the ec2 instance | `string` | n/a | yes |
| <a name="input_security_group_ids"></a> [security\_group\_ids](#input\_security\_group\_ids) | attach security group/s | `list(string)` | `[]` | no |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | subnet by id where to launch instance into | `any` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | additional tags other than tag:Name, which is added by default | `any` | `{}` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | vpc id used to attach default security group to | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_arn"></a> [arn](#output\_arn) | n/a |
| <a name="output_id"></a> [id](#output\_id) | n/a |
| <a name="output_private_dns"></a> [private\_dns](#output\_private\_dns) | n/a |
| <a name="output_private_ip"></a> [private\_ip](#output\_private\_ip) | n/a |
| <a name="output_public_dns"></a> [public\_dns](#output\_public\_dns) | n/a |
| <a name="output_public_ip"></a> [public\_ip](#output\_public\_ip) | n/a |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->