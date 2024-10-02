output "id" {
  value       = local.self_id
  description = "outputs the security group id"
}

output "name" {
  value       = aws_security_group.default.name
  description = "outputs the security group name"
}
