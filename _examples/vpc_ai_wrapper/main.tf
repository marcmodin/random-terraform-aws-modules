####################################################################
# Transit Gateway
####################################################################

module "transit_gateway" {
  source                          = "../../_modules/tgw"
  name_prefix                     = format("%s-%s", var.name_prefix, var.region)
  amazon_side_asn                 = 64512

  create_route_tables = true
  route_tables = {
    spokes     = {default_table = true} # default_table = true dont work
    inspection = {default_propagation = true} # default_propagation = true dont work
  }

  resource_share_principals = [] # local.resource_share_principals_merged

  tags = {
    Environment = "prod"
  }
}

output "transit_gateway" {
  value = module.transit_gateway
}

####################################################################
# Egress VPC 
####################################################################

module "vpc_egress" {
  source       = "../../_modules/vpc_wrapper"
  name         = format("%s-egress-vpc", var.name_prefix) # name from snap
  cidr_block   = "10.0.0.0/25" # small, medui
  az_count     = 2
  nat_gateway_configuration = "none"
  network_type = "egress"
  transit_gateway_id = module.transit_gateway.id
}

# Override the default route table association set on Transit Gateway
resource "aws_ec2_transit_gateway_route_table_association" "egress" {
  transit_gateway_attachment_id  = module.vpc_egress.transit_gateway_attachment_id
  transit_gateway_route_table_id = module.transit_gateway.route_tables.inspection
}

# Create a static route to the egress attachment on the spoke route table
resource "aws_ec2_transit_gateway_route" "egress" {
  destination_cidr_block         = "0.0.0.0/0"
  transit_gateway_attachment_id  = module.vpc_egress.transit_gateway_attachment_id
  transit_gateway_route_table_id = module.transit_gateway.route_tables.spokes
}


####################################################################
# Spoke VPC 
####################################################################

module "vpc_spoke" {
  source       = "../../_modules/vpc_wrapper"
  name         = format("%s-spoke-vpc",var.name_prefix)
  cidr_block   = "10.0.0.128/25"
  az_count     = 2
  network_type = "spoke"
  transit_gateway_id = module.transit_gateway.id
}
