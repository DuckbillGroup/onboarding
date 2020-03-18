# AWS CLI Role Creation

You can use the AWS CLI to apply our required IAM resources into your AWS account. We've provided some helpful scripts that do everything for you!

Depending on what you've hired us to do, there are a couple of different roles you can create. We'll let you know which role to use.

If we're working on a *Cost Optimization Project* for you, please set up the [Cost Optimization Project Role](#Cost-Optimization-Project-Role). This role should ideally be set up in every account you have. If that’s not feasible, then apply it to your master payer account and your largest (by spend) account.

If you've hired us for a *Cloud Finance & Analysis* engagement, please set up the [Cloud Finance Analysis Role](#Cloud-Finance-Analysis-Role). This role should be applied to your master payer AWS account only.

## Prerequisites

You'll need the [AWS CLI](https://aws.amazon.com/cli/) installed and [configured](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-configure.html) for your target AWS account. Your AWS user will need to have privileges to create IAM roles and policies in your target account.

## Cost Optimization Project Role

From this directory, create the COP role via our role creation script:

    $ make create-cop

## Cloud Finance Analysis Role

From this directory, create the CFA role via our role creation script:

    $ make create-cfa

The script will prompt you for a couple of required parameters:

*Customer Name Slug:* This is a short, lower-case slug that identifies your company, e.g. `acme-corp`. Duckbill Group will need to know this value, so that we can set up our own infrastructure for you.

*CUR S3 Bucket Name:* The name of the S3 bucket in which you are storing Cost and Usage Reports. If you haven't set up Cost and Usage reports in your master payer account yet, talk to us before applying this role.

Please make sure to communicate your chosen *Customer Name Slug* to us after the script completes successfully.

## Deleting Resources

After we've completed our engagement, you can delete our IAM role and policy resources from your AWS account:

    $ make delete-cop

or

    $ make delete-cfa

If you prefer or need to use the AWS console, you can delete the resources manually.

### Deleting Cost Optimization Project Resources Manually

Log into the AWS console,

 - navigate to `IAM > Policies` and delete the `DuckbillGroupBilling` policy
 - navigate to `IAM > Roles` and delete the `DuckbillGroupRole-COP` role

### Deleting Cloud Finance Analysis Resources Manually

Log into the AWS console,

 - navigate to `IAM > Policies` and delete the `DuckbillGroupResourceDiscovery` policy
 - navigate to `IAM > Policies` and delete the `DuckbillGroupCURIngestPipeline` policy
 - navigate to `IAM > Roles` and delete the `DuckbillGroupRole-CFA` role

## Developer Information

We lint our shell scripts with `shellcheck`, which runs in CI on every PR. If you have `shellcheck` installed locally, you can run the linter:

    $ make lint
