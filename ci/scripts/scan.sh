#!/bin/sh
#
# Runs tflint against code
#

set -eux

cd infrastructure-repo

# "Scanning" terraform
for env in $(ls environments | grep '.tfvars')
do
    echo "****************** SCANNING $env ******************"
    tflint --error-with-issues --fast --var-file=environments/$env
done
