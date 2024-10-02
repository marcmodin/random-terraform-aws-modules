
data "aws_caller_identity" "this" {}

locals {
  this_account_id     = data.aws_caller_identity.this.account_id
  github_username     = var.github_username
  github_repositories = var.github_repositories
  github_subjects     = [for repo in local.github_repositories : "${local.github_username}/${repo}:*"]

  default_policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

# Create a GitHub OIDC provider
module "iam_github_oidc_provider" {
  source = "terraform-aws-modules/iam/aws//modules/iam-github-oidc-provider"
}

# Create a role that can be assumed by GitHub actions for Digger to use
module "digger_oidc_role" {
  source = "terraform-aws-modules/iam/aws//modules/iam-github-oidc-role"

  name = format("%s-terraform-deploy-demo-role", var.name_prefix)

  # This should be updated to suit your organization, repository, references/branches, etc.
  subjects = local.github_subjects

  policies = {
    DiggerLock = module.digger_dynamodb_lock_table.iam_policy_arn
  }
}

# Create a role that can be assumed by GitHub actions for aft management
module "terraform_oidc_admin_role" {
  source = "terraform-aws-modules/iam/aws//modules/iam-github-oidc-role"

  name = format("%s-terraform-admin-role", var.name_prefix)

  # This should be updated to suit your organization, repository, references/branches, etc.
  subjects = local.github_subjects

  policies = {
    Admin = local.default_policy_arn
  }
}

# Create digger dynamodb lock table
module "digger_dynamodb_lock_table" {
  source = "../../digger-dynamodb-lock"
}
