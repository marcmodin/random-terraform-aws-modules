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

  # you can filter based on locale also
  # filter {
  #   name   = "locale"
  #   values = [var.region]
  # }

  depends_on = [module.ipam-aws]
}

locals {
  # create a map of locale to pool id
  pools = {
    for value in data.aws_vpc_ipam_pools.default.ipam_pools : value.locale => value.id
  }
}

module "vpc_eu_north_1" {
  source              = "../../vpc"
  name_prefix         = var.name_prefix
  ipv4_ipam_pool_id   = local.pools.eu-north-1
  ipv4_netmask_length = 24
  max_zones           = 2

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


output "vpc_eu_north_1" {
  value = module.vpc_eu_north_1
}

module "vpc_eu_central_1" {
  providers = {
    aws = aws.euc1
  }
  source              = "../../vpc"
  name_prefix         = var.name_prefix
  ipv4_ipam_pool_id   = local.pools.eu-central-1
  ipv4_netmask_length = 24
  max_zones           = 2

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


output "vpc_eu_central_1" {
  value = module.vpc_eu_central_1
}