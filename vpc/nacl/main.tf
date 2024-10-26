variable "name" {
  type        = string
  description = "The name of the nacl"
}

variable "vpc_id" {
  type        = string
  description = "The VPC ID to create the nacl in"
}

variable "subnet_ids" {
  type        = list(string)
  description = "The subnet IDs to associate with the nacl"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags to apply to all resources"
}

resource "aws_network_acl" "default" {
  vpc_id     = var.vpc_id
  subnet_ids = var.subnet_ids

  tags = merge(var.tags, {
    Name = var.name
  })

  lifecycle {
    ignore_changes = [ingress, egress]
  }
}


resource "aws_network_acl_rule" "default_ingress" {
  network_acl_id = aws_network_acl.default.id
  rule_action    = "allow"
  rule_number    = 100
  egress         = false
  cidr_block     = "0.0.0.0/0" #tfsec:ignore:aws-ec2-no-public-ingress-acl
  from_port      = 0
  to_port        = 0
  protocol       = "-1" #tfsec:ignore:aws-ec2-no-excessive-port-access

  lifecycle {
    create_before_destroy = false
  }
}

resource "aws_network_acl_rule" "default_egress" {
  network_acl_id = aws_network_acl.default.id
  rule_action    = "allow"
  rule_number    = 100
  egress         = true
  cidr_block     = "0.0.0.0/0"
  from_port      = 0
  to_port        = 0
  protocol       = "-1" #tfsec:ignore:aws-ec2-no-excessive-port-access

  lifecycle {
    create_before_destroy = false
  }
}

output "id" {
  value = aws_network_acl.default.id
}

output "arn" {
  value = aws_network_acl.default.arn
}

output "name" {
  value = var.name
}

output "associated_subnet_ids" {
  value = aws_network_acl.default.subnet_ids
}