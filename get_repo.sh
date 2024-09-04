#!/usr/bin/env bash
# shellcheck disable=SC2129

set -ex

export APP_NAME="VSCode"
export ASSETS_REPOSITORY="siwan-tc/vscode-build-for-riscv"
export BINARY_NAME="code"
export DISABLE_UPDATE="yes"
export OS_NAME="linux"
export VERSIONS_REPOSITORY="siwan-tc/versions"
export VSCODE_QUALITY="stable"

# git workaround
# if [[ "${CI_BUILD}" != "no" ]]; then
#   git config --global --add safe.directory "/__w/$( echo "${GITHUB_REPOSITORY}" | awk '{print tolower($0)}' )"
# fi


if [[ -z "${RELEASE_VERSION}" ]]; then
  if [[ "${VSCODE_LATEST}" == "yes" ]] || [[ ! -f "${VSCODE_QUALITY}.json" ]]; then
    echo "Retrieve lastest version"
   # UPDATE_INFO=$( curl --silent --fail "https://update.code.visualstudio.com/api/update/darwin/${VSCODE_QUALITY}/0000000000000000000000000000000000000000" )
  else
    echo "Get version from ${VSCODE_QUALITY}.json"
    MS_COMMIT=$( jq -r '.commit' "${VSCODE_QUALITY}.json" )
    MS_TAG=$( jq -r '.tag' "${VSCODE_QUALITY}.json" )
  fi
fi
#上一步成功这步不执行
  # if [[ -z "${MS_COMMIT}" ]]; then
  #   MS_COMMIT=$( echo "${UPDATE_INFO}" | jq -r '.version' )
  #   MS_TAG=$( echo "${UPDATE_INFO}" | jq -r '.name' )

  #   if [[ "${VSCODE_QUALITY}" == "insider" ]]; then
  #     MS_TAG="${MS_TAG/\-insider/}"
  #   fi
  # fi

  date=$( date +%Y%j )

#   if [[ "${VSCODE_QUALITY}" == "insider" ]]; then
#     RELEASE_VERSION="${MS_TAG}.${date: -5}-insider"
#   else
#     RELEASE_VERSION="${MS_TAG}.${date: -5}"
#   fi
# fi

echo "RELEASE_VERSION=\"${RELEASE_VERSION}\""
# 检查 'vscode' 目录是否存在
if [ ! -d "vscode" ]; then
  echo "'vscode' 目录不存在，正在创建并执行后续操作..."
  mkdir -p vscode
  cd vscode || { echo "'vscode' dir not found"; exit 1; }

  git init -q
  git remote add origin https://github.com/Microsoft/vscode.git

# figure out latest tag by calling MS update API

  echo "MS_TAG=\"${MS_TAG}\""
  echo "MS_COMMIT=\"${MS_COMMIT}\""

  git fetch --depth 1 origin "${MS_COMMIT}"
  git checkout FETCH_HEAD

  cd ..
  else
    echo "vscode 目录已存在，跳过创建步骤"
fi
# for GH actions
if [[ "${GITHUB_ENV}" ]]; then
  echo "MS_TAG=${MS_TAG}" >> "${GITHUB_ENV}"
  echo "MS_COMMIT=${MS_COMMIT}" >> "${GITHUB_ENV}"
  echo "RELEASE_VERSION=${RELEASE_VERSION}" >> "${GITHUB_ENV}"
fi

echo "MS_TAG=${MS_TAG}"
echo "MS_COMMIT=${MS_COMMIT}"
echo "RELEASE_VERSION=${RELEASE_VERSION}"

export MS_TAG
export MS_COMMIT
export RELEASE_VERSION
