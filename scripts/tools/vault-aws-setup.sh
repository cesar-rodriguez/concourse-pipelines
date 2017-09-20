#!/bin/sh
#
# Sets up vault AWS backend
# Expects:
#   - The aws cli and vault cli to be installed
#   - AWS credentials file with 2 profiles named 'stage' and 'prod'

set -ex

# Variables
VAULT_ADDR_NO_PROTOCOL='192.168.100.4:8200'
VAULT_ADDR='http://192.168.100.4:8200'
VAULT_TOKEN='1234'
GITHUB_ORG='therasec'


echo "Authenticating to Vault"
export VAULT_ADDR=${VAULT_ADDR}
vault auth ${VAULT_TOKEN}

environments='stage prod'
for env in $environments
do
    AWS_PROFILE=$env
    export AWS_PROFILE=${AWS_PROFILE}
    echo "Get AWS IAM access keys for Vault"
    set +e
    aws iam delete-access-key --user-name vault-iam --access-key-id $(aws iam list-access-keys --user-name vault-iam | jq -r '.AccessKeyMetadata[0].AccessKeyId')
    set -e
    KEYS=$(aws iam create-access-key --user-name vault-iam)

    echo "Mount AWS backend and admin role"
    vault mount -path=aws/${AWS_PROFILE} aws
    vault write aws/${AWS_PROFILE}/config/root \
        access_key=$(echo $KEYS | jq -r '.AccessKey.AccessKeyId') \
        secret_key=$(echo $KEYS | jq -r '.AccessKey.SecretAccessKey') \
        region=us-east-1

    echo "Create admin role"
    vault write aws/${AWS_PROFILE}/roles/aws-admin \
        arn=$(aws iam list-roles | jq -r '.Roles[] | select(.RoleName=="adfs-admin") | .Arn')
    echo "path \"aws/${AWS_PROFILE}/sts/aws-admin\" {
        capabilities = [\"read\"]
    }" | vault policy-write aws-sts-therasec-${AWS_PROFILE}-admin -
done


echo "Enable Approle"
vault auth-enable approle
vault write auth/approle/role/teamconcourse bind_cidr_list=192.168.0.0/16,127.0.0.1/32 policies=aws-sts-therasec-stage-admin,aws-sts-therasec-prod-admin token_num_uses=0 token_ttl=24h token_max_ttl=720h secret_id_ttl=24h

echo "Retrieving approle"
vault read auth/approle/role/teamconcourse/role-id
vault write -f auth/approle/role/teamconcourse/secret-id
