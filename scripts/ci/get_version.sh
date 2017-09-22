#!/bin/sh
#
# Performs terraform apply
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

echo "v$(cat version/number)" > release/tag
echo "${BUILD_PIPELINE_NAME} v$(cat version/number)" > release/name
