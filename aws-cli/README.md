# AWS CLI Role Creation

You can use the AWS CLI to apply our required IAM resources into your AWS account. We've provided some helpful scripts that do everything for you!

Our IAM role should ideally be set up in every AWS account you have. If that’s not feasible, then please apply it to your master payer account and your largest (by spend) accounts.

## Prerequisites

You'll need the [AWS CLI](https://aws.amazon.com/cli/) installed and [configured](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-configure.html) for your target AWS account. Your AWS user will need to have privileges to create IAM roles and policies in your target account.

## Creating Resources

From this directory, create the IAM role and policies via our role creation script:

    $ make create

The script will prompt you for a couple of required parameters:

*Customer Name Slug:* This is a short, lower-case slug that identifies your company, e.g. `acme-corp`. Duckbill Group will need to know this value, so that we can set up our own infrastructure for you.

*CUR S3 Bucket Name:* The name of the S3 bucket in which you are storing Cost and Usage Reports. If you haven't set up Cost and Usage reports in your master payer account yet, talk to us before applying this role.

*External ID:* The External ID used when Duckbill assumes the role. Duckbill will provide you with a unique UUID in the onboarding documents to use for this field.

## Deleting Resources

After we've completed our engagement, you can delete our IAM role and policy resources from your AWS account:

    $ make delete

If you prefer or need to use the AWS console, you can delete the resources manually.

### Deleting Resources Manually

Log into the AWS console,

 - navigate to `IAM > Policies` and delete the `DuckbillGroupBilling` policy
 - navigate to `IAM > Policies` and delete the `DuckbillGroupResourceDiscovery` policy
 - navigate to `IAM > Policies` and delete the `DuckbillGroupCURIngestPipeline` policy
 - navigate to `IAM > Roles` and delete the `DuckbillGroupRole` role

## Developer Information

We lint our shell scripts with `shellcheck`, which runs in CI on every PR. If you have `shellcheck` installed locally, you can run the linter:

    $ make lint
