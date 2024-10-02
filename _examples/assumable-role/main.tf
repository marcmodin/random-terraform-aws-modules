# Using modules from awesome https://github.com/terraform-aws-modules/terraform-aws-iam

data "aws_caller_identity" "current" {}

locals {
  account_id = data.aws_caller_identity.current.account_id
  root_arn   = "arn:aws:iam::${local.account_id}:root"
}

#########################################
# Assumable role
#########################################

data "aws_iam_policy_document" "assumable_role" {
  statement {
    sid = "AllowGetCallerIdentity"
    actions = [
      "sts:GetCallerIdentity"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "assumable_role" {

  name   = format("%s-role-policy", var.name_prefix)
  policy = data.aws_iam_policy_document.assumable_role.json
}

module "assumable_role" {

  source = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"

  create_role           = true
  force_detach_policies = true
  role_requires_mfa     = false

  role_name = format("%s-role", var.name_prefix)

  trusted_role_arns = [
    local.root_arn
  ]

  custom_role_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess", # Add Policy Arn
    aws_iam_policy.assumable_role.arn,
    module.iam_read_only_policy.arn,
    module.iam_inline_policy.arn,
    module.iam_policy_from_data_source.arn

  ]
}

#########################################
# Readonly IAM policy
#########################################

module "iam_read_only_policy" {
  source = "terraform-aws-modules/iam/aws//modules/iam-read-only-policy"

  name        = format("%s-policy-with-read-only", var.name_prefix)
  path        = "/"
  description = "Read only policy"

  allowed_services = ["dynamo", "iam"]
}

#########################################
# IAM policy with inline policy
#########################################

module "iam_inline_policy" {
  source = "terraform-aws-modules/iam/aws//modules/iam-policy"

  name_prefix = format("%s-policy-with-inline", var.name_prefix)
  path        = "/"
  description = "Default policy with inline policy"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "ec2:Describe*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}


#########################################
# IAM policy from data source
#########################################

data "aws_iam_policy_document" "iam_policy_from_data_source" {
  statement {
    sid = "AllowKMSKeyUsage"
    actions = [
      "kms:ListKeys",
      "kms:DescribeKey",
      "kms:Decrypt",
      "kms:GetKeyPolicy"
    ]
    resources = ["*"]
  }
}

module "iam_policy_from_data_source" {
  source      = "terraform-aws-modules/iam/aws//modules/iam-policy"
  name        = format("%s-policy-from-data-source", var.name_prefix)
  path        = "/"
  description = "Policy using from data source json"
  policy      = data.aws_iam_policy_document.iam_policy_from_data_source.json
  tags        = {}
}