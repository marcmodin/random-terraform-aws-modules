output "transit_gateway" {
  value = module.transit_gateway
  description = "Transit Gateway module"
}

output "vpc_egress" {
  value = module.vpc_egress
  description = "Egress VPC module"
}

output "vpc_spoke" {
  value = module.vpc_spoke
  description = "Spoke VPC module"
}