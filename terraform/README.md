# Terraform Role Creation

You can use [Terraform](https://www.terraform.io/) to apply our required IAM resources into your AWS account.

Our IAM role should ideally be set up in every AWS account you have. If that’s not feasible, then please apply it to your master payer account and your largest (by spend) accounts.

## Prerequisites

You'll need [Terraform](https://www.terraform.io/) (version `0.13` or newer) installed locally. We use the Terraform AWS provider, which must be configured to authenticate to your target AWS account via [environment variables](https://www.terraform.io/docs/providers/aws/index.html#environment-variables) or a [shared credentials file](https://www.terraform.io/docs/providers/aws/index.html#shared-credentials-file). Your AWS user will need to have privileges to create IAM roles and policies in your target account.

## Creating Resources

From this directory, apply the Terraform resources:

    $ make apply

Our automation scripting will initialize Terraform and perform Terraform `plan` and `apply` actions automatically for you.

Terraform will prompt you for a couple of required variables:

*Customer Name Slug:* This is a short, lower-case slug that identifies your company, e.g. `acme-corp`. Duckbill Group provided this to you in the Client Onboarding Guide.

*CUR S3 Bucket Name:* The name of the S3 bucket in which you are storing Cost and Usage Reports. If you haven't set up Cost and Usage reports in your master payer account yet, talk to us before applying this role.

*External ID:* The External ID used when Duckbill assumes the role. Duckbill Group provided this to you in the Client Onboarding Guide.

You'll be prompted to confirm the `apply` action.

## Deleting Resources

After we've completed our engagement, you can delete our IAM role and policy resources from your AWS account:

    $ make destroy

This will only work from the same computer that was used to create the resources (i.e. the `terraform.tfstate` file is present locally).

If you don't have access to the existing state file, you can delete the resources manually.

### Deleting Resources Manually

Log into the AWS console,

 - navigate to `IAM > Policies` and delete the `DuckbillGroupBilling` policy
 - navigate to `IAM > Policies` and delete the `DuckbillGroupResourceDiscovery` policy
 - navigate to `IAM > Policies` and delete the `DuckbillGroupCURIngestPipeline` policy
 - navigate to `IAM > Roles` and delete the `DuckbillGroupRole` role

## Advanced Usage

The `Makefile` contains a number of tasks for working with Terraform.

`make init`: Run `terraform init`

`make plan`: Run `terraform plan` and save the output in `terraform.tfplan`

`make apply`: Run `terraform apply` against `terraform.tfplan`

`make destroy`: Run `terraform destroy` against `terraform.tfstate`

`make clean`: Delete all terraform artifacts from the directory.

## Developer Information

There are some developer-focused `make` tasks:

`make fmt`: Run `terraform fmt`

`make fmtcheck`: Run `terraform fmt -check`

Our linting process consists of running the `fmtcheck` task in CI on every PR commit. You can run the linting task locally:

    $ make lint
