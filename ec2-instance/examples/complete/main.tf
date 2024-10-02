# Get your assigned vpc
data "aws_vpcs" "vpc" {}

data "aws_vpc" "vpc" {
  id = tolist(data.aws_vpcs.vpc.ids)[0]
}

data "aws_subnet_ids" "subnet" {
  vpc_id = tolist(data.aws_vpcs.vpc.ids)[0]
  filter {
    name   = "availabilityZone"
    values = ["eu-north-1c"]
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

  # use remote source when calling this module
  # source = "git::https://bitbucket.services.kambi.com/scm/sec/terraform-secops-aws-instance-module.git?ref=origin/master"

  source = "../../"

  name                          = "test-focal-instance"
  ami_id                        = data.aws_ami.focal.id
  instance_type                 = "t3.small"
  vpc_id                        = data.aws_vpc.vpc.id
  subnet_id                     = tolist(data.aws_subnet_ids.subnet.ids)[0]
  security_group_ids            = [module.security-group.id]
  instance_profile              = ""
  enable_termination_protection = false

  # use key DNS and full fqdn for ansible to pick up instance
  tags = { DNS = "" }
}

module "security-group" {
  # bridgecrew:skip=CKV2_AWS_5
  # SKIP CHECK: A check to ensure that orphaned Security groups aren't created. 
  # Elastic Network Interfaces (ENIs). This checks that Security Groups are attached to provisioning resources.

  source = "git::https://bitbucket.services.kambi.com/scm/sec/terraform-secops-aws-security-group-module.git?ref=origin/master"

  vpc_id = data.aws_vpc.vpc.id
  name   = "module-example-sg"

  ingress_rules = [
    {
      type        = "https"
      source_cidr = [data.aws_vpc.vpc.cidr_block]
    }
  ]

  egress_rules = [
    {
      type        = "all"
      source_cidr = ["0.0.0.0/0"]
    }
  ]
}
