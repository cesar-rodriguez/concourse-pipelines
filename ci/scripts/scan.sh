#!/bin/sh
#
# Script for producing terraform plan file.
#

set -eux

cd infrastructure-repo

# Check if code is properly formatted
format_status=$(terraform fmt | wc -l)
if [ $format_status -gt 0 ]
then
    echo "Scan failed as templates are not formatted. Please run 'terraform fmt'"
    exit 1
fi

# "Scanning" terraform
for env in $(ls environments | grep '.tfvars')
do
    tflint --error-with-issues --fast --var-file=environments/$env
done
