# Terraform Role Creation

You can use [Terraform](https://www.terraform.io/) to apply our required IAM resources into your AWS account.

Depending on what you've hired us to do, there are a couple of different roles you can create. We'll let you know which role to use.

If we're working on a *Cost Optimization Project* for you, please set up the [Cost Optimization Project Role](#Cost-Optimization-Project-Role). This role should ideally be set up in every account you have. If that’s not feasible, then apply it to your master payer account and your largest (by spend) account.

If you've hired us for a *Cloud Finance & Analysis* engagement, please set up the [Cloud Finance Analysis Role](#Cloud-Finance-Analysis-Role). This role should be applied to your master payer AWS account only.

## Prerequisites

You'll need [Terraform](https://www.terraform.io/) (version `0.12` or newer) installed locally. We use the Terraform AWS provider, which must be configured to authenticate to your target AWS account via [environment variables](https://www.terraform.io/docs/providers/aws/index.html#environment-variables) or a [shared credentials file](https://www.terraform.io/docs/providers/aws/index.html#shared-credentials-file). Your AWS user will need to have privileges to create IAM roles and policies in your target account.

## Cost Optimization Project Role

From this directory, create the COP role:

    $ make apply-cop

Our automation scripting will initialize Terraform and perform Terraform `plan` and `apply` actions automatically for you. You'll be prompted to confirm the `apply` action.

## Cloud Finance Analysis Role

From this directory, create the COP role:

    $ make apply-cfa

Our automation scripting will initialize Terraform and perform Terraform `plan` and `apply` actions automatically for you.

Terraform will prompt you for a couple of required variables:

`customer_name_slug`: This is a short, lower-case slug that identifies your company, e.g. `acme-corp`. Duckbill Group will need to know this value, so that we can set up our own infrastructure for you.

`cur_bucket_name`: The name of the S3 bucket in which you are storing Cost and Usage Reports. If you haven't set up Cost and Usage reports in your master payer account yet, talk to us before applying this role.

You'll be prompted to confirm the `apply` action.

Please make sure to communicate your chosen `customer_name_slug` to us after you've successfully created the stack.

## Deleting Resources

After we've completed our engagement, you can delete our IAM role and policy resources from your AWS account:

    $ make destroy-cop

or

    $ make destroy-cfa

This will only work from the same computer that was used to create the resources (i.e. the `terraform.tfstate` file is present locally).

If you don't have access to the existing state file, you can delete the resources manually.

## Advanced Usage

The `Makefile` contains a number of tasks for working with Terraform. All tasks accept a  `-cop` or `-cfa` suffix, and will operate in the `cop/` or `cfa/` directory respectively.

`make init-(cop|cfa)`: Run `terraform init`

`make plan-(cop|cfa)`: Run `terraform plan` and save the output in `terraform.tfplan`

`make apply-(cop|cfa)`: Run `terraform apply` against `terraform.tfplan`

`make destroy-(cop|cfa)`: Run `terraform destroy` against `terraform.tfstate`

`make clean-(cop|cfa)`: Delete all terraform artifacts from the directory.

## Developer Information

There are some developer-focused `make` tasks:

`make fmt-(cop|cfa)`: Run `terraform fmt`

`make fmt`: Run `terraform fmt` against both directories.

`make fmtcheck-(cop|cfa)`: Run `terraform fmt -check`

Our linting process is to run the `fmtcheck` task against both directories, which runs in CI on every PR. You can run the linting task locally:

    $ make lint
