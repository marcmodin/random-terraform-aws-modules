# Security Lake requires permission to replicate data across contributing and rollup Regions.
# AmazonSecurityLakeS3ReplicationRole is the role that Security Lake uses to replicate data across Regions.
data "aws_iam_policy_document" "replication" {
  statement {
    sid    = "AllowReadS3ReplicationSetting"
    effect = "Allow"

    resources = [
      "arn:aws:s3:::aws-security-data-lake-[[sourceRegions]]*",
      "arn:aws:s3:::aws-security-data-lake-[[sourceRegions]]*/*",
    ]

    actions = [
      "s3:ListBucket",
      "s3:GetReplicationConfiguration",
      "s3:GetObjectVersionForReplication",
      "s3:GetObjectVersion",
      "s3:GetObjectVersionAcl",
      "s3:GetObjectVersionTagging",
      "s3:GetObjectRetention",
      "s3:GetObjectLegalHold",
    ]
  }

  statement {
    sid       = "AllowS3Replication"
    effect    = "Allow"
    resources = ["arn:aws:s3:::aws-security-data-lake-[[destinationRegions]]*/*"]

    actions = [
      "s3:ReplicateObject",
      "s3:ReplicateDelete",
      "s3:ReplicateTags",
      "s3:GetObjectVersionTagging",
    ]
  }
}