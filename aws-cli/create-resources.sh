#!/usr/bin/env bash
# Creates all AWS IAM resources required for Duckbill Group remote access.

set -euo pipefail

this_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
user_arn=$(aws sts get-caller-identity --output text --query 'Arn' | tr -d '\r')
account_number=$(aws sts get-caller-identity --output text --query 'Account' | tr -d '\r')

cat <<EOM

Please enter your customer name slug. This is a short, lower-case slug
that identifies your company, e.g. 'acme-corp'

Duckbill Group will need to know this value, so that we can set up our own
infrastructure for you.

EOM
read -rp 'Customer name slug: ' customer_name_slug

cat <<EOM

Please enter the name of the S3 bucket in which you are storing Cost and Usage Reports.

EOM
read -rp 'CUR S3 Bucket Name: ' cur_bucket_name

cat <<EOM

Please enter the External ID provided to you by Duckbill Cloud Economists

EOM
read -rp 'External ID: ' external_id

internal_customer_id=$(echo "${external_id}" | awk -F '-' '{print $1}' | tr -d '\r\n')

sed "s/CUSTOMER_NAME_SLUG/${customer_name_slug}/g;s/CUR_BUCKET_NAME/${cur_bucket_name}/g;s/INTERNAL_CUSTOMER_ID/${internal_customer_id}/g" \
	"${this_dir}/cur-ingest-pipeline-policy.json.template" > "${this_dir}/cur-ingest-pipeline-policy.json"

sed "s/CUSTOMER_NAME_SLUG/${customer_name_slug}/g;s/CUR_BUCKET_NAME/${cur_bucket_name}/g;s/INTERNAL_CUSTOMER_ID/${internal_customer_id}/g" \
	"${this_dir}/deny-sensitive-data-policy.json.template" > "${this_dir}/deny-sensitive-data-policy.json"

sed "s/EXTERNAL_ID/${external_id}/g" \
	"${this_dir}/assume-role-trust-policy.json.template" > "${this_dir}/assume-role-trust-policy.json"

echo "Logged into AWS as ${user_arn}"
echo "Adding Duckbill Group role and policies..."

aws iam create-role \
	--role-name DuckbillGroupRole \
	--assume-role-policy-document "file://${this_dir}/assume-role-trust-policy.json"

aws iam create-policy \
	--policy-name DuckbillGroupBilling \
	--policy-document "file://${this_dir}/billing-policy.json"

aws iam create-policy \
	--policy-name DuckbillGroupResourceDiscovery \
	--policy-document "file://${this_dir}/resource-discovery-policy.json"

aws iam create-policy \
	--policy-name DuckbillGroupCURIngestPipeline \
	--policy-document "file://${this_dir}/cur-ingest-pipeline-policy.json"

aws iam create-policy \
	--policy-name DuckbillGroupDenySensitiveAccess \
	--policy-document "file://${this_dir}/deny-sensitive-data-policy.json"

aws iam attach-role-policy \
	--role-name DuckbillGroupRole \
	--policy-arn arn:aws:iam::aws:policy/job-function/ViewOnlyAccess

aws iam attach-role-policy \
	--role-name DuckbillGroupRole \
	--policy-arn arn:aws:iam::aws:policy/job-function/Billing

aws iam attach-role-policy \
	--role-name DuckbillGroupRole \
	--policy-arn arn:aws:iam::aws:policy/AWSSavingsPlansReadOnlyAccess

aws iam attach-role-policy \
	--role-name DuckbillGroupRole \
	--policy-arn "arn:aws:iam::${account_number}:policy/DuckbillGroupBilling"

aws iam attach-role-policy \
	--role-name DuckbillGroupRole \
	--policy-arn "arn:aws:iam::${account_number}:policy/DuckbillGroupResourceDiscovery"

aws iam attach-role-policy \
	--role-name DuckbillGroupRole \
	--policy-arn "arn:aws:iam::${account_number}:policy/DuckbillGroupCURIngestPipeline"

aws iam attach-role-policy \
	--role-name DuckbillGroupRole \
	--policy-arn "arn:aws:iam::${account_number}:policy/DuckbillGroupDenySensitiveAccess"

echo "Done!"
