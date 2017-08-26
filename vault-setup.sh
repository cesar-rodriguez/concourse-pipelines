#!/bin/sh
#
# Sets up a dev version of vault with app role and aws backend
#
#

set -ex

echo "Starting dev Vault instance"
VAULT_ADDR_NO_PROTOCOL='192.168.100.1:8200'
VAULT_ADDR='http://192.168.100.1:8200'
VAULT_TOKEN='1234'
vault server -dev -dev-root-token-id=${VAULT_TOKEN} -dev-listen-address=${VAULT_ADDR_NO_PROTOCOL} &>/dev/null &

echo "Authenticating to Vault"
export VAULT_ADDR=${VAULT_ADDR}
vault auth ${VAULT_TOKEN}

echo "Get AWS IAM access keys for Vault"
set +e
aws iam delete-access-key --user-name vault-iam --access-key-id $(aws iam list-access-keys --user-name vault-iam | jq -r '.AccessKeyMetadata[0].AccessKeyId')
set -e
KEYS=$(aws iam create-access-key --user-name vault-iam)

echo "Mount AWS backend and demo role"
vault mount -path=aws/therasecaws aws
vault write aws/therasecaws/config/root \
    access_key=$(echo $KEYS | jq -r '.AccessKey.AccessKeyId') \
    secret_key=$(echo $KEYS | jq -r '.AccessKey.SecretAccessKey') \
    region=us-east-1

echo "Create demo role"
vault write aws/therasecaws/roles/aws-global-admin \
    arn=arn:aws:iam::445730574438:role/adfs-admin
echo 'path "aws/therasecaws/sts/aws-global-admin"{
    capabilities = ["read"]
}' | vault policy-write aws-sts-therasecaws-admin -

echo "Enable Approle"
vault auth-enable approle
vault write auth/approle/role/awspipelinerole bind_cidr_list=192.168.0.0/16,127.0.0.1/32 policies=aws-sts-therasecaws-admin token_num_uses=0 token_ttl=24h token_max_ttl=720h secret_id_ttl=24h

echo "Retrieving approle"
vault read auth/approle/role/awspipelinerole/role-id
vault write -f auth/approle/role/awspipelinerole/secret-id
