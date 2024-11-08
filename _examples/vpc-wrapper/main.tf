############################################
# Create IPAM which VPC Wrapper will use
############################################

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

###################################################
# Create Transit Gateway which VPC Wrapper will use
###################################################

module "transit_gateway" {
  source          = "../../_modules/tgw"
  name_prefix     = format("%s-%s", var.name_prefix, var.region)
  amazon_side_asn = 64512

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

############################################
# Create a VPC with the wrapper module
############################################

module "wrapper" {
  source       = "../../vpc_wrapper"
  name_prefix  = var.name_prefix
  network_type = "small"
  environment  = "prod"
  project      = "ipam"

  depends_on = [module.transit_gateway, module.ipam-aws]
}

output "vpc" {
  value = module.wrapper
}