#!/usr/bin/env bash

if [[ -e vscode ]]; then
  rm -rf vscode
fi

. get_repo.sh

echo "APP_NAME=${APP_NAME}"
echo "ASSETS_REPOSITORY=${ASSETS_REPOSITORY}"
echo "BINARY_NAME=${BINARY_NAME}"
echo "DISABLE_UPDATE=${DISABLE_UPDATE}"
echo "OS_NAME=${OS_NAME}"
echo "VERSIONS_REPOSITORY=${VERSIONS_REPOSITORY}"
echo "VSCODE_QUALITY=${VSCODE_QUALITY}"
echo "MS_TAG=${MS_TAG}"
echo "MS_COMMIT=${MS_COMMIT}"
echo "RELEASE_VERSION=${RELEASE_VERSION}"
echo "GENERATE_ASSETS=${GENERATE_ASSETS}"


. check_cron_or_pr.sh
. check_tags.sh

set -ex

. version.sh


echo "MS_COMMIT=\"${MS_COMMIT}\""
export SHOULD_BUILD_REH="no"
. build.sh
# . build.sh

find vscode -type f -not -path "*/node_modules/*" -not -path "vscode/.build/node/*" -not -path "vscode/.git/*" > vscode.txt
echo "vscode/.build/extensions/node_modules" >> vscode.txt
echo "vscode/.git" >> vscode.txt
tar -czf vscode.tar.gz -T vscode.txt
