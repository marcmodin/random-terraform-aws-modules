output "endpoints" {
  value = { for key, val in aws_vpc_endpoint.default : key => val }

}