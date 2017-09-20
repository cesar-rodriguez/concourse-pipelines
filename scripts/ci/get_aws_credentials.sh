#!/bin/sh
#
# Retrieves AWS STS tokens from Vault and creates a credentials file
#

set -ex

echo "*** Using role $PIPELINE_AWS_ROLE"

environments=$(ls vault/aws)
for env in $environments
do
    echo "
    [$env]
    aws_access_key_id = $(cat vault/aws/$env/sts/${PIPELINE_AWS_ROLE}.json | jq -r '.access_key')
    aws_secret_access_key = $(cat vault/aws/$env/sts/${PIPELINE_AWS_ROLE}.json | jq -r '.secret_key')
    aws_session_token = $(cat vault/aws/$env/sts/${PIPELINE_AWS_ROLE}.json | jq -r '.security_token')
    " >> aws-creds/credentials
done
