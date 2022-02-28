# CloudFormation Role Creation

You can use [AWS CloudFormation](https://aws.amazon.com/cloudformation/) to apply our required IAM resources into your AWS account.

Our IAM role should ideally be set up in every AWS account you have. If that’s not feasible, then please apply it to your master payer account and your largest (by spend) accounts.

## Creating Resources

From your AWS console, please [create a new stack](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/cfn-console-create-stack.html).

You'll choose to *Upload a template file*, and you should use the [duckbill-iam-role.yml](duckbill-iam-role.yml) template from this directory.

Name your stack whatever you'd like (we recommend `DuckbillGroupRole`).

This stack includes a couple of required parameters, which you'll need to provide in the UI:

*Customer Name Slug:* This is a short, lower-case slug that identifies your company, e.g. `acme-corp`. Duckbill Group provided this to you in the Client Onboarding Guide.

*CUR S3 Bucket Name:* The name of the S3 bucket in which you are storing Cost and Usage Reports. If you haven't set up Cost and Usage reports in your master payer account yet, talk to us before applying this role.

*External ID:* The External ID used when Duckbill assumes the role. Duckbill Group provided this to you in the Client Onboarding Guide.


## Deleting Resources

After we've completed our engagement, you can delete our IAM role and policy resources from your AWS account by [deleting the CloudFormation stack](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/cfn-console-delete-stack.html).

## Developer Information

We lint our CloudFormation template with `cfn-lint`, which runs in CI on every PR commit. If you have `cfn-lint` installed locally, you can run the linter:

    $ make lint
