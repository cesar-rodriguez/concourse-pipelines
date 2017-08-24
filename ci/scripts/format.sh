#!/bin/sh
#
# Verify if terraform templates are formatted
#

set -eux

cd infrastructure-repo

# Check if code is properly formatted
format_status=$(terraform fmt | wc -l)
if [ $format_status -gt 0 ]
then
    echo "Scan failed as templates are not formatted. Please run 'terraform fmt'"
    exit 1
else
    exit 0
fi
