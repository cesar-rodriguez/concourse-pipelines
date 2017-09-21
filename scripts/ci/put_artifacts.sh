#!/bin/sh
#
# Places terraform artifacts in s3
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

ls terraform-plan-out
aws s3 ls --profile therasec-stage
