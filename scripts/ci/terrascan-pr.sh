#!/bin/sh
#
# Installs and runs terrascan against infrastructure repository
# Saves output to pull-request directory
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

echo "Installing terrascan..."
git clone https://github.com/therasec/terrascan.git
cd terrascan
pip install -r requirements.txt

echo "Configuring terrascan..."
echo "TERRAFORM_LOCATION = \"../../pull-request\"" > terrascan/settings.py

echo "Running terrascan..."
python -m unittest 2>&1 | tee ../pull-request-comment/comment | grep "FAILED"

# Exit 1 if unit test contains FAILED in it's output
if [ $? -eq 0 ]; then
    exit 1
fi
