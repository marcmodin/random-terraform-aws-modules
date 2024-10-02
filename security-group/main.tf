locals {
  self_id              = aws_security_group.default.id
  rule_has_source_type = [for rules in var.ingress_rules : rules if contains(keys(rules), "source_security_group")]
  rule_has_cidr_type   = [for rules in var.ingress_rules : rules if contains(keys(rules), "source_cidr")]
  rule_has_self_type   = [for rules in var.ingress_rules : rules if contains(keys(rules), "source_self")]

  egress_rule_has_source_type = [for rules in var.egress_rules : rules if contains(keys(rules), "source_security_group")]
  egress_rule_has_cidr_type   = [for rules in var.egress_rules : rules if contains(keys(rules), "source_cidr")]
  egress_rule_has_self_type   = [for rules in var.egress_rules : rules if contains(keys(rules), "source_self")]


}

################
## Security Group
################

resource "aws_security_group" "default" {
  # bridgecrew:skip=CKV2_AWS_5
  # SKIP CHECK: "Ensure that Security Groups are attached to an other resource"

  name        = var.name
  description = var.description
  vpc_id      = var.vpc_id

  tags = merge(
    {
      "Name" = format("%s", var.name)
    },
    var.tags,
  )

  lifecycle {
    create_before_destroy = true
  }

}

################
## Ingress Rules
################

# with cidr block
resource "aws_security_group_rule" "ingress_rule_cidr" {
  for_each = { for keys, rules in local.rule_has_cidr_type : format("%s_%s", try(lookup(rules, "type"), "custom"), lookup(rules, "source_cidr")[0]) => rules }

  type              = "ingress"
  security_group_id = local.self_id
  cidr_blocks       = lookup(each.value, "source_cidr")

  from_port   = try(lookup(each.value, "type"), null) == null || try(lookup(each.value, "type"), null) == "custom" ? lookup(each.value, "from_port") : lookup(var.allowed_rules, lookup(each.value, "type"))[0]
  to_port     = try(lookup(each.value, "type"), null) == null || try(lookup(each.value, "type"), null) == "custom" ? lookup(each.value, "to_port") : lookup(var.allowed_rules, lookup(each.value, "type"))[1]
  protocol    = try(lookup(each.value, "type"), null) == null || try(lookup(each.value, "type"), null) == "custom" ? lookup(each.value, "protocol") : lookup(var.allowed_rules, try(lookup(each.value, "type")))[2]
  description = try(lookup(each.value, "type"), null) == null || try(lookup(each.value, "type"), null) == "custom" ? try(lookup(each.value, "description"), null) : lookup(var.allowed_rules, try(lookup(each.value, "type")))[3]

  lifecycle {
    create_before_destroy = true
  }
}

# with self
resource "aws_security_group_rule" "ingress_rule_self" {
  for_each = { for keys, rules in local.rule_has_self_type : format("%s_self", try(lookup(rules, "type"), "custom")) => rules }

  type              = "ingress"
  security_group_id = local.self_id
  self              = true

  from_port   = try(lookup(each.value, "type"), null) == null || try(lookup(each.value, "type"), null) == "custom" ? lookup(each.value, "from_port") : lookup(var.allowed_rules, lookup(each.value, "type"))[0]
  to_port     = try(lookup(each.value, "type"), null) == null || try(lookup(each.value, "type"), null) == "custom" ? lookup(each.value, "to_port") : lookup(var.allowed_rules, lookup(each.value, "type"))[1]
  protocol    = try(lookup(each.value, "type"), null) == null || try(lookup(each.value, "type"), null) == "custom" ? lookup(each.value, "protocol") : lookup(var.allowed_rules, try(lookup(each.value, "type")))[2]
  description = try(lookup(each.value, "type"), null) == null || try(lookup(each.value, "type"), null) == "custom" ? try(lookup(each.value, "description"), null) : lookup(var.allowed_rules, try(lookup(each.value, "type")))[3]

  lifecycle {
    create_before_destroy = true
  }
}

