# CloudFormation Role Creation

You can use [AWS CloudFormation](https://aws.amazon.com/cloudformation/) to apply our required IAM resources into your AWS account.

Depending on what you've hired us to do, there are a couple of different roles you can create. We'll let you know which role to use.

If we're working on a *Cost Optimization Project* for you, please set up the [Cost Optimization Project Role](#Cost-Optimization-Project-Role). This role should ideally be set up in every account you have. If that’s not feasible, then apply it to your master payer account and your largest (by spend) account.

If you've hired us for a *Cloud Finance & Analysis* engagement, please set up the [Cloud Finance Analysis Role](#Cloud-Finance-Analysis-Role). This role should be applied to your master payer AWS account only.

## Cost Optimization Project Role

From your AWS console, please [create a new stack](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/cfn-console-create-stack.html).

You'll choose to *Upload a template file*, and you should use the [cop/duckbill-cop-iam-role.yml](cop/duckbill-cop-iam-role.yml) template from this repo.

Name your stack whatever you'd like (we recommend `DuckbillGroupRole-COP`). You can accept all the default options, or you can adjust the stack options per your company policies or preferences.

## Cloud Finance Analysis Role

From your AWS console, please [create a new stack](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/cfn-console-create-stack.html).

You'll choose to *Upload a template file*, and you should use the [cfa/duckbill-cfa-iam-role.yml](cfa/duckbill-cfa-iam-role.yml) template from this repo.

Name your stack whatever you'd like (we recommend `DuckbillGroupRole-CFA`).

This stack includes a couple of required parameters, which you'll need to provide in the UI:

`CustomerNameSlug`: This is a short, lower-case slug that identifies your company, e.g. `acme-corp`. Duckbill Group will need to know this value, so that we can set up our own infrastructure for you.

`CURBucketName`: The name of the S3 bucket in which you are storing Cost and Usage Reports. If you haven't set up Cost and Usage reports in your master payer account yet, talk to us before applying this role.

You can accept all the default options, or you can adjust the stack options per your company policies or preferences.

Please make sure to communicate your chosen `CustomerNameSlug` to us after you've successfully created the stack.

## Developer Information

We lint our CloudFormation templates with `cfn-lint`, which runs in CI on every PR. If you have `cfn-lint` installed locally, you can run the linter:

    $ make lint
