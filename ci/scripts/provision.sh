#!/bin/sh
#
# Performs terraform apply
#

set -e
tar -xzf infrastructure-repo-artifacts/terraform-plan-$(cat infrastructure-repo-artifacts/version).tgz
for env in $(ls terraform-plan-out)
do
    echo "****************** PROVISIONING $env ******************"
    set -x
    cd terraform-plan-out/$env
    cat tfplan.txt
    terraform apply -input=false tfplan
    set +x
    cd ../../
done

echo "v$(cat version/number)" > release/tag
echo "terraform-pipeline v$(cat version/number)" > release/name
