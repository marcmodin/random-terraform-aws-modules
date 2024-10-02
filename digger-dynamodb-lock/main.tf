


############################################################
# Creates an Digger specific table  to lock Pull Requests
# https://docs.digger.dev/ce/cloud-providers/aws
############################################################

resource "aws_dynamodb_table" "default" {
  # the name has to match the one in the Digger code
  name                        = "DiggerDynamoDBLockTable"
  billing_mode                = "PAY_PER_REQUEST"
  hash_key                    = "PK"
  range_key                   = "SK"
  deletion_protection_enabled = var.enable_deletion_protection

  attribute {
    name = "PK"
    type = "S"
  }

  attribute {
    name = "SK"
    type = "S"
  }

  tags = var.tags
}

############################################################
# Creates an IAM Policy for Digger to lock Pull Requests
############################################################

data "aws_iam_policy_document" "default" {
  statement {
    sid = "AllowListTables"
    actions = [
      "dynamodb:List*",
      "dynamodb:DescribeReservedCapacity*",
      "dynamodb:DescribeLimits",
      "dynamodb:DescribeTimeToLive"
    ]
    effect    = "Allow"
    resources = ["*"]
  }

  statement {
    sid = "AllowDiggerTableActions"
    actions = [
      "dynamodb:BatchGet*",
      "dynamodb:DescribeStream",
      "dynamodb:DescribeTable",
      "dynamodb:Get*",
      "dynamodb:Query",
      "dynamodb:Scan",
      "dynamodb:BatchWrite*",
      # "dynamodb:CreateTable",
      "dynamodb:Delete*",
      "dynamodb:Update*",
      "dynamodb:PutItem"
    ]
    effect = "Allow"
    resources = [
      aws_dynamodb_table.default.arn
    ]
  }
}

resource "aws_iam_policy" "default" {

  name   = "DiggerDynamoDBLockTablePolicy"
  policy = data.aws_iam_policy_document.default.json

  tags = var.tags
}