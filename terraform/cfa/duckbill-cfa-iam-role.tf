# These Terraform resources create a remote access role for Duckbill Group
# for a Cloud Finance and Analysis engagement.


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
  name               = "DuckbillGroupRole-CFA"
  assume_role_policy = "${data.aws_iam_policy_document.DuckbillGroup_AssumeRole_policy_document.json}"
}


# DuckbillGroupResourceDiscovery IAM Policy

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

resource "aws_iam_role_policy_attachment" "duckbill-attach-ViewOnlyAccess" {
  role       = "${aws_iam_role.DuckbillGroupRole.name}"
  policy_arn = "arn:aws:iam::aws:policy/job-function/ViewOnlyAccess"
}

resource "aws_iam_role_policy_attachment" "duckbill-attach-DuckbillGroupResourceDiscovery_policy" {
  role       = "${aws_iam_role.DuckbillGroupRole.name}"
  policy_arn = "${aws_iam_policy.DuckbillGroupResourceDiscovery_policy.arn}"
}

resource "aws_iam_role_policy_attachment" "duckbill-attach-DuckbillGroupCURIngestPipeline_policy" {
  role       = "${aws_iam_role.DuckbillGroupRole.name}"
  policy_arn = "${aws_iam_policy.DuckbillGroupCURIngestPipeline_policy.arn}"
}
