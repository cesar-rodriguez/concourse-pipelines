#!/bin/sh
#
# Script for producing terraform plan file.
#

set -eu

# Formatting
cd infrastructure-repo
terraform fmt > /dev/null 2>&1
cd ../

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
    set -e
    if [ $planexit -eq 0 ]
    then
        echo "BUILDING $env: terraform plan <no changes>\n\n"
        cd ../../
        rm -rf $env
    elif [ $planexit -eq 1 ]
    then
        echo "BUILDING $env: terraform plan <error>"
        cat tfplan.txt
        echo
        echo
        errors=1
    else
        echo "BUILDING $env: terraform plan <diff>"
        cat tfplan.txt
        echo
        echo
        cd ../../
    fi
done

set -x
# Get email address of committer
`git -C infrastructure-repo --no-pager show $(git -C infrastructure-repo rev-parse HEAD) -s --format='%ae' > email-out/${OUTPUT_RECEPIENTS_FILE_NAME}`

if [ $errors -eq 0 ]
then
    # Tar built terraform plans
    tar -cvzf terraform-plan-$(cat version/number).tgz terraform-plan-out
    mv terraform-plan-$(cat version/number).tgz terraform-plan-out

    # Details for email
    echo -e "[Concourse CI] Sucessfully built \${BUILD_PIPELINE_NAME}: build \${BUILD_ID} on $(date)" > email-out/${OUTPUT_SUBJECT_FILE_NAME}
    echo -e "Sucessfully built \${BUILD_PIPELINE_NAME}: build \${BUILD_ID} on $(date)\n\n \
    Build ID: \${BUILD_ID} \n \
    Ready for review at: \${ATC_EXTERNAL_URL}/teams/main/pipelines/\${BUILD_PIPELINE_NAME}/jobs/\${BUILD_JOB_NAME}/builds/\${BUILD_NAME}" > email-out/${OUTPUT_BODY_FILE_NAME}
    exit $errors
else
    # Details for email
    echo -e "[Concourse CI] Failed build of \${BUILD_PIPELINE_NAME}: build \${BUILD_ID} on $(date)" > email-out/${OUTPUT_SUBJECT_FILE_NAME}
    echo -e "Failed build of \${BUILD_PIPELINE_NAME}: build \${BUILD_ID} on $(date)\n\n \
    Build ID: \${BUILD_ID} \n \
    Review at: \${ATC_EXTERNAL_URL}/teams/main/pipelines/\${BUILD_PIPELINE_NAME}/jobs/\${BUILD_JOB_NAME}/builds/\${BUILD_NAME}" > email-out/${OUTPUT_BODY_FILE_NAME}

    exit $errors
fi

