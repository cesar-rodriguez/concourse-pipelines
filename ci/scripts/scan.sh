#!/bin/sh
#
# Script for producing terraform plan file.
#

set -eux

cd infrastructure-repo

# "Scanning" terraform
for env in $(ls environments | grep '.tfvars')
do
  tflint --error-with-issues --fast --var-file=environments/$env
done
