#!/usr/bin/env bash
# Deletes all AWS IAM resources required for Duckbill Group remote access.

set -euo pipefail

user_arn=$(aws sts get-caller-identity --output text --query 'Arn' | tr -d '\r')
account_number=$(aws sts get-caller-identity --output text --query 'Account' | tr -d '\r')

echo "Logged into AWS as ${user_arn}"
echo "Deleting Duckbill Group role and policies..."

aws iam detach-role-policy \
	--role-name DuckbillGroupRole \
	--policy-arn arn:aws:iam::aws:policy/job-function/ViewOnlyAccess

aws iam detach-role-policy \
	--role-name DuckbillGroupRole \
	--policy-arn arn:aws:iam::aws:policy/job-function/Billing

aws iam detach-role-policy \
	--role-name DuckbillGroupRole \
	--policy-arn arn:aws:iam::aws:policy/AWSSavingsPlansReadOnlyAccess

aws iam detach-role-policy \
	--role-name DuckbillGroupRole \
	--policy-arn "arn:aws:iam::${account_number}:policy/DuckbillGroupBilling"

aws iam detach-role-policy \
	--role-name DuckbillGroupRole \
	--policy-arn "arn:aws:iam::${account_number}:policy/DuckbillGroupResourceDiscovery"

aws iam delete-policy \
	--policy-arn "arn:aws:iam::${account_number}:policy/DuckbillGroupBilling"

aws iam delete-policy \
	--policy-arn "arn:aws:iam::${account_number}:policy/DuckbillGroupResourceDiscovery"

aws iam delete-role \
	--role-name DuckbillGroupRole

echo "Done!"
