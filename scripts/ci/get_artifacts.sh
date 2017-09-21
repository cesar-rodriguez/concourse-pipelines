#!/bin/sh
#
# Gets tar file from S3
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

# Get tar file
echo "Retrieving tar file..."
cd artifacts
aws s3 cp s3://${BUCKET_NAME}/terraform-plan-out/${BUILD_PIPELINE_NAME}-$(cat version/number).tgz . --profile ${AWS_PROFILE}
ls
