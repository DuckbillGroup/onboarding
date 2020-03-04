
## AWS CLI
```
export AWS_ACCOUNT_NUMBER=<your account number>
aws iam create-role --role-name DuckbillGroupRole-COP --assume-role-policy-document file://assume-role-trust-policy.json
aws iam create-policy --policy-name DuckbillGroupBilling --policy-document file://billing-policy.json
aws iam attach-role-policy --role-name DuckbillGroupRole-COP --policy-arn arn:aws:iam::aws:policy/ReadOnlyAccess
aws iam attach-role-policy --role-name DuckbillGroupRole-COP --policy-arn arn:aws:iam::aws:policy/job-function/Billing
aws iam attach-role-policy --role-name DuckbillGroupRole-COP --policy-arn arn:aws:iam::${AWS_ACCOUNT_NUMBER}:policy/DuckbillGroupBilling
```
