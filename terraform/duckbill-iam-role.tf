# These Terraform resources create a remote access role for Duckbill Group.


# Variables

variable "customer_name_slug" {
  type        = string
  description = "A short, lower-case slug that identifies your company, e.g. 'acme-corp'. Duckbill Group provided this to you in the Client Onboarding Guide."
}

variable "cur_bucket_name" {
  type        = string
  description = "Name of the S3 bucket in which you are storing Cost and Usage Reports."
}

variable "external_id" {
  type        = string
  description = "The External ID used when Duckbill assumes the role. Duckbill Group provided this to you in the Client Onboarding Guide."
}

locals {
  internal_customer_id = split("-", var.external_id)[0]
}

# Terraform configuration

terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
  required_version = ">= 0.13"
}

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

    condition {
      test     = "StringEquals"
      variable = "sts:ExternalId"
      values   = [var.external_id]
    }
  }
}

resource "aws_iam_role" "DuckbillGroupRole" {
  name               = "DuckbillGroupRole"
  assume_role_policy = data.aws_iam_policy_document.DuckbillGroup_AssumeRole_policy_document.json
}


# DuckbillGroupBilling IAM Policy

data "aws_iam_policy_document" "DuckbillGroupBilling_policy_document" {
  statement {
    effect = "Allow"

    actions = [
      "ce:*",
      "cur:DescribeReportDefinitions",
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
  policy = data.aws_iam_policy_document.DuckbillGroupBilling_policy_document.json
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
      "elasticmapreduce:Describe*",
      "es:ListTags",
      "es:DescribeReservedElasticsearchInstances",
      "fsx:Describe*",
      "glue:Get*",
      "glue:List*",
      "health:Describe*",
      "iam:GetPolicyVersion",
      "iam:GetRole",
      "iam:GetUser",
      "kafka:List*",
      "kinesis:Describe*",
      "kinesis:List*",
      "kms:Describe*",
      "kms:List*",
      "lambda:Get*",
      "lambda:List*",
      "lightsail:GetInstances",
      "lightsail:GetLoadBalancers",
      "lightsail:GetRelationalDatabases",
      "macie2:Describe*",
      "macie2:ListTagsForResources",
      "macie2:GetBucketStatistics",
      "macie2:GetMacieSession",
      "macie2:GetUsageStatistics",
      "macie2:GetUsageTotals",
      "medialive:Describe*",
      "medialive:List*",
      "mq:List*",
      "redshift:Describe*",
      "s3:GetAnalyticsConfiguration",
      "s3:GetBucket*",
      "s3:GetReplication*",
      "s3:GetStorageLensDashboard",
      "s3:GetStorageLensConfiguration",
      "s3:ListStorageLensConfigurations",
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
  policy = data.aws_iam_policy_document.DuckbillGroupResourceDiscovery_policy_document.json
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
      "arn:aws:s3:::dbg-cur-ingest-${var.customer_name_slug}/*",
      "arn:aws:s3:::dbg-cur-ingest-${local.internal_customer_id}",
      "arn:aws:s3:::dbg-cur-ingest-${local.internal_customer_id}/*"
    ]
  }
}

resource "aws_iam_policy" "DuckbillGroupCURIngestPipeline_policy" {
  name   = "DuckbillGroupCURIngestPipeline"
  policy = data.aws_iam_policy_document.DuckbillGroupCURIngestPipeline_policy_document.json
}


# DuckbillGroupDenySensitiveAccess - Prevent Access to Customer Data

