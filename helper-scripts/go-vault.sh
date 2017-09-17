#!/bin/sh

set -ex

VAULT_ADDR='192.168.100.4:8200'
VAULT_TOKEN='1234'

echo "Starting dev Vault instance..."
vault server -dev -dev-root-token-id=${VAULT_TOKEN} -dev-listen-address=${VAULT_ADDR} &>/dev/null &

echo "Authenticating to Vault..."
export VAULT_ADDR=http://${VAULT_ADDR}
vault auth ${VAULT_TOKEN}

echo "Setting up vault policies..."
echo "path \"/concourse/*\" {
        capabilities = [\"read\"]
    }" | vault policy-write concourse -

echo "Enabling Approle..."
vault auth-enable approle
vault write auth/approle/role/concourse bind_cidr_list=192.168.0.0/16,127.0.0.1/32 policies=concourse token_num_uses=0 token_ttl=720h secret_id_ttl=24h

echo "Get AppRole"
ROLE_ID=$( vault read -format=json auth/approle/role/concourse/role-id | jq -r .data.role_id )
SECRET_ID=$( vault write -format=json -f auth/approle/role/concourse/secret-id | jq -r .data.secret_id )

echo "Configuring concourse-web service"
sudo service concourse-web stop
echo "start on runlevel [2345]
stop on shutdown

exec concourse web \
  --no-really-i-dont-want-any-auth \
  --external-url http://192.168.100.4:8080 \
  --session-signing-key /opt/concourse/session_signing_key \
  --tsa-host-key /opt/concourse/host_key \
  --tsa-authorized-keys /opt/concourse/authorized_worker_keys \
  --postgres-data-source postgres://vagrant:vagrant@127.0.0.1:5432/atc?sslmode=disable \
  --vault-url http://192.168.100.4:8200 \
  --vault-auth-backend approle \
  --vault-auth-param role_id=${ROLE_ID} \
  --vault-auth-param secret_id=${SECRET_ID}" > /etc/init/concourse-web.conf
sudo service concourse-web start
