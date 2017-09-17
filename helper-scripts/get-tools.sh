#!/bin/sh

set -ex

CONCOURSE_VERSION='v3.4.1'
VAULT_VERSION='0.8.2'

sudo apt-get update
sudo apt-get install unzip
sudo apt-get install jq

echo "Downloading Concourse..."
wget https://github.com/concourse/concourse/releases/download/${CONCOURSE_VERSION}/concourse_linux_amd64
chmod 0755 concourse_linux_amd64
sudo mv concourse_linux_amd64 /usr/local/bin/concourse

echo "Downloading Vault..."
wget https://releases.hashicorp.com/vault/${VAULT_VERSION}/vault_${VAULT_VERSION}_linux_amd64.zip
sudo unzip vault_${VAULT_VERSION}_linux_amd64.zip -d /usr/local/bin/
sudo chmod 0755 /usr/local/bin/vault
