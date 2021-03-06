#!/bin/sh
#
# Verify if terraform templates are formatted
#

if [ ! -z ${DEBUG_MODE} ]
then
  if [ ${DEBUG_MODE} = "true" ]
  then
    echo "DEBUG MODE"
    set -x
  fi
fi

# Checking if test is going to be performed against pull request or main repo
ls pull-request &>/dev/null
if [ $? -eq 0 ]
then
    echo "Evaluating pull-request"
    export TEST_DIR=pull-request
    cd $TEST_DIR
    echo "**FAILED** \`terraform fmt\` test on: $(git rev-parse HEAD | cut -c1-7)
Please run \`terraform fmt\`." > ../pull-request-comment/comment
    cd ../
else
    echo "Evaluating infrastructure-repo"
    export TEST_DIR=infrastructure-repo
fi

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'


cd $TEST_DIR

# Testing if code is properly formatted
format_status=$(terraform fmt | wc -l)
if [ $format_status -gt 0 ]
then
    echo -e "${RED}Failed: Templates are not formatted. Please run 'terraform fmt'"
    exit 1
else
    echo -e "${GREEN}Success! Templates are formatted."
    exit 0
fi
