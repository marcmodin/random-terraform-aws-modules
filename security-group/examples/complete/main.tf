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

module "loadbalancer-security-group" {
  # bridgecrew:skip=CKV2_AWS_5
  # SKIP CHECK: A check to ensure that orphaned Security groups aren't created.
  # Elastic Network Interfaces (ENIs). This checks that Security Groups are attached to provisioning resources.

  source = "../../"

  vpc_id = data.aws_vpc.vpc.id
  name   = "loadbalancer-example-sg"

  ingress_rules = [
    {
      type        = "https"
      source_cidr = ["0.0.0.0/0"]
    }
  ]

  egress_rules = [
    {
      type        = "all"
      source_cidr = ["0.0.0.0/0"]
    }
  ]
}

module "instance-security-group" {
  # bridgecrew:skip=CKV2_AWS_5
  # SKIP CHECK: A check to ensure that orphaned Security groups aren't created.
  # Elastic Network Interfaces (ENIs). This checks that Security Groups are attached to provisioning resources.

  source = "../../"

  vpc_id = data.aws_vpc.vpc.id
  name   = "instance-example-sg"

  ingress_rules = [
    {
      type                  = "https"
      source_security_group = module.loadbalancer-security-group.id
    }
  ]

  egress_rules = [
    {
      type        = "all"
      source_cidr = [data.aws_vpc.vpc.cidr_block]
    }
  ]
}