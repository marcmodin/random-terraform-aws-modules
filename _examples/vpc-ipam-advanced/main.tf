locals {
  ipam_pools = {
    top_level = ["10.0.0.0/20"]
    levels = {
      eu_north_1 = {
        cidrs = ["10.0.0.0/22", "10.0.4.0/22"]
        production = {
          cidrs = ["10.0.0.0/23", "10.0.2.0/23"]
        }
      }
      eu_central_1 = {
        cidrs = ["10.0.8.0/22", "10.0.12.0/22"]
        production = {
          cidrs = ["10.0.8.0/23", "10.0.10.0/23"]
        }
      }
    }
  }
}

module "ipam-aws" {
  source = "aws-ia/ipam/aws"

  top_cidr = local.ipam_pools.top_level

  top_name        = "Organisation IPAM"
  top_description = "Organisation IPAM"
  top_auto_import = false

  pool_configurations = {
    eu-north-1 = {
      description = "Pool for the eu-north-1 region"
      locale      = "eu-north-1"
      auto_import = false
      cidr        = local.ipam_pools.levels.eu_north_1.cidrs
      # Sub-pools for the eu-north-1 region
      sub_pools = {
        production = {
          description = "Production pool for the eu-north-1 region"
          auto_import = true
          cidr        = local.ipam_pools.levels.eu_north_1.production.cidrs
          tags = {
            Environment = "prod"
          }
        }
      }
    }
    eu-central-1 = {
      description = "Pool for the eu-central-1 region"
      locale      = "eu-central-1"
      auto_import = false
      cidr        = local.ipam_pools.levels.eu_central_1.cidrs
      # Sub-pools for the eu-central-1 region
      sub_pools = {
        production = {
          description = "Production pool for the eu-central-1 region"
          auto_import = true
          cidr        = local.ipam_pools.levels.eu_central_1.production.cidrs
          tags = {
            Environment = "prod"
          }
        }
      }
    }
  }

  tags = {}
}

output "ipam" {
  value = module.ipam-aws
}

# Find the pool RAM shared to your account
# Info on RAM sharing pools: https://docs.aws.amazon.com/vpc/latest/ipam/share-pool-ipam.html
data "aws_vpc_ipam_pools" "default" {

  filter {
    name   = "tag:Environment"
    values = ["prod"]
  }

  filter {
    name   = "address-family"
    values = ["ipv4"]
  }

  filter {
    name   = "locale"
    values = [var.region]
  }

  depends_on = [module.ipam-aws]
}

locals {
  # create a map of locale to pool id
  pools = {
    for value in data.aws_vpc_ipam_pools.default.ipam_pools : value.locale => value.id
  }
}

# Create a custom allocation for the transit gateway cidr block from the pool
resource "aws_vpc_ipam_pool_cidr_allocation" "transit_gateway_allocation" {
  ipam_pool_id = values(local.pools)[0]
  cidr         = "10.0.0.0/24"
  depends_on   = [module.ipam-aws]
}

module "transit_gateway" {
  source          = "../../_modules/tgw"
  name_prefix     = format("%s-%s", var.name_prefix, var.region)
  amazon_side_asn = 64512
  # use the allocated cidr block from the pool
  transit_gateway_cidr_blocks = [aws_vpc_ipam_pool_cidr_allocation.transit_gateway_allocation.cidr]

  # use the the default route table for all attachment associations and propagations
  create_route_tables             = false
  default_route_table_association = "enable"
  default_route_table_propagation = "enable"

  tags = {
    Environment = "prod"
  }
}

output "transit_gateway" {
  value = module.transit_gateway
}

module "vpc" {
  source              = "../../_modules/vpc"
  name_prefix         = var.name_prefix
  ipv4_ipam_pool_id   = values(local.pools)[0]
  ipv4_netmask_length = 24
  max_zones           = 2

  # create transit gateway attachment with defualt route table association and propagation
  transit_gateway_association = {
    id                              = module.transit_gateway.id
    subnet_group                    = "management"
    default_route_table_association = true
    default_route_table_propagation = true
  }

  networks = [
    # networks are created in the order they are defined, always prefer to create the management network first
    {
      name    = "management"
      netmask = 28
    }
  ]
  tags = {

    Environment = "prod"
  }
}


output "vpc" {
  value = module.vpc
}