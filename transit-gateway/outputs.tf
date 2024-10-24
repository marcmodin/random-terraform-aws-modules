output "name" {
  value = var.name_prefix
  description = "The name of the Transit Gateway"
}

output "id" {
  value = try(aws_ec2_transit_gateway.default.id, "")
  description = "The ID of the Transit Gateway"
}

output "arn" {
  value = try(aws_ec2_transit_gateway.default.arn, "")
  description = "The ARN of the Transit Gateway"
}

output "region" {
  value = local.this_region
  description = "The region of the Transit Gateway"
}

output "route_tables" {
  value = { for key, val in aws_ec2_transit_gateway_route_table.default : key => val.id }
  description = "The IDs of the Transit Gateway route tables"
}

output "resource_share_principals" {
  value = try(aws_ram_principal_association.default, {})
  description = "The principals associated with the Transit Gateway resource share"
}