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
#

set -x

echo "Enable Approle"
vault auth-enable approle

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

for role in $AWS_ROLES_TO_ONBOARD
do
    echo "Creating approle aws-sts-${role}"
    vault write auth/approle/role/aws-sts-${role} bind_cidr_list=192.168.0.0/16,127.0.0.1/32 policies=aws-sts-${role} token_num_uses=0 token_ttl=72h token_max_ttl=720h secret_id_ttl=72h
    echo "Retrieving authentication tokens"
    vault read auth/approle/role/aws-sts-${role}/role-id
    vault write -f auth/approle/role/aws-sts-${role}/secret-id
    echo
    echo
done
