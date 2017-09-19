#!/bin/sh
#
# Creates version branch
# Used for Concourse CI semver resource
#

git checkout --orphan version
git rm --cached -r .
rm -rf *
rm .gitignore .gitmodules
touch README.md
git add .
git commit -m "new branch"
git push origin version
