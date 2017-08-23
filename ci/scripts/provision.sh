#!/bin/sh
#
# Script for producing terraform plan file.
#

set -eux

tar -xvzf infrastructure-repo-artifacts/terraform-plan-$(cat version/number).tgz
ls infrastructure-repo-artifacts
ls
