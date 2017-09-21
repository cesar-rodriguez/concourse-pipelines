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

# Get AWS credentials
mkdir -p ~/.aws
cp aws-creds/credentials ~/.aws/credentials

aws s3 cp terraform-plan-out/${BUILD_PIPELINE_NAME}-$(cat version/number).tgz s3://${BUCKET_NAME} --profile ${AWS_PROFILE}