data "aws_iam_policy_document" "DuckbillGroupDenySensitiveAccess_policy_document" {
  statement {
    effect = "Deny"

    actions = [
      "appsync:GetDataSource",
      "appsync:GetFunction",
      "athena:GetQueryExecution",
      "athena:GetQueryResults",
      "athena:GetQueryResultsStream",
      "cassandra:Select",
      "chatbot:DescribeSlackChannels",
      "chatbot:DescribeSlackUserIdentities",
      "chatbot:ListMicrosoftTeamsConfiguredTeams",
      "chatbot:ListMicrosoftTeamsUserIdentities",
      "chime:GetAttendee",
      "chime:GetChannelMessage",
      "chime:GetMeeting",
      "chime:GetMeetingDetail",
      "chime:GetRoom",
      "chime:GetUser",
      "chime:GetUserActivityReportData",
      "chime:GetUserByEmail",
      "chime:GetUserSettings",
      "chime:ListAttendees",
      "chime:ListMeetingEvents",
      "chime:ListMeetings",
      "chime:ListUsers",
      "cleanrooms:GetProtectedQuery",
      "cloudformation:GetTemplate",
      "cloudfront:GetFunction",
      "cloudtrail:GetQueryResults",
      "cloudtrail:LookupEvents",
      "codeartifact:GetPackageVersionAsset",
      "codeartifact:GetPackageVersionReadme",
      "codeartifact:ReadFromRepository",
      "codebuild:BatchGetReportGroups",
      "codebuild:BatchGetReports",
      "codecommit:BatchGetCommits",
      "codecommit:BatchGetPullRequests",
      "codecommit:BatchGetRepositories",
      "codecommit:DescribeMergeConflicts",
      "codecommit:DescribePullRequestEvents",
      "codecommit:GetApprovalRuleTemplate",
      "codecommit:GetBlob",
      "codecommit:GetBranch",
      "codecommit:GetComment",
      "codecommit:GetCommentReactions",
      "codecommit:GetCommentsForComparedCommit",
      "codecommit:GetCommentsForPullRequest",
      "codecommit:GetCommit",
      "codecommit:GetCommitHistory",
      "codecommit:GetCommitsFromMergeBase",
      "codecommit:GetDifferences",
      "codecommit:GetFile",
      "codecommit:GetFolder",
      "codecommit:GetMergeCommit",
      "codecommit:GetMergeConflicts",
      "codecommit:GetMergeOptions",
      "codecommit:GetObjectIdentifier",
      "codecommit:GetPullRequest",
      "codecommit:GetPullRequestApprovalStates",
      "codecommit:GetPullRequestOverrideState",
      "codecommit:GetReferences",
      "codecommit:GetTree",
      "codecommit:GitPull",
      "codeguru-profiler:GetRecommendations",
      "codeguru-reviewer:DescribeCodeReview",
      "codeguru-reviewer:DescribeRecommendationFeedback",
      "codepipeline:GetPipelineExecution",
      "cognito-identity:LookupDeveloperIdentity",
      "cognito-idp:AdminGetDevice",
      "cognito-idp:AdminGetUser",
      "cognito-idp:AdminListDevices",
      "cognito-idp:AdminListGroupsForUser",
      "cognito-idp:AdminListUserAuthEvents",
      "cognito-idp:GetDevice",
      "cognito-idp:GetGroup",
      "cognito-idp:GetUser",
      "cognito-idp:ListUsers",
      "cognito-idp:ListDevices",
      "cognito-idp:ListGroups",
      "cognito-sync:ListRecords",
      "cognito-sync:QueryRecords",
      "connect:ListUsers",
      "datapipeline:QueryObjects",
      "dax:BatchGetItem",
      "dax:GetItem",
      "dax:Query",
      "dax:Scan",
      "dynamodb:BatchGetItem",
      "dynamodb:GetItem",
      "dynamodb:GetRecords",
      "dynamodb:Query",
      "dynamodb:Scan",
      "ecr:GetDownloadUrlForLayer",
      "es:ESHttpDelete",
      "es:ESHttpGet",
      "es:ESHttpHead",
      "es:ESHttpPatch",
      "es:ESHttpPost",
      "es:ESHttpPut",
      "gamelift:GetInstanceAccess",
      "healthlake:ReadResource",
      "healthlake:SearchWithGet",
      "healthlake:SearchWithPost",
      "kendra:Query",
      "kinesis:GetRecords",
      "kinesisvideo:GetImages",
      "kinesisvideo:GetMedia",
      "lambda:GetFunction",
      "lambda:GetLayerVersion",
      "lightsail:GetContainerImages",
      "logs:GetLogEvents",
      "logs:GetLogRecord",
      "logs:GetQueryResults",
      "macie2:GetFindings",
      "mediastore:GetObject",
      "qldb:GetBlock",
      "rds:DownloadCompleteDBLogFile",
      "rds:DownloadDBLogFilePortion",
      "robomaker:GetWorldTemplateBody",
      "s3-object-lambda:GetObject",
      "s3-object-lambda:GetObjectVersion",
      "s3-object-lambda:ListBucket",
      "s3:GetObject",
      "s3:GetObjectVersion",
      "sagemaker:Search",
      "sdb:Select",
      "serverlessrepo:GetApplication",
      "serverlessrepo:GetCloudFormationTemplate",
      "sqs:ReceiveMessage",
      "ssm:GetDocument",
      "ssm:GetParameter",
      "ssm:GetParameterHistory",
      "ssm:GetParameters",
      "ssm:GetParametersByPath",
      "sso-directory:DescribeGroup",
      "sso-directory:DescribeUser",
      "sso-directory:SearchGroups",
      "sso-directory:SearchUsers",
      "sso:SearchGroups",
      "sso:SearchUsers",
      "support:DescribeAttachment",
      "support:DescribeCommunications",
      "workdocs:GetDocument",
      "workdocs:GetDocumentPath",
      "workdocs:GetDocumentVersion",
      "workmail:ListGroupMembers",
      "workmail:ListGroups",
      "workmail:ListUsers"
    ]

    not_resources = [
      "arn:aws:s3:::${var.cur_bucket_name}",
      "arn:aws:s3:::${var.cur_bucket_name}/*",
      "arn:aws:s3:::dbg-cur-ingest-${var.customer_name_slug}",
      "arn:aws:s3:::dbg-cur-ingest-${var.customer_name_slug}/*",
      "arn:aws:s3:::dbg-cur-ingest-${local.internal_customer_id}",
      "arn:aws:s3:::dbg-cur-ingest-${local.internal_customer_id}/*"
    ]
  }
}

