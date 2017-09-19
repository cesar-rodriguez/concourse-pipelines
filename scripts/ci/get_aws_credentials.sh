#!/bin/sh
#
# Retrieves AWS STS tokens from Vault and creates a credentials file
#

set -e

environments=$(ls vault/aws)
for env in $environments
do
    echo "
    [$env]
    aws_access_key_id = $(cat vault/aws/$env/sts/aws-global-admin.json | jq -r '.access_key')
    aws_secret_access_key = $(cat vault/aws/$env/sts/aws-global-admin.json | jq -r '.secret_key')
    aws_session_token = $(cat vault/aws/$env/sts/aws-global-admin.json | jq -r '.security_token')
    " >> aws-creds/credentials
done
