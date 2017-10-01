#!/bin/bash
#
# Sets up Hashicorp Vault AWS backend.
# The script expects the following values to be provided as environment variables:
#
# export VAULT_ADDR='http://192.168.100.4:8200'
# export VAULT_TOKEN='1234'
# export AWS_PROFILES='therasec-stage therasec-prod'
# export VAULT_IAM_USER_NAME='vault-iam'
# export AWS_ROLES_TO_ONBOARD='ec2admin'
# export GITHUB_TEAM='admins'
# export GITHUB_ORG='therasec'
#

set -x

echo "Enable GitHub"
vault auth-enable github
vault write auth/github/config organization=${GITHUB_ORG}

set -e

for env in $AWS_PROFILES
do
    AWS_PROFILE=$env
    export AWS_PROFILE=${AWS_PROFILE}
    echo "Get AWS IAM access keys for Vault IAM user"
    set +e
    aws iam delete-access-key --user-name vault-iam --access-key-id $(aws iam list-access-keys --user-name $VAULT_IAM_USER_NAME | jq -r '.AccessKeyMetadata[0].AccessKeyId')
    set -e
    set +x
    KEYS=$(aws iam create-access-key --user-name $VAULT_IAM_USER_NAME)
    set -x

    echo "Mount AWS backend and Vault IAM role"
    set +e
    vault mount -path=aws/${AWS_PROFILE} aws
    set -e
    vault write aws/${AWS_PROFILE}/config/root \
        access_key=$(echo $KEYS | jq -r '.AccessKey.AccessKeyId') \
        secret_key=$(echo $KEYS | jq -r '.AccessKey.SecretAccessKey') \
        region=us-east-1

    for role in $AWS_ROLES_TO_ONBOARD
    do
        echo "Create $role role"
        vault write aws/${AWS_PROFILE}/roles/${role} \
            arn=$(aws iam list-roles | jq -r --arg ROLE "$role" '.Roles[] | select(.RoleName==$ROLE) | .Arn')

        echo "Creating policy aws-sts-${role}"
        POLICY=$(vault policies aws-sts-${role})
        POLICY="$POLICY
path \"aws/${AWS_PROFILE}/sts/${role}\" {
            capabilities = [\"read\"]
        }"
        echo "$POLICY" | vault policy-write aws-sts-${role} -
    done
done

echo "Adding policies to GitHub team: ${GITHUB_TEAM}"
POLICIES=""
for role in $AWS_ROLES_TO_ONBOARD
do
    POLICIES="aws-sts-${role},${POLICIES}"
done
vault write auth/github/map/teams/admins value=${POLICIES}

echo "Enabling secret backend"
vault mount -path=concourse generic
