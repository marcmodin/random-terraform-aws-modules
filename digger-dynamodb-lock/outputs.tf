output "dynamodb_table_arn" {
  description = "The Digger DynamoDB table ARN "
  value       = aws_dynamodb_table.default.arn
}

output "dynamodb_table_id" {
  description = "The Digger DynamoDB table ID"
  value       = aws_dynamodb_table.default.id
}

output "iam_policy_arn" {
  description = "The IAM Policy to access the DiggerDynamoDBLockTable"
  value       = aws_iam_policy.default.arn
}