
variable "inbound_rules" {
  type = list(object({
    action     = string
    number     = number
    cidr_block = string
    from_port  = number
    to_port    = number
    protocol   = string
  }))
  description = "List of rules to apply to the NACL"
}

variable "outbound_rules" {
  type = list(object({
    action     = string
    number     = number
    cidr_block = string
    from_port  = number
    to_port    = number
    protocol   = string
  }))
  description = "List of rules to apply to the NACL"
}

variable "nacl_id" {
  type        = string
  description = "ID of the NACL to apply rules to"
}


resource "aws_network_acl_rule" "default_ingress" {
  for_each       = { for key, val in var.inbound_rules : val.number => val }
  network_acl_id = var.nacl_id
  egress         = false
  rule_action    = each.value.action
  rule_number    = each.value.number
  cidr_block     = each.value.cidr_block
  from_port      = each.value.from_port
  to_port        = each.value.to_port
  protocol       = each.value.protocol

  lifecycle {
    create_before_destroy = false
  }
}

resource "aws_network_acl_rule" "default_egress" {
  for_each       = { for key, val in var.outbound_rules : val.number => val }
  network_acl_id = var.nacl_id
  egress         = true
  rule_action    = each.value.action
  rule_number    = each.value.number
  cidr_block     = each.value.cidr_block
  from_port      = each.value.from_port
  to_port        = each.value.to_port
  protocol       = each.value.protocol
  lifecycle {
    create_before_destroy = false
  }
}

output "rules" {
  value = {
    inbound  = flatten([for rule in aws_network_acl_rule.default_ingress : rule])
    outbound = flatten([for rule in aws_network_acl_rule.default_egress : rule])
  }
}