resource "aws_iam_policy" "DuckbillGroupDenySensitiveAccess_policy" {
  name   = "DuckbillGroupDenySensitiveAccess"
  policy = data.aws_iam_policy_document.DuckbillGroupDenySensitiveAccess_policy_document.json
}


# Attach IAM Policies to DuckbillGroup Role

resource "aws_iam_role_policy_attachment" "duckbill-attach-ViewOnlyAccess" {
  role       = aws_iam_role.DuckbillGroupRole.name
  policy_arn = "arn:aws:iam::aws:policy/job-function/ViewOnlyAccess"
}

resource "aws_iam_role_policy_attachment" "duckbill-attach-Billing" {
  role       = aws_iam_role.DuckbillGroupRole.name
  policy_arn = "arn:aws:iam::aws:policy/job-function/Billing"
}

resource "aws_iam_role_policy_attachment" "duckbill-attach-SavingsPlans" {
  role       = aws_iam_role.DuckbillGroupRole.name
  policy_arn = "arn:aws:iam::aws:policy/AWSSavingsPlansReadOnlyAccess"
}

resource "aws_iam_role_policy_attachment" "duckbill-attach-DuckbillGroupBilling" {
  role       = aws_iam_role.DuckbillGroupRole.name
  policy_arn = aws_iam_policy.DuckbillGroupBilling_policy.arn
}

resource "aws_iam_role_policy_attachment" "duckbill-attach-DuckbillGroupResourceDiscovery_policy" {
  role       = aws_iam_role.DuckbillGroupRole.name
  policy_arn = aws_iam_policy.DuckbillGroupResourceDiscovery_policy.arn
}

resource "aws_iam_role_policy_attachment" "duckbill-attach-DuckbillGroupCURIngestPipeline_policy" {
  role       = aws_iam_role.DuckbillGroupRole.name
  policy_arn = aws_iam_policy.DuckbillGroupCURIngestPipeline_policy.arn
}

resource "aws_iam_role_policy_attachment" "duckbill-attach-DuckbillGroupDenySensitiveAccess_policy" {
  role       = aws_iam_role.DuckbillGroupRole.name
  policy_arn = aws_iam_policy.DuckbillGroupDenySensitiveAccess_policy.arn
}