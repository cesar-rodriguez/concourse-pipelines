Hello Vault - Pipeline
=====================
Basic pipeline used to test Concourse and Vault are configured properly. The pipeline will read a team level secret from Vault and echo it. By default, the secret should be placed at `concourse/TEAM/hello` and the pipeline will read the key named **value**.

Pre-requisites
--------------
Concourse and Vault installed and configured. Pre-populate the secret to Vault with the following Vault cli commands (assuming that the pipeline is being configured in the **main** team):

```bash
export VAULT_ADDR='http://192.168.100.4:8200'
vault mount -path=concourse/main/hello generic
vault write concourse/main/hello value=Vault
vault read concourse/main/hello
```

Pipeline Setup
--------------
You can setup the pipeline with the following commands:

```bash
fly --target lite login -c http://192.168.100.4:8080
fly --target lite set-pipeline --pipeline hello-vault --config hello.yml
fly --target lite unpause-pipeline --pipeline hello-vault
```
