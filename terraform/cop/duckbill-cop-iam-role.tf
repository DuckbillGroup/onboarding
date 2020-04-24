# These Terraform resources create a remote access role for Duckbill Group
# for a Cost Optimization Project.


# Providers

provider "aws" {
  region  = "us-east-1"
  version = "~> 2.53"
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
  name               = "DuckbillGroupRole-COP"
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

# DuckbillGroupResourceDiscovery IAM Policy - a complimentary policy
# to the actions allowed by the ViewOnlyAccess policy

data "aws_iam_policy_document" "DuckbillGroupResourceDiscovery_policy_document" {
  statement {
    effect = "Allow"

    actions = [
      "acm:Describe*",
      "apigateway:GET",
      "batch:Describe*",
      "cloudhsm:Describe*",
      "cloudhsm:List*",
      "cloudwatch:Describe*",
      "codebuild:BatchGetProjects",
      "codecommit:BatchGetRepositories",
      "cognito-identity:Describe*",
      "cognito-idp:Describe*",
      "dax:Describe*",
      "dlm:Get*",
      "dms:Describe*",
      "ec2:Describe*",
      "eks:Describe*",
      "eks:List*",
      "elasticbeanstalk:ListTagsForResource",
      "elasticfilesystem:Describe*",
      "es:ListTags",
      "fsx:Describe*",
      "glue:Get*",
      "health:Describe*",
      "iam:GetRole",
      "iam:GetUser",
      "kafka:List*",
      "kms:Describe*",
      "kms:List*",
      "lightsail:GetInstances",
      "lightsail:GetLoadBalancers",
      "lightsail:GetRelationalDatabases",
      "mq:List*",
      "redshift:Describe*",
      "s3:GetBucket*",
      "s3:GetReplication*",
      "secretsmanager:ListSecrets",
      "shield:List*",
      "snowball:List*",
      "sns:GetTopicAttributes",
      "ssm:Describe*",
      "tag:Get*"
    ]

    resources = ["*"]
  }
}

resource "aws_iam_policy" "DuckbillGroupResourceDiscovery_policy" {
  name   = "DuckbillGroupResourceDiscovery"
  policy = "${data.aws_iam_policy_document.DuckbillGroupResourceDiscovery_policy_document.json}"
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

resource "aws_iam_role_policy_attachment" "duckbill-attach-DuckbillGroupResourceDiscovery_policy" {
  role       = "${aws_iam_role.DuckbillGroupRole.name}"
  policy_arn = "${aws_iam_policy.DuckbillGroupResourceDiscovery_policy.arn}"
}

resource "aws_iam_role_policy_attachment" "duckbill-attach-ReadOnlyAccess" {
  role       = "${aws_iam_role.DuckbillGroupRole.name}"
  policy_arn = "arn:aws:iam::aws:policy/job-function/ViewOnlyAccess"
}
