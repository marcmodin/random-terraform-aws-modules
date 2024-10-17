

##############################################
# Transit Gateway
##############################################

data "aws_region" "this" {}

locals {
  this_region = data.aws_region.this.name
}

resource "aws_ec2_transit_gateway" "default" {
  description                        = format("%s tgw for %s", var.name_prefix, local.this_region)
  amazon_side_asn                    = var.amazon_side_asn
  auto_accept_shared_attachments     = var.auto_accept_shared_attachments
  default_route_table_association    = var.default_route_table_association
  default_route_table_propagation    = var.default_route_table_propagation
  security_group_referencing_support = var.security_group_referencing_support
  dns_support                        = var.dns_support
  vpn_ecmp_support                   = var.vpn_ecmp_support

  tags = merge({
    "Name" : var.name_prefix
  }, var.tags)

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_ec2_transit_gateway_route_table" "default" {
  for_each           = var.route_tables != {} ? var.route_tables : {}
  transit_gateway_id = aws_ec2_transit_gateway.default.id
  tags = merge({
    "Name" : format("%s", each.key)
  }, var.tags)

  lifecycle {
    create_before_destroy = true
  }
}

# This part is not working as expected
# the idea is that we should be able to assign specific route tables to be default for association and propagation tables
# issue is that deletion fails since the default association and propagation need to be reset to the default route table.

# locals {
#   default_route_table        = { for key, value in aws_ec2_transit_gateway_route_table.default : key => value.id if var.route_tables[key].default_table == true }
#   create_default_association = var.default_route_table_association == "enable" && var.create_route_tables && length([for k, v in local.default_route_table : k]) == 1 ? local.default_route_table : {}

#   default_route_table_propagation = { for key, value in aws_ec2_transit_gateway_route_table.default : key => value.id if var.route_tables[key].default_propagation == true }
#   create_default_propagation      = var.default_route_table_propagation == "enable" && var.create_route_tables && length([for k, v in local.default_route_table_propagation : k]) == 1 ? local.default_route_table_propagation : {}
# }

# # Create default route table association
# resource "aws_ec2_transit_gateway_default_route_table_association" "default" {
#   for_each                       = local.create_default_association
#   transit_gateway_id             = aws_ec2_transit_gateway.default.id
#   transit_gateway_route_table_id = each.value
# }

# # Create default route table propagation
# resource "aws_ec2_transit_gateway_default_route_table_propagation" "default" {
#   for_each                       = local.create_default_propagation
#   transit_gateway_id             = aws_ec2_transit_gateway.default.id
#   transit_gateway_route_table_id = each.value
# }

##############################################
# Resource Access Manager (RAM) Share
##############################################

locals {
  create_resource_share = length(var.resource_share_principals) > 0
}

# RAM Resource Share
resource "aws_ram_resource_share" "default" {
  count = local.create_resource_share ? 1 : 0

  name                      = format("%s tgw for %s resource share", var.name_prefix, local.this_region)
  allow_external_principals = false

  tags = merge({
    "Name" : var.name_prefix
  }, var.tags)
}

# RAM Resource Association
resource "aws_ram_resource_association" "default" {
  count = local.create_resource_share ? 1 : 0

  resource_arn       = aws_ec2_transit_gateway.default.arn
  resource_share_arn = aws_ram_resource_share.default[0].arn
}

# RAM Principal Association
resource "aws_ram_principal_association" "default" {
  for_each = toset(var.resource_share_principals)

  principal          = each.value
  resource_share_arn = aws_ram_resource_share.default[0].arn
}