# with source security group
resource "aws_security_group_rule" "ingress_rule_source" {
  for_each = { for keys, rules in local.rule_has_source_type : keys => rules }

  type                     = "ingress"
  security_group_id        = local.self_id
  source_security_group_id = lookup(each.value, "source_security_group")

  from_port = try(lookup(each.value, "type"), null) == null || try(lookup(each.value, "type"), null) == "custom" ? lookup(each.value, "from_port") : lookup(var.allowed_rules, lookup(each.value, "type"))[0]
  to_port   = try(lookup(each.value, "type"), null) == null || try(lookup(each.value, "type"), null) == "custom" ? lookup(each.value, "to_port") : lookup(var.allowed_rules, lookup(each.value, "type"))[1]
  protocol  = try(lookup(each.value, "type"), null) == null || try(lookup(each.value, "type"), null) == "custom" ? lookup(each.value, "protocol") : lookup(var.allowed_rules, try(lookup(each.value, "type")))[2]

  description = try(lookup(each.value, "type"), null) == null || try(lookup(each.value, "type"), null) == "custom" ? try(lookup(each.value, "description"), null) : lookup(var.allowed_rules, try(lookup(each.value, "type")))[3]

  lifecycle {
    create_before_destroy = true
  }
}

################
## Egress Rules
################

# with cidr block
resource "aws_security_group_rule" "egress_rule_cidr" {
  for_each = { for keys, rules in local.egress_rule_has_cidr_type : format("%s_%s", try(lookup(rules, "type"), "custom"), lookup(rules, "source_cidr")[0]) => rules }

  type              = "egress"
  security_group_id = local.self_id
  cidr_blocks       = lookup(each.value, "source_cidr")

  from_port   = try(lookup(each.value, "type"), null) == null || try(lookup(each.value, "type"), null) == "custom" ? lookup(each.value, "from_port") : lookup(var.allowed_rules, lookup(each.value, "type"))[0]
  to_port     = try(lookup(each.value, "type"), null) == null || try(lookup(each.value, "type"), null) == "custom" ? lookup(each.value, "to_port") : lookup(var.allowed_rules, lookup(each.value, "type"))[1]
  protocol    = try(lookup(each.value, "type"), null) == null || try(lookup(each.value, "type"), null) == "custom" ? lookup(each.value, "protocol") : lookup(var.allowed_rules, try(lookup(each.value, "type")))[2]
  description = try(lookup(each.value, "type"), null) == null || try(lookup(each.value, "type"), null) == "custom" ? try(lookup(each.value, "description"), null) : lookup(var.allowed_rules, try(lookup(each.value, "type")))[3]

  lifecycle {
    create_before_destroy = true
  }
}

# with self
resource "aws_security_group_rule" "egress_rule_self" {
  for_each = { for keys, rules in local.egress_rule_has_self_type : format("%s_self", try(lookup(rules, "type"), "custom")) => rules }

  type              = "egress"
  security_group_id = local.self_id
  self              = true

  from_port   = try(lookup(each.value, "type"), null) == null || try(lookup(each.value, "type"), null) == "custom" ? lookup(each.value, "from_port") : lookup(var.allowed_rules, lookup(each.value, "type"))[0]
  to_port     = try(lookup(each.value, "type"), null) == null || try(lookup(each.value, "type"), null) == "custom" ? lookup(each.value, "to_port") : lookup(var.allowed_rules, lookup(each.value, "type"))[1]
  protocol    = try(lookup(each.value, "type"), null) == null || try(lookup(each.value, "type"), null) == "custom" ? lookup(each.value, "protocol") : lookup(var.allowed_rules, try(lookup(each.value, "type")))[2]
  description = try(lookup(each.value, "type"), null) == null || try(lookup(each.value, "type"), null) == "custom" ? try(lookup(each.value, "description"), null) : lookup(var.allowed_rules, try(lookup(each.value, "type")))[3]

  lifecycle {
    create_before_destroy = true
  }
}

# with source security group
resource "aws_security_group_rule" "egress_rule_source" {
  for_each = { for keys, rules in local.egress_rule_has_source_type : keys => rules }

  type                     = "egress"
  security_group_id        = local.self_id
  source_security_group_id = lookup(each.value, "source_security_group")

  from_port   = try(lookup(each.value, "type"), null) == null || try(lookup(each.value, "type"), null) == "custom" ? lookup(each.value, "from_port") : lookup(var.allowed_rules, lookup(each.value, "type"))[0]
  to_port     = try(lookup(each.value, "type"), null) == null || try(lookup(each.value, "type"), null) == "custom" ? lookup(each.value, "to_port") : lookup(var.allowed_rules, lookup(each.value, "type"))[1]
  protocol    = try(lookup(each.value, "type"), null) == null || try(lookup(each.value, "type"), null) == "custom" ? lookup(each.value, "protocol") : lookup(var.allowed_rules, try(lookup(each.value, "type")))[2]
  description = try(lookup(each.value, "type"), null) == null || try(lookup(each.value, "type"), null) == "custom" ? try(lookup(each.value, "description"), null) : lookup(var.allowed_rules, try(lookup(each.value, "type")))[3]

  lifecycle {
    create_before_destroy = true
  }
}
