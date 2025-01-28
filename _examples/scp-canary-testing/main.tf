data "aws_caller_identity" "this" {}

data "aws_organizations_organization" "default" {}

data "aws_organizations_organizational_unit_descendant_organizational_units" "default" {
  parent_id = data.aws_organizations_organization.default.roots[0].id
}

locals {
  organization_root_account_id = data.aws_organizations_organization.default.roots[0].id

  organization_id = data.aws_organizations_organization.default.id

  organizational_units = data.aws_organizations_organizational_unit_descendant_organizational_units.default.children

  # change this to the name of the OU you want to attach the policy to
  target_organizational_unit = "Management"

  # Filter out the Canary organizational unit from the list of organizational units
  selected_organizational_unit = merge([for ou in local.organizational_units : ou if ou.name == local.target_organizational_unit]...)

}

data "aws_iam_policy_document" "common" {
  statement {
    sid       = "DenyServiceByRegion"
    effect    = "Deny"
    resources = ["*"]

    actions = [
      "ec2:DescribeRegions",
      "ec2:DescribeSecurityGroups",
    ]

    condition {
      test     = "StringNotEquals"
      variable = "aws:RequestedRegion"

      values = [
        "eu-north-1"
      ]
    }
  }
}

resource "aws_organizations_policy" "common" {
  name    = "common_guardrail"
  content = data.aws_iam_policy_document.common.json
}

resource "aws_organizations_policy_attachment" "canary" {
  policy_id = aws_organizations_policy.common.id
  target_id = local.selected_organizational_unit.id
}