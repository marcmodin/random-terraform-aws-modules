output "vpc_name" {
  value       = aws_vpc.default.tags.Name
  description = "The name assigned to the default VPC."
}

output "vpc_id" {
  value       = aws_vpc.default.id
  description = "The unique identifier of the default VPC."
}

output "vpc_arn" {
  value       = aws_vpc.default.arn
  description = "The ARN of the default VPC."
}

output "vpc_cidr_block" {
  value       = aws_vpc.default.cidr_block
  description = "The CIDR block of the default VPC."
}

output "vpc_default_route_table_id" {
  value       = aws_vpc.default.default_route_table_id
  description = "The ID of the default route table for the VPC."
}

output "vpc_default_network_acl_id" {
  value       = aws_vpc.default.default_network_acl_id
  description = "The ID of the default Network ACL for the VPC."
}

output "vpc_default_security_group_id" {
  value       = aws_vpc.default.default_security_group_id
  description = "The ID of the default Security Group for the VPC."
}

output "vpc_dhcp_options_id" {
  value       = aws_vpc.default.dhcp_options_id
  description = "The ID of the DHCP options set associated with the VPC."
}

output "subnets" {
  value       = local.subnets_created
  description = "A list of subnets created within the VPC."
}

output "subnets_by_group" {
  value       = local.subnets_by_group
  description = "Subnets grouped by group name. Example usage: get a single id - [element(module.vpc.subnets_by_group.management, 0).id]"
}

output "transit_gateway_attachment" {
  value       = try(module.tgw-attachment, null)
  description = "Transit Gateway Attachment module output."
}

output "nacls" {
  value       = module.nacl
  description = "A list of Network ACLs created within the VPC."
}

output "nacl_rules" {
  value       = module.nacl-rules
  description = "A list of rules associated with the Network ACLs in the VPC."
}

