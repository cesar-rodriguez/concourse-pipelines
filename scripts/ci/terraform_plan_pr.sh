#!/bin/sh
#
# Produces terraform plan file.
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

RED='\033[0;31m'

# Get AWS credentials
mkdir -p ~/.aws
cp aws-creds/credentials ~/.aws/credentials

WORK_DIR=$(pwd)

# "Building" terraform
errors=0
for env in $(ls infrastructure-repo/environments | grep '.tfvars' | cut -d '.' -f 1)
do
    echo "****************** BUILDING $env ******************"
    cp -R infrastructure-repo terraform-plan-out/$env
    cd terraform-plan-out/$env

    echo "BUILDING $env: terraform init"
    terraform init -input=false -backend-config=environments/$env.tf
    echo

    touch tfplan.txt
    set +e
    terraform plan -detailed-exitcode -out=tfplan -input=false -var-file=environments/$env.tfvars > tfplan.txt
    planexit=$?
    terraform plan -detailed-exitcode -no-color -input=false -var-file=environments/$env.tfvars > tfplan-nc.txt
    set -e
    if [ $planexit -eq 0 ]
    then
        echo "BUILDING $env: terraform plan <no changes>\n\n"
        cd ../
        rm -rf $env
        cd ../
        echo
        echo
    elif [ $planexit -eq 1 ]
    then
        echo "BUILDING $env: terraform plan <error>"
        cat tfplan.txt
        echo "#ERROR in \`terraform plan\` for environment: $env" >> ${WORK_DIR}/pull-request-comment/comment
        cat tfplan-nc.txt >> ${WORK_DIR}/pull-request-comment/comment
        errors=1
        cd ../../
        echo
        echo
    else
        echo "BUILDING $env: terraform plan <diff>"
        cat tfplan.txt
        echo "#`terraform plan` output for environment: $env" >> ${WORK_DIR}/pull-request-comment/comment
        cat tfplan-nc.txt >> ${WORK_DIR}/pull-request-comment/comment
        cd ../../
        echo
        echo
    fi
done

# The build fails if there are no changes in any environment
no_changes=$(ls terraform-plan-out | wc -l)
if [ $no_changes -eq 0 ]
then
    echo -e "${RED}There are no changes in any environment"
    exit 1
fi

exit $errors
