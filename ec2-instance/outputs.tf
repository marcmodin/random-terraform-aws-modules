output "public_ip" {
  value = aws_instance.self.public_ip
}

output "private_ip" {
  value = aws_instance.self.private_ip
}

output "public_dns" {
  value = aws_instance.self.public_dns
}

output "private_dns" {
  value = aws_instance.self.private_dns
}

output "id" {
  value = aws_instance.self.id
}

output "arn" {
  value = aws_instance.self.arn
}

