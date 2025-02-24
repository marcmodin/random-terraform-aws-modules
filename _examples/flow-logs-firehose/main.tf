

data "aws_caller_identity" "current" {}

locals {
  account_id            = data.aws_caller_identity.current.account_id
  root_arn              = "arn:aws:iam::${local.account_id}:root"
  flow_logs_bucket_name = format("%s-%s-flow-logs-30423j43947834", var.name_prefix, var.region)
}


###################################################
# Create Transit Gateway which VPC Wrapper will use
###################################################

module "transit_gateway" {
  source          = "../../_modules/transit-gateway"
  name_prefix     = format("%s-%s", var.name_prefix, var.region)
  amazon_side_asn = 64512

  # use the the default route table for all attachment associations and propagations
  create_route_tables = false

  default_route_table_association = "enable"
  default_route_table_propagation = "enable"

  tags = {
    Environment = "prod"
  }
}

############################################
# Create two spoke VPCs
############################################

locals {
  vpcs = {
    spoke-one = {
      ipv4_cidr_block = "10.0.0.0/26"
      network = {
        management = {
          netmask = 28
        }
      }
    },
    spoke-two = {
      ipv4_cidr_block = "10.0.0.64/26"
      network = {
        management = {
          netmask = 28
        }
      }
    }
  }
}

module "spoke_one" {
  source     = "aws-ia/vpc/aws"
  version    = ">= 4.2.0"
  for_each   = { for idx, vpc in local.vpcs : idx => vpc }
  name       = format("%s-%s", var.name_prefix, each.key)
  cidr_block = each.value.ipv4_cidr_block
  az_count   = 2
  subnets = merge(each.value.network, {
    transit_gateway = {
      netmask                                         = 28
      transit_gateway_default_route_table_association = true
      transit_gateway_default_route_table_propagation = true
      transit_gateway_dns_support                     = "enable"

      tags = {
        subnet_type = "tgw"
      }
    }
  })

  transit_gateway_id = module.transit_gateway.id

  transit_gateway_routes = {
    management = "10.0.0.0/8"
  }
}


################################################
# Create two instances in each spoke VPC
# with session manager private enpoints enabled
################################################

locals {
  spoke_vpcs = module.spoke_one
}

# # Create a session manager endpoint
# module "session_manager" {
#   source         = "../../_modules/session-manager"
#   for_each       = { for idx, vpc in local.spoke_vpcs : vpc.vpc_attributes.id => vpc }
#   name_prefix    = each.value.vpc_attributes.tags.Name
#   vpc_id         = each.value.vpc_attributes.id
#   vpc_cidr_block = each.value.vpc_attributes.cidr_block
#   subnet_ids     = [each.value.private_subnet_attributes_by_az["management/eu-north-1a"].id]
# }

# Create an instance
module "instance" {
  source        = "../../_modules/instance"
  for_each      = { for idx, vpc in local.spoke_vpcs : idx => vpc if idx == "spoke-two" }
  name_prefix   = format("%s-instance", var.name_prefix)
  instance_type = "t3.micro"
  vpc_id        = each.value.vpc_attributes.id
  subnet_id     = each.value.private_subnet_attributes_by_az["management/eu-north-1a"].id
  state         = "running"
}

# output "instance_private_ips" {
#   value = module.instance
# }

################################################
# Create internet monitor to test flow logs
################################################

resource "aws_networkmonitor_monitor" "spoke_one" {
  aggregation_period = 60
  monitor_name       = local.spoke_vpcs["spoke-one"].vpc_attributes.tags.Name
}

resource "aws_networkmonitor_probe" "spoke-one" {
  monitor_name = aws_networkmonitor_monitor.spoke_one.monitor_name
  destination  = module.instance["spoke-two"].private_ip
  protocol     = "ICMP"
  source_arn   = local.spoke_vpcs["spoke-one"].private_subnet_attributes_by_az["management/eu-north-1a"].arn
  packet_size  = 56
}
