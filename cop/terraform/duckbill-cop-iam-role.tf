# These Terraform resrources create a remote access role for Duckbill Group
# for a Cost Optimization Project.


# Providers

provider "aws" {
  region = "us-east-1"
}


# DuckbillGroup IAM Role

data "aws_iam_policy_document" "DuckbillGroup_AssumeRole_policy_document" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = ["753095100886"]
    }
  }
}

resource "aws_iam_role" "DuckbillGroupRole" {
  name               = "DuckbillGroupRole"
  assume_role_policy = "${data.aws_iam_policy_document.DuckbillGroup_AssumeRole_policy_document.json}"
}


# DuckbillGroupBilling IAM Policy

data "aws_iam_policy_document" "DuckbillGroupBilling_policy_document" {
  statement {
    effect = "Allow"

    actions = [
      "ce:*",
      "cur:*",
      "aws-portal:ViewBilling",
      "aws-portal:ViewUsage",
      "budgets:ViewBudget",
      "compute-optimizer:Get*",
      "glue:BatchGetJobs",
      "glue:ListJobs",
      "pricing:GetProducts"
    ]

    resources = ["*"]
  }
}

resource "aws_iam_policy" "DuckbillGroupBilling_policy" {
  name   = "DuckbillGroupBilling"
  policy = "${data.aws_iam_policy_document.DuckbillGroupBilling_policy_document.json}"
}


# Attach IAM Policies to DuckbillGroup Role

resource "aws_iam_role_policy_attachment" "duckbill-attach-DuckbillGroupBilling_policy" {
  role       = "${aws_iam_role.DuckbillGroupRole.name}"
  policy_arn = "${aws_iam_policy.DuckbillGroupBilling_policy.arn}"
}

resource "aws_iam_role_policy_attachment" "duckbill-attach-Billing" {
  role       = "${aws_iam_role.DuckbillGroupRole.name}"
  policy_arn = "arn:aws:iam::aws:policy/job-function/Billing"
}

resource "aws_iam_role_policy_attachment" "duckbill-attach-ReadOnlyAccess" {
  role       = "${aws_iam_role.DuckbillGroupRole.name}"
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}
