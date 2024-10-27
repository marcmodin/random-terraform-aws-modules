module "region" {
  source = "./short-region"
}

data "aws_ec2_transit_gateway" "default" {
  filter {
    name   = "tag:Environment"
    values = ["prod"]
  }
}

# Find the pool RAM shared to your account
# Info on RAM sharing pools: https://docs.aws.amazon.com/vpc/latest/ipam/share-pool-ipam.html
data "aws_vpc_ipam_pool" "default" {
  filter {
    name   = "tag:Environment"
    values = [var.environment]
  }

  filter {
    name   = "address-family"
    values = ["ipv4"]
  }

  filter {
    name   = "locale"
    values = [local.region.region]
  }
}

locals {
  # get the current region
  region = module.region
  # get the pool id for the region
  pool = data.aws_vpc_ipam_pool.default.id

  name_prefix = format("%s-%s-%s-%s", var.project, var.environment, local.region.short_region, var.name_prefix)
  # create transit gateway attachment with defualt route table association and propagation
  transit_gateway_association = {
    id                              = data.aws_ec2_transit_gateway.default.id
    subnet_group                    = "management"
    default_route_table_association = true
    default_route_table_propagation = true
  }

  # create a map of predefined subnets by type
  vpc_by_type = {
    small = {
      name                        = local.name_prefix
      netmask                     = 25
      max_zones                   = 2
      transit_gateway_association = local.transit_gateway_association
      networks = [
        # networks are created in the order they are defined, always prefer to create the management network first
        {
          name    = "management"
          netmask = 28
        }
      ]
      tags = {
        Environment = var.environment
        Class       = var.class
        Project     = var.project
      }
    }
  }

  # determine the type of subnet to create based on the network type
  vpc = try(local.vpc_by_type[var.network_type], {})
}