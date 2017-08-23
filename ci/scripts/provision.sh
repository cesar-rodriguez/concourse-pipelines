#!/bin/sh
#
# Script for producing terraform plan file.
#

set -eux

tar -xvzf infrastructure-repo-artifacts/terraform-plan-0.0.0-rc.8.tgz
ls infrastructure-repo-artifacts
ls

cat version/number
