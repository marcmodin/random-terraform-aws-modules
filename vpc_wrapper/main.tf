module "vpc" {
  source                      = "../_modules/vpc"
  name_prefix                 = local.vpc.name
  ipv4_ipam_pool_id           = local.pool
  ipv4_netmask_length         = local.vpc.netmask
  max_zones                   = local.vpc.max_zones
  transit_gateway_association = local.vpc.transit_gateway_association
  networks                    = local.vpc.networks
  tags                        = local.vpc.tags
}