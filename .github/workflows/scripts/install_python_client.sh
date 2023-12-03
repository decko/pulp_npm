#!/bin/bash

# WARNING: DO NOT EDIT!
#
# This file was generated by plugin_template, and is managed by it. Please use
# './plugin-template --github pulp_npm' to update this file.
#
# For more info visit https://github.com/pulp/plugin_template

set -mveuo pipefail

# make sure this script runs at the repo root
cd "$(dirname "$(realpath -e "$0")")"/../../..

source .github/workflows/scripts/utils.sh

export PULP_URL="${PULP_URL:-https://pulp}"

REPORTED_STATUS="$(pulp status)"
REPORTED_VERSION="$(echo "$REPORTED_STATUS" | jq --arg plugin "npm" -r '.versions[] | select(.component == $plugin) | .version')"
VERSION="$(echo "$REPORTED_VERSION" | python -c 'from packaging.version import Version; print(Version(input()))')"

pushd ../pulp-openapi-generator
rm -rf pulp_npm-client
./generate.sh pulp_npm python "$VERSION"
pushd pulp_npm-client
python setup.py sdist bdist_wheel --python-tag py3

twine check "dist/pulp_npm_client-$VERSION-py3-none-any.whl"
twine check "dist/pulp_npm-client-$VERSION.tar.gz"

cmd_prefix pip3 install "/root/pulp-openapi-generator/pulp_npm-client/dist/pulp_npm_client-${VERSION}-py3-none-any.whl"
tar cvf ../../pulp_npm/npm-python-client.tar ./dist

find ./docs/* -exec sed -i 's/Back to README/Back to HOME/g' {} \;
find ./docs/* -exec sed -i 's/README//g' {} \;
cp README.md docs/index.md
sed -i 's/docs\///g' docs/index.md
find ./docs/* -exec sed -i 's/\.md//g' {} \;

cat >> mkdocs.yml << DOCSYAML
---
site_name: PulpNpm Client
site_description: Npm bindings
site_author: Pulp Team
site_url: https://docs.pulpproject.org/pulp_npm_client/
repo_name: pulp/pulp_npm
repo_url: https://github.com/pulp/pulp_npm
theme: readthedocs
DOCSYAML

# Building the bindings docs
mkdocs build

tar cvf ../../pulp_npm/npm-python-client-docs.tar ./docs
popd
popd
