#!/usr/bin/env bash
# Deletes all AWS IAM resources required for Duckbill Group remote access
# for a Cost Optimization Project engagement.

set -euo pipefail

this_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
user_arn=$(aws sts get-caller-identity --output text --query 'Arn' | tr -d '\r')
account_number=$(aws sts get-caller-identity --output text --query 'Account' | tr -d '\r')

echo "Logged into AWS as ${user_arn}"
echo "Deleting Duckbill Group role and policies..."

aws iam detach-role-policy \
	--role-name DuckbillGroupRole-COP \
	--policy-arn arn:aws:iam::aws:policy/ReadOnlyAccess

aws iam detach-role-policy \
	--role-name DuckbillGroupRole-COP \
	--policy-arn arn:aws:iam::aws:policy/job-function/Billing

aws iam detach-role-policy \
	--role-name DuckbillGroupRole-COP \
	--policy-arn "arn:aws:iam::${account_number}:policy/DuckbillGroupBilling"

aws iam delete-policy \
	--policy-arn "arn:aws:iam::${account_number}:policy/DuckbillGroupBilling"

aws iam delete-role \
	--role-name DuckbillGroupRole-COP

echo "Done!"
