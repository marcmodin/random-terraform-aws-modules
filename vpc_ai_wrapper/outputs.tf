output "vpc_id" {
  value       = module.wrapper.vpc_attributes.id
  description = "The unique identifier of the VPC."
}

output "vpc_cidr_block" {
  value       = module.wrapper.vpc_attributes.cidr_block
  description = "The CIDR block assigned to the VPC."
}

output "public_subnets" {
  value       = module.wrapper.public_subnet_attributes_by_az
  description = "Attributes of public subnets grouped by availability zone."
}

output "private_subnets" {
  value       = module.wrapper.private_subnet_attributes_by_az
  description = "Attributes of private subnets grouped by availability zone."
}

output "transit_gateway_attachment_id" {
  value       = try(module.wrapper.transit_gateway_attachment_id, null)
  description = "The ID of the Transit Gateway attachment, if configured."
}
