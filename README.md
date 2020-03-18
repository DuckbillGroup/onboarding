# Duckbill Group Onboarding

This repo contains tooling to create AWS IAM roles and policies that Duckbill Group will use to access your AWS accounts. We always prefer to use [STS AssumeRole](https://docs.aws.amazon.com/STS/latest/APIReference/API_AssumeRole.html) rather than dedicated IAM users, and the scripts and templates here will enable you to create those resources in your AWS account.

We've provided a few different ways for you to create roles for us, depending on your technology preference. Each directory contains a README with detailed instructions.

- [cloudformation/](cloudformation/) Deploy a CloudFormation stack from the AWS console.
- [terraform/](terraform/) Apply resources via Terraform.
- [aws-cli/](aws-cli/) Create resources using the AWS CLI.

Please talk to us if any of this is confusing or if you have any questions at all.

We're excited to work with you!
