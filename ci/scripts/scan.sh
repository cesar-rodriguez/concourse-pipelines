#!/bin/sh
#
# Runs tflint against code
#

set -e

cd infrastructure-repo

# "Scanning" terraform
for env in $(ls environments | grep '.tfvars')
do
    set -x
    echo "****************** SCANNING $env ******************"
    tflint --error-with-issues --fast --var-file=environments/$env
    set +x
done
