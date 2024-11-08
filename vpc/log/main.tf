
###############################################################
# FLOW LOG
###############################################################
resource "aws_flow_log" "default" {
  log_destination          = var.configuration.log_destination
  log_destination_type     = "s3"
  log_format               = var.configuration.log_format
  traffic_type             = var.configuration.traffic_type
  vpc_id                   = var.vpc_id
  max_aggregation_interval = var.configuration.max_aggregation_interval

  dynamic "destination_options" {
    for_each = var.configuration.destination_options != null ? [1] : []

    content {
      file_format                = var.configuration.destination_options.file_format
      per_hour_partition         = var.configuration.destination_options.per_hour_partition
      hive_compatible_partitions = var.configuration.destination_options.hive_compatible_partitions
    }
  }

  tags = merge(
    { Name = var.name },
    var.tags
  )
}
