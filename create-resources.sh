#!/usr/bin/env bash
# shellcheck disable=SC2094

# Creates all AWS IAM resources required for Duckbill Group remote access.

set -euo pipefail

this_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
user_arn=$(aws sts get-caller-identity --output text --query 'Arn' | tr -d '\r')
account_number=$(aws sts get-caller-identity --output text --query 'Account' | tr -d '\r')

cat <<EOM

Please enter the External ID provided to you by Duckbill Cloud Economists

EOM
read -rp 'External ID: ' external_id

cat <<EOM

Please enter the name of the S3 bucket where your Cost & Usage Report resides.

EOM
read -rp 'S3 Bucket Name: ' cur_bucket_name

sed "s/CUR_BUCKET_NAME/${cur_bucket_name}/g" \
	"${this_dir}/deny-sensitive-data-policy.json.template" > "${this_dir}/deny-sensitive-data-policy.json"

sed "s/CUR_BUCKET_NAME/${cur_bucket_name}/g" \
	"${this_dir}/data-export-hourly.json" > "${this_dir}/data-export-hourly.json"

sed "s/CUR_BUCKET_NAME/${cur_bucket_name}/g" \
	"${this_dir}/data-export-daily.json" > "${this_dir}/data-export-daily.json"

sed "s/CUR_BUCKET_NAME/${cur_bucket_name}/g" \
	"${this_dir}/billing-policy.json" > "${this_dir}/billing-policy.json"

sed "s/CUR_BUCKET_NAME/${cur_bucket_name}/g" \
	"${this_dir}/skyway-bucket-policy.json" > "${this_dir}/skyway-bucket-policy.json"

sed "s/EXTERNAL_ID/${external_id}/g" \
	"${this_dir}/dbg-assume-role-trust-policy.json.template" > "${this_dir}/dbg-assume-role-trust-policy.json"

sed "s/EXTERNAL_ID/${external_id}/g" \
	"${this_dir}/skyway-assume-role-trust-policy.json.template" > "${this_dir}/skyway-assume-role-trust-policy.json"

sed "s/CUSTOMER_ACCOUNT_NUMBER/${account_number}/g" \
	"${this_dir}/skyway-bucket-policy.json" > "${this_dir}/skyway-bucket-policy.json"

echo "Logged into AWS as ${user_arn}"
echo "Adding role and policies..."

echo "Setting up Duckbill Group access"
# Duckbill Group access
# More expansive as we need access to more stuff for cost optimization work
# At a minimum, deploy to payer. Ideally, all accounts.
aws iam create-role \
	--role-name DuckbillGroupRole \
	--assume-role-policy-document "file://${this_dir}/dbg-assume-role-trust-policy.json"

aws iam create-policy \
	--policy-name DuckbillGroupBilling \
	--policy-document "file://${this_dir}/billing-policy.json"

aws iam create-policy \
	--policy-name DuckbillGroupResourceDiscovery \
	--policy-document "file://${this_dir}/resource-discovery-policy.json"

# Denies access to all but the CUR bucket. Only relevant because the ResourceDiscoveryPolicy grants S3 access
aws iam create-policy \
	--policy-name DuckbillGroupDenySensitiveAccess \
	--policy-document "file://${this_dir}/deny-sensitive-data-policy.json"

aws iam attach-role-policy \
	--role-name DuckbillGroupRole \
	--policy-arn arn:aws:iam::aws:policy/job-function/ViewOnlyAccess

aws iam attach-role-policy \
	--role-name DuckbillGroupRole \
	--policy-arn "arn:aws:iam::${account_number}:policy/DuckbillGroupBilling"

aws iam attach-role-policy \
	--role-name DuckbillGroupRole \
	--policy-arn "arn:aws:iam::${account_number}:policy/DuckbillGroupResourceDiscovery"

aws iam attach-role-policy \
	--role-name DuckbillGroupRole \
	--policy-arn "arn:aws:iam::${account_number}:policy/DuckbillGroupDenySensitiveAccess"

echo "Setting up Skyway access"
# Skyway access
# Only needed on payer account
aws iam create-role \
	--role-name SkywayRole \
	--assume-role-policy-document "file://${this_dir}/skyway-assume-role-trust-policy.json"

aws iam create-policy \
	--policy-name SkywayAccess \
	--policy-document "file://${this_dir}/billing-policy.json"

aws iam attach-role-policy \
	--role-name SkywayRole \
	--policy-arn "arn:aws:iam::${account_number}:policy/SkywayAccess"

# Create CUR config
aws bcm-data-exports create-export --export file://data-export-hourly.json
aws bcm-data-exports create-export --export file://data-export-daily.json

# Set bucket policy on the bucket containing the CUR
aws s3api put-bucket-policy --bucket {{ cur_bucket_name }} --cli-input-json file://skyway-bucket-policy.json
echo "Done!"
