# Duckbill Group Onboarding

### Purpose
We’ll be accessing your AWS accounts via an assumed role rather than IAM account. This needs to be set up in every account you have. If that’s not feasible, then apply it to your master payer account and your largest (by spend) account.

### Usage

There are two sets of IAM resources here, depending on how we're working together.

If we're working on a *Cost Optimization Project*, please set up the role in the `cop/` directory.

If you've hired us for *Cloud Finance & Analysis*, please set up the role in the `cfa/` directory.

We've provided three ways to set up our role and policies: CloudFormation, Terraform, or AWS CLI.

#### CloudFormation

The `/cloudformation` directory contains a CloudFormation template that creates all required resources.

From your AWS console, please [create a new stack](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/cfn-console-create-stack.html) from this template.

#### Terraform

The `/terraform` directory contains a Terraform config that create all required resources.

You'll need [Terraform](https://www.terraform.io/) installed and AWS credentials for the target account available in your shell.

```
$ terraform init
$ terraform plan -out terraform.tfplan
$ terraform apply terraform.tfplan
```

#### AWS CLI

The `/aws-cli` directory contains a script that will create all required resources.

You'll need the [AWS CLI](https://aws.amazon.com/cli/) installed and AWS credentials for the target account available in your shell.

```
$ ./create-resources.sh
```
