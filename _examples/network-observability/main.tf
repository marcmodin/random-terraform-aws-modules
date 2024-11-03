###################################################
# Create Transit Gateway which VPC Wrapper will use
###################################################

module "transit_gateway" {
  source          = "../../transit-gateway"
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

###################################################
# Global Network 
###################################################

resource "aws_networkmanager_global_network" "default" {
  description = "Global Network"
}

resource "aws_networkmanager_transit_gateway_registration" "default" {
  global_network_id   = aws_networkmanager_global_network.default.id
  transit_gateway_arn = module.transit_gateway.arn
}

############################################
# Create two spoke VPCs
############################################

module "spoke_one" {
  source          = "../../vpc"
  name_prefix     = format("%s-spoke-one", var.name_prefix)
  ipv4_cidr_block = "10.0.0.0/25"
  max_zones       = 2
  networks = [
    {
      name    = "management"
      netmask = 28
    }
  ]
  transit_gateway_association = {
    id                              = module.transit_gateway.id
    subnet_group                    = "management"
    default_route_table_association = true
    default_route_table_propagation = true
    default_transit_gateway_route   = "10.0.0.0/8"
  }
}

module "spoke_two" {
  source          = "../../vpc"
  name_prefix     = format("%s-spoke-two", var.name_prefix)
  ipv4_cidr_block = "10.0.0.128/25"
  max_zones       = 2
  networks = [
    {
      name    = "management"
      netmask = 28
    }
  ]
  transit_gateway_association = {
    id                              = module.transit_gateway.id
    subnet_group                    = "management"
    default_route_table_association = true
    default_route_table_propagation = true
    default_transit_gateway_route   = "10.0.0.0/8"
  }
}

locals {
  spoke_vpcs = [module.spoke_one, module.spoke_two]
}

################################################
# Create two instances in each spoke VPC
# with session manager private enpoints enabled
################################################

# Create a session manager endpoint
module "session_manager" {
  source         = "../../session-manager"
  for_each       = { for idx, vpc in local.spoke_vpcs : vpc.vpc_name => vpc }
  name_prefix    = each.value.vpc_name
  vpc_id         = each.value.vpc_id
  vpc_cidr_block = each.value.vpc_cidr_block
  subnet_ids     = [element(each.value.subnets_by_group.management, 0).id]
}

# Create an instance
module "instance" {
  source      = "../../instance"
  for_each    = { for idx, vpc in local.spoke_vpcs : vpc.vpc_name => vpc }
  name_prefix = format("%s-instance", var.name_prefix)
  vpc_id      = each.value.vpc_id
  subnet_id   = element(each.value.subnets_by_group.management, 0).id
  # state       = "running"
}


################################################
# Create a flow log for each spoke VPC
################################################

# Centralized flow log destination
# resource "aws_s3_bucket" "default" {
#   bucket        = format("%s-%s-flow-logs", var.name_prefix, var.region)
#   force_destroy = true
# }

# TODO: Need to implement cross account iam role for delivery to cloudwatch logs
module "flow_logs" {
  source                        = "../../flow_logs"
  for_each                      = { for idx, vpc in local.spoke_vpcs : vpc.vpc_name => vpc }
  name_prefix                   = each.value.vpc_name
  vpc_id                        = each.value.vpc_id
  subnet_id                     = null
  eni_id                        = null
  transit_gateway_id            = null
  transit_gateway_attachment_id = null
  max_aggregation_interval      = 60
  configuration = {
    log_destination_type = "cloud-watch-logs"
    # log_destination      = "s3"
    # log_destination      = aws_s3_bucket.default.arn
    retention_in_days = 7
  }
}