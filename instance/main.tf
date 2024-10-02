#################################
# Security Groups
#################################

#tfsec:ignore:aws-vpc-no-public-egress-sgr
module "security_group" {
  source = "../security-group"

  vpc_id = var.vpc_id
  name   = format("%s-sg", var.name_prefix)

  ingress_rules = [
    {
      type        = "icmp_all"
      source_cidr = ["10.0.0.0/8"]
    },
    {
      type        = "https"
      source_cidr = ["10.0.0.0/8"]
    }
  ]

  egress_rules = [
    {
      type        = "all"
      source_cidr = ["0.0.0.0/0"]
    }
  ]
}

#################################
# Get Amazon Linux AMIs
#################################
data "aws_ami" "default" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["al2023-ami-2023*"]
  }
}

#################################
# SSM Instance Profile
#################################

module "ssm_profile" {
  source      = "./profile"
  name_prefix = format("%s-ssm-role", var.name_prefix)
}

#################################
# Test Servers
#################################

module "instance" {
  source = "../ec2-instance"

  name                          = var.name_prefix
  ami_id                        = data.aws_ami.default.id
  instance_type                 = var.instance_type
  vpc_id                        = var.vpc_id
  subnet_id                     = var.subnet_id
  security_group_ids            = [module.security_group.id]
  instance_profile              = module.ssm_profile.id
  enable_termination_protection = false
  monitoring                    = var.monitoring
}

#################################
# Stop of Start Instance
#################################

resource "aws_ec2_instance_state" "default" {
  instance_id = module.instance.id
  state       = var.state
}
