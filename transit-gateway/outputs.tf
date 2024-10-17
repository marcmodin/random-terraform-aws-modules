output "name" {
  value = var.name_prefix
}

output "id" {
  value = try(aws_ec2_transit_gateway.default.id, "")
}

output "arn" {
  value = try(aws_ec2_transit_gateway.default.arn, "")
}

output "region" {
  value = local.this_region
}

output "route_tables" {
  value = { for key, val in aws_ec2_transit_gateway_route_table.default : key => val.id }
}

output "resource_share_principals" {
  value = try(aws_ram_principal_association.default, {})
}