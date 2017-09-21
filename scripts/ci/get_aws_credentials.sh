#!/bin/sh
#
# Retrieves AWS STS tokens from Vault and creates a credentials file
#

set -e

if [ ! -z ${DEBUG_MODE} ]
then
  if [ ${DEBUG_MODE} = "true" ]
  then
    echo "DEBUG MODE: Warning all STS tokens will be displayed in the Concourse UI"
    set -x
  fi
fi

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

echo "Stored STS tokens in aws-creds/credentials"
