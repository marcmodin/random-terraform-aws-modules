###########################################################
# Session Manager
###########################################################

locals {
  endpoints = toset(["ec2messages", "ssm", "ssmmessages"])
}

data "aws_region" "default" {}

#tfsec:ignore:aws-vpc-no-public-egress-sgr
module "ssm_security_group" {
  source = "../security-group"

  vpc_id = var.vpc_id
  name   = format("%s-%s-sg", var.name_prefix, "ssm")

  ingress_rules = [
    {
      type        = "https"
      source_cidr = [var.vpc_cidr_block]
    }
  ]

  egress_rules = [
    {
      type        = "all"
      source_cidr = ["0.0.0.0/0"]
    }
  ]

  tags = merge({
    Name = format("%s-%s-sg", var.name_prefix, "ssm")
  }, var.tags)
}

resource "aws_vpc_endpoint" "default" {
  for_each            = local.endpoints
  vpc_id              = var.vpc_id
  subnet_ids          = var.subnet_ids
  security_group_ids  = [module.ssm_security_group.id]
  service_name        = format("com.amazonaws.%s.%s", data.aws_region.default.name, each.value)
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  tags = merge({
    Name = format("%s-%s", var.name_prefix, each.value)
  }, var.tags)
}