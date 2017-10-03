#!/bin/sh
#
# Performs terraform apply
#

set -e

if [ ! -z ${DEBUG_MODE} ]
then
  if [ ${DEBUG_MODE} = "true" ]
  then
    echo "DEBUG MODE"
    set -x
  fi
fi

# Get AWS credentials
mkdir -p ~/.aws
cp aws-creds/credentials ~/.aws/credentials

# Provisioning infrastructure
export TF_IN_AUTOMATION="true"
tar -xzf artifacts/${BUILD_PIPELINE_NAME}-$(cat version/number).tgz
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
