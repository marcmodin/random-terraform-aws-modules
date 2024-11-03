locals {
  name            = "${var.name_prefix}-cwfl"
  log_destination = var.configuration.log_destination != null ? var.configuration.log_destination : aws_cloudwatch_log_group.default[0].arn
  iam_role_arn    = var.configuration.log_destination_type == "cloud-watch-logs" ? aws_iam_role.default[0].arn : null
}

###############################################################
# CLOUDWATCH LOG GROUP
###############################################################

resource "aws_cloudwatch_log_group" "default" {
  count             = var.configuration.log_destination_type == "cloud-watch-logs" ? 1 : 0
  name_prefix       = local.name
  retention_in_days = var.configuration.retention_in_days
  kms_key_id        = var.configuration.kms_key_id
  tags              = var.tags
}

###############################################################
# IAM
###############################################################

resource "aws_iam_role" "default" {
  count       = var.configuration.log_destination_type == "cloud-watch-logs" ? 1 : 0
  name_prefix = "${local.name}-role"
  description = "Cloudwatch Flow Logs permissions role for ${local.name}"
  tags        = merge({ Name = "${local.name}-role" }, var.tags)

  assume_role_policy = data.aws_iam_policy_document.assume_role[count.index].json
}

data "aws_iam_policy_document" "assume_role" {
  count = var.configuration.log_destination_type == "cloud-watch-logs" ? 1 : 0
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["vpc-flow-logs.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "default" {
  count = var.configuration.log_destination_type == "cloud-watch-logs" ? 1 : 0
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
      "logs:PutLogEvents",
    ]
    resources = [format("%s:*", aws_cloudwatch_log_group.default[count.index].arn)]
  }
}

resource "aws_iam_policy" "default" {
  count       = var.configuration.log_destination_type == "cloud-watch-logs" ? 1 : 0
  name_prefix = "${aws_iam_role.default[count.index].name}-policy"
  policy      = data.aws_iam_policy_document.default[count.index].json
  description = "Cloudwatch permissions policy for ${aws_iam_role.default[count.index].name}"
  tags        = merge({ Name = "${aws_iam_role.default[count.index].name}-policy" }, var.tags)
}

resource "aws_iam_role_policy_attachment" "default" {
  count      = var.configuration.log_destination_type == "cloud-watch-logs" ? 1 : 0
  role       = aws_iam_role.default[count.index].name
  policy_arn = aws_iam_policy.default[count.index].arn
}

###############################################################
# FLOW LOG
###############################################################
resource "aws_flow_log" "default" {
  log_destination               = local.log_destination
  iam_role_arn                  = local.iam_role_arn
  log_destination_type          = var.configuration.log_destination_type
  log_format                    = var.log_format
  traffic_type                  = var.configuration.traffic_type
  vpc_id                        = var.vpc_id
  subnet_id                     = var.subnet_id
  eni_id                        = var.eni_id
  transit_gateway_id            = var.transit_gateway_id
  transit_gateway_attachment_id = var.transit_gateway_attachment_id
  max_aggregation_interval      = var.max_aggregation_interval

  dynamic "destination_options" {
    for_each = var.configuration.log_destination_type == "s3" && var.configuration.destination_options != null ? [1] : []

    content {
      file_format                = var.configuration.destination_options.file_format
      per_hour_partition         = var.configuration.destination_options.per_hour_partition
      hive_compatible_partitions = var.configuration.destination_options.hive_compatible_partitions
    }
  }

  tags = merge(
    { Name = local.name },
    var.tags
  )
}
