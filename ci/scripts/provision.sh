#!/bin/sh
#
# Script for producing terraform plan file.
#

set -eux

ls infrastructure-repo-artifacts
ls infrastructure-repo-artifacts/version
cat infrastructure-repo-artifacts/version/number
#tar -xvzf infrastructure-repo-artifacts/terraform-plan-$(cat version/number).tgz

