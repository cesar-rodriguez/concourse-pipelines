#!/bin/sh
#
# Verify if terraform templates are formatted
#

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'

cd infrastructure-repo

# Check if code is properly formatted
format_status=$(terraform fmt | wc -l)
if [ $format_status -gt 0 ]
then
    echo -e "${RED}[SCAN] failed: Templates are not formatted. Please run 'terraform fmt'"
    exit 1
else
    echo -e "${GREEN}[SCAN] successful"
    exit 0
fi
