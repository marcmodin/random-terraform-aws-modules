###########################################################
# Security Lake Data Lake MetaStoreManagerV2
###########################################################
# The Security Lake Data Lake MetaStoreManagerV2 role is an IAM role that Security Lake managed Lambda Function uses to manage the AWS Glue Data Catalog in the account.

module "security_lake_meta_store_manager" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"
  version = "5.48.0"

  create_role           = true
  force_detach_policies = true
  role_requires_mfa     = false
  role_path             = "/service-role/"
  role_name             = "AmazonSecurityLakeMetaStoreManagerV2"

  trusted_role_services = [
    "lambda.amazonaws.com"
  ]

  custom_role_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AmazonSecurityLakeMetastoreManager"
  ]
}


###########################################################
# Security Lake Data Lake Replication Manager
###########################################################
# The Security Lake Data Lake Replication Manager role is an IAM role that Security Lake uses to replicate data across contributing and rollup Regions.

module "security_lake_replication_manager" {
  for_each = var.replication_configuration_regions != null ? { true : {} } : {}
  source   = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"
  version  = "5.48.0"

  create_role           = true
  force_detach_policies = true
  role_requires_mfa     = false
  role_path             = "/service-role/"
  role_name             = "AmazonSecurityLakeS3ReplicationRole"

  trusted_role_services = [
    "s3.amazonaws.com"
  ]

  custom_role_policy_arns = [
    module.replication_policy["true"].arn
  ]
}

module "replication_policy" {
  for_each = var.replication_configuration_regions != null ? { true : {} } : {}
  source   = "terraform-aws-modules/iam/aws//modules/iam-policy"
  version  = "5.48.0"

  name        = "AmazonSecurityLakeS3ReplicationRolePolicy"
  description = "Policy for Security Lake S3 Replication Role"
  policy      = data.aws_iam_policy_document.replication.json
}