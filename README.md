### Purpose
We’ll be accessing your AWS accounts via an assumed role rather than IAM account. This needs to be set up in every account you have. If that’s not feasible, then apply it to your master payer account and your largest (by spend) account.

### Usage
You can set this assumed role up with our CloudFormation template, our Terraform template, or do it manually.

#### CloudFormation
* Download the cloudformation/duckbill-iam-role.yml file to your laptop.
* Go to CloudFormation > Create stack > With new resources (standard).
* Upload the duckbill-iam-role.yml file.
* Click through the CloudFormation wizard with the default settings.
* Click "Create stack".

#### Terraform
* Copy the files in the terraform/ directory of this repo to your laptop.
* Initialize the Terraform providers.
```
$ terraform init
```
* If you'd like, you can plan the changes.
```
$ terraform plan
[...]

Plan: 5 to add, 0 to change, 0 to destroy.
```
* Apply the changes to create the role.
```
$ terraform apply
[...]

Apply complete! Resources: 5 added, 0 changed, 0 destroyed.
```

#### Manual
1. Go to IAM > Roles > Create Role > Another AWS Account: 789736909639
2. Assign the new role the AWS managed policy ReadOnlyAccess.
3. Add an additional inline policy, which you can download here.
4. Enable Require MFA and Require External ID.
5. Provide us with the External ID and ARN.
