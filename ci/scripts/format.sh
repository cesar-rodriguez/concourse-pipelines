#!/bin/sh
#
# Verify if terraform templates are formatted
#

ls pull-request &>/dev/null
if [ $? -eq 0 ]
then
    echo "Evaluating pull-request"
    export TEST_DIR=pull-request
else
    echo "Evaluating infrastructure-repo"
    export TEST_DIR=infrastructure-repo
fi

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'


cd $TEST_DIR

# Check if code is properly formatted
format_status=$(terraform fmt | wc -l)
if [ $format_status -gt 0 ]
then
    echo -e "${RED}Failed: Templates are not formatted. Please run 'terraform fmt'"
    exit 1
else
    echo -e "${GREEN}Success! Templates are formatted."
    exit 0
fi
