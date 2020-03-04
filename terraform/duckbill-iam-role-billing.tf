# These Terraform resrources create a remote access role for Duckbill Group
# for a Cost Optimization Project.


# Variables

variable "customer_name_slug" {
  type        = string
  description = "A short, lower-case slug that identifies your company, e.g. 'acme-corp'. Duckbill Group will need to know this value, so that we can set up our own infrastructure for you."
}

variable "cur_bucket_name" {
  type        = string
  description = "Name of the S3 bucket in which you are storing Cost and Usage Reports."
}


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


# DuckbillGroupCURIngestPipeline IAM Policy

data "aws_iam_policy_document" "DuckbillGroupCURIngestPipeline_policy_document" {
  statement {
    effect = "Allow"

    actions = [
      "s3:ListBucket",
      "s3:GetObject"
    ]

    resources = [
      "arn:aws:s3:::${var.cur_bucket_name}",
      "arn:aws:s3:::${var.cur_bucket_name}/*"
    ]
  }
  statement {
    effect = "Allow"

    actions = [
      "s3:ListBucket",
      "s3:PutObject",
      "s3:PutObjectAcl"
    ]

    resources = [
      "arn:aws:s3:::dbg-cur-ingest-${var.customer_name_slug}",
      "arn:aws:s3:::dbg-cur-ingest-${var.customer_name_slug}/*"
    ]
  }
}

resource "aws_iam_policy" "DuckbillGroupCURIngestPipeline_policy" {
  name   = "DuckbillGroupCURIngestPipeline"
  policy = "${data.aws_iam_policy_document.DuckbillGroupCURIngestPipeline_policy_document.json}"
}


# Attach IAM Policies to DuckbillGroup Role

resource "aws_iam_role_policy_attachment" "duckbill-attach-DuckbillGroupBilling_policy" {
  role       = "${aws_iam_role.DuckbillGroupRole.name}"
  policy_arn = "${aws_iam_policy.DuckbillGroupBilling_policy.arn}"
}

resource "aws_iam_role_policy_attachment" "duckbill-attach-DuckbillGroupCURIngestPipeline_policy" {
  role       = "${aws_iam_role.DuckbillGroupRole.name}"
  policy_arn = "${aws_iam_policy.DuckbillGroupCURIngestPipeline_policy.arn}"
}

resource "aws_iam_role_policy_attachment" "duckbill-attach-Billing" {
  role       = "${aws_iam_role.DuckbillGroupRole.name}"
  policy_arn = "arn:aws:iam::aws:policy/job-function/Billing"
}

resource "aws_iam_role_policy_attachment" "duckbill-attach-ReadOnlyAccess" {
  role       = "${aws_iam_role.DuckbillGroupRole.name}"
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}
