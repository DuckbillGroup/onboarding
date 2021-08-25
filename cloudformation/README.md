# CloudFormation Role Creation

You can use [AWS CloudFormation](https://aws.amazon.com/cloudformation/) to apply our required IAM resources into your AWS account.

Our IAM role should ideally be set up in every AWS account you have. If that’s not feasible, then please apply it to your master payer account and your largest (by spend) accounts.

## Creating Resources

From your AWS console, please [create a new stack](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/cfn-console-create-stack.html).

You'll choose to *Upload a template file*, and you should use the [duckbill-iam-role.yml](duckbill-iam-role.yml) template from this directory.

Name your stack whatever you'd like (we recommend `DuckbillGroupRole`).

This stack includes a couple of required parameters, which you'll need to provide in the UI:

`CustomerNameSlug`: This is a short, lower-case slug that identifies your company, e.g. `acme-corp`. Duckbill Group will need to know this value, so that we can set up our own infrastructure for you.

`CURBucketName`: The name of the S3 bucket in which you are storing Cost and Usage Reports. If you haven't set up Cost and Usage reports in your master payer account yet, talk to us before applying this role.

`ExternalID`: The External ID used when Duckbill assumes the role. Duckbill will provide you with a unique UUID in the onboarding documents to use for this field.

You can accept all the default options, or you can adjust the stack options per your company policies or preferences.

Please make sure to communicate your chosen `CustomerNameSlug`, `CURBucketName`, and `ExternalID` to us after you've successfully created the stack.

## Deleting Resources

After we've completed our engagement, you can delete our IAM role and policy resources from your AWS account by [deleting the CloudFormation stack](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/cfn-console-delete-stack.html).

## Developer Information

We lint our CloudFormation template with `cfn-lint`, which runs in CI on every PR commit. If you have `cfn-lint` installed locally, you can run the linter:

    $ make lint
