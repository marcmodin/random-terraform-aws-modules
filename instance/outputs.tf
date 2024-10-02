output "id" {
  value = module.instance.id
}

output "private_dns" {
  value = module.instance.private_dns
}

output "private_ip" {
  value = module.instance.private_ip
}

output "instance_profile" {
  value = module.ssm_profile.id
}

output "instance_security_group_id" {
  value = module.security_group.id
}