# AWS Ipam would most likely be created in a central account and shared with other accounts.
module "ipam-aws" {
  source = "aws-ia/ipam/aws"

  top_cidr        = ["10.0.0.0/21"]
  top_name        = "Organisation IPAM"
  top_description = "Organisation IPAM"

  pool_configurations = {
    eu-north-1 = {
      description = "Pool for the eu-north-1 region"
      locale      = "eu-north-1"
      auto_import = false
      cidr        = ["10.0.0.0/22"]
      # Sub-pools for the eu-north-1 region
      sub_pools = {
        production = {
          description                       = "Production pool for the eu-north-1 region"
          auto_import                       = true
          netmask_length                    = 24
          allocation_default_netmask_length = 25
          allocation_resource_tags = {
            Environment = "prod"
          }
        }
      }
    }
  }

  tags = {}
}

# Find the pool RAM shared to your account for the current region
# Info on RAM sharing pools: https://docs.aws.amazon.com/vpc/latest/ipam/share-pool-ipam.html
data "aws_vpc_ipam_pool" "default" {
  filter {
    name   = "description"
    values = ["Production pool*"]
  }

  filter {
    name   = "address-family"
    values = ["ipv4"]
  }
}

module "vpc" {
  source              = "../../vpc"
  name_prefix         = var.name_prefix
  ipv4_ipam_pool_id   = data.aws_vpc_ipam_pool.default.id
  ipv4_netmask_length = 26

  max_zones = 2
  networks = [
    # networks are created in the order they are defined, always prefer to create the management network first
    {
      name    = "management"
      netmask = 28
    },
    {
      name    = "middleware"
      netmask = 28
    }
  ]
  tags = {
    # This is the required IPAM production pool allocation tag, without it creation will fail
    Environment = "prod"
  }
}