############################################
# Create Transit Gateway
############################################

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

  depends_on = [module.transit_gateway]
}

output "vpc" {
  value = module.wrapper
}