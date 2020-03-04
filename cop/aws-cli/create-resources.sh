#!/usr/bin/env bash
#

set -euo pipefail

this_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
user_arn=$(aws sts get-caller-identity --output text --query 'Arn' | tr -d '\r')
account_number=$(aws sts get-caller-identity --output text --query 'Account' | tr -d '\r')

echo "Logged into AWS as ${user_arn}"
echo "Adding Duckbill Group role and policies..."

aws iam create-role \
	--role-name DuckbillGroupRole-COP \
	--assume-role-policy-document file://${this_dir}/assume-role-trust-policy.json

aws iam create-policy \
	--policy-name DuckbillGroupBilling \
	--policy-document file://${this_dir}/billing-policy.json

aws iam attach-role-policy \
	--role-name DuckbillGroupRole-COP \
	--policy-arn arn:aws:iam::aws:policy/ReadOnlyAccess

aws iam attach-role-policy \
	--role-name DuckbillGroupRole-COP \
	--policy-arn arn:aws:iam::aws:policy/job-function/Billing

aws iam attach-role-policy \
	--role-name DuckbillGroupRole-COP \
	--policy-arn arn:aws:iam::${account_number}:policy/DuckbillGroupBilling

echo "Done!"
