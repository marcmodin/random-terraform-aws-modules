
# Instance
#################

resource "aws_instance" "self" {
  ami                     = var.ami_id
  instance_type           = var.instance_type
  subnet_id               = var.subnet_id
  key_name                = var.key_name
  vpc_security_group_ids  = var.security_group_ids
  iam_instance_profile    = var.instance_profile
  disable_api_termination = var.enable_termination_protection
  ebs_optimized           = true
  monitoring              = var.monitoring

  tags = merge({
    Name      = var.name,
    ManagedBy = "terraform"
  }, var.tags)

  root_block_device {
    encrypted = true
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_put_response_hop_limit = 1
    http_tokens                 = "required"
  }

  lifecycle {
    create_before_destroy = true
  }

}



