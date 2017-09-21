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

# Install terrascan
git clone https://github.com/therasec/terrascan.git
cd terrascan
pip install -r requirements.txt

# Configure terrascan
echo "TERRAFORM_LOCATION = \"../infrastructure-repo\"" > terrascan/settings.py

# Execute tests
python -m unittest
