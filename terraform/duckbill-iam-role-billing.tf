# https://www.terraform.io/downloads.html
provider "aws" {
  region                  = "us-east-1"
}

# DuckbillGroup IAM Role
data "aws_iam_policy_document" "DuckbillGroup_AssumeRole_policy_document" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = ["789736909639"]
    }

    condition {
      test     = "StringEquals"
      variable = "sts:ExternalId"

      values = ["PlatypusBills"]
    }

  }
}

resource "aws_iam_role" "DuckbillGroupRole" {
  name               = "DuckbillGroupRole"
  assume_role_policy = "${data.aws_iam_policy_document.DuckbillGroup_AssumeRole_policy_document.json}"
}

# DuckbillGroup IAM Policy
data "aws_iam_policy_document" "DuckbillGroup_policy_document" {
  statement {
    effect = "Allow"

    actions = [
      "ce:*",
      "aws-portal:ViewBilling",
      "aws-portal:ViewUsage",
      "budgets:ViewBudget",
      "pricing:GetProducts",
    ]

    resources = ["*"]
  }
}

resource "aws_iam_policy" "DuckbillGroup_policy" {
  name   = "DuckbillGroupBilling"
  policy = "${data.aws_iam_policy_document.DuckbillGroup_policy_document.json}"
}

# Attach IAM Policies to DuckbillGroup Role
resource "aws_iam_role_policy_attachment" "duckbill-attach-DuckbillGroup_policy" {
  role       = "${aws_iam_role.DuckbillGroupRole.name}"
  policy_arn = "${aws_iam_policy.DuckbillGroup_policy.arn}"
}

resource "aws_iam_role_policy_attachment" "duckbill-attach-Billing" {
  role       = "${aws_iam_role.DuckbillGroupRole.name}"
  policy_arn = "arn:aws:iam::aws:policy/job-function/Billing"
}

resource "aws_iam_role_policy_attachment" "duckbill-attach-ReadOnlyAccess" {
  role       = "${aws_iam_role.DuckbillGroupRole.name}"
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}
