variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags to apply to all resources"
}

variable "enable_deletion_protection" {
  type        = bool
  default     = false
  description = "Enable deletion protection for the DynamoDB table"
}