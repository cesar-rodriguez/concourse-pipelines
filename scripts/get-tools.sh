#!/bin/sh

set -e

CONCOURSE_VERSION='v3.4.1'
VAULT_VERSION='0.8.2'

get_vault () {
  wget https://releases.hashicorp.com/vault/${VAULT_VERSION}/vault_${VAULT_VERSION}_linux_amd64.zip \
    --progress=bar:force 2>&1 | tail -f -n +6
  sudo unzip vault_${VAULT_VERSION}_linux_amd64.zip -d /usr/local/bin/
  rm -f vault_${VAULT_VERSION}_linux_amd64.zip
  sudo chmod 0755 /usr/local/bin/vault
}

get_concourse () {
  wget https://github.com/concourse/concourse/releases/download/${CONCOURSE_VERSION}/concourse_linux_amd64 \
    --progress=bar:force 2>&1 | tail -f -n +6
  chmod 0755 concourse_linux_amd64
  sudo mv concourse_linux_amd64 /usr/local/bin/concourse
}

echo "Installing Concourse..."
SYS_CONCOURSE_VERSION=$( concourse -v )
if [ "v$SYS_CONCOURSE_VERSION" != "$CONCOURSE_VERSION" ]; then
    get_concourse
fi

echo "Installing Vault..."
which vault || get_vault


