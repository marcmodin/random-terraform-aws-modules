
variable "name" {
  type        = string
  description = "The name of the subnet"
}

variable "vpc_id" {
  type        = string
  description = "The VPC ID to create the subnet in"
}

variable "availability_zone_id" {
  type        = string
  description = "The availability zone ID to create the subnet in"
}

variable "cidr_block" {
  type        = string
  description = "The CIDR block for the subnet"
}

variable "map_public_ip_on_launch" {
  type        = bool
  description = "Specify true to indicate that instances launched into the subnet should be assigned a public IP address."
  default     = false
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags to apply to all resources"
}


resource "aws_subnet" "default" {
  vpc_id                  = var.vpc_id
  availability_zone_id    = var.availability_zone_id
  cidr_block              = var.cidr_block
  map_public_ip_on_launch = var.map_public_ip_on_launch # prevent auto public ip assignment

  tags = merge(var.tags, {
    Name = var.name
  })

  lifecycle {
    ignore_changes = [
      availability_zone,
      availability_zone_id
    ]
  }
}

resource "aws_route_table" "default" {
  vpc_id = var.vpc_id

  tags = merge(
    var.tags,
    {
      "Name" = format("%s-rtb", var.name)
    }
  )

  lifecycle {
    ignore_changes = [
      route
    ]
  }
}

resource "aws_route_table_association" "default" {
  subnet_id = aws_subnet.default.id
  # Use element() to "wrap around" and allow for a single table to be associated with all subnets
  route_table_id = aws_route_table.default.id
}

output "name" {
  value = var.name
}

output "id" {
  value = aws_subnet.default.id
}

output "cidr_block" {
  value = aws_subnet.default.cidr_block
}

output "availability_zone_id" {
  value = aws_subnet.default.availability_zone_id
}

output "route_table_id" {
  value = aws_route_table.default.id
}

