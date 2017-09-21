#!/bin/sh
#
# Installs and runs terrascan against infrastructure repository
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
ls ../infrastructure-repo
echo "TERRAFORM_LOCATION = \"../../infrastructure-repo\"" > terrascan/settings.py

echo "Running terrascan..."
python -m unittest
