#!/usr/bin/env bash
# shellcheck disable=SC2129

set -e

# git workaround
if [[ "${CI_BUILD}" != "no" ]]; then
  git config --global --add safe.directory "/__w/$( echo "${GITHUB_REPOSITORY}" | awk '{print tolower($0)}' )"
fi

if [[ -n "${PULL_REQUEST_ID}" ]]; then
  BRANCH_NAME=$( git rev-parse --abbrev-ref HEAD )

  git config --global user.email "$( echo "${GITHUB_USERNAME}" | awk '{print tolower($0)}' )-ci@not-real.com"
  git config --global user.name "${GITHUB_USERNAME} CI"
  git fetch --unshallow
  git fetch origin "pull/${PULL_REQUEST_ID}/head"
  git checkout FETCH_HEAD
  git merge --no-edit "origin/${BRANCH_NAME}"
fi

# Initialize Git repository
mkdir -p vscode
cd vscode || { echo "'vscode' dir not found"; exit 1; }

git init -q
git remote add origin https://gitee.com/openkylin/kylin-code

# Fetch the latest tags and commits
git fetch --tags

# Determine the latest tag and commit
LATEST_TAG=$(git tag -l | sort -V | tail -n 1)
LATEST_COMMIT=$(git rev-list -n 1 "$LATEST_TAG")

if [[ -z "${LATEST_TAG}" || -z "${LATEST_COMMIT}" ]]; then
  echo "Error: Could not determine the latest tag or commit."
  exit 1
fi

# Set environment variables
export MS_TAG="${LATEST_TAG}"
export MS_COMMIT="${LATEST_COMMIT}"

# Generate release version
date=$(date +%Y%j)
if [[ "${VSCODE_QUALITY}" == "insider" ]]; then
  RELEASE_VERSION="${MS_TAG}.${date: -5}-insider"
else
  RELEASE_VERSION="${MS_TAG}.${date: -5}"
fi

export RELEASE_VERSION

# For GH actions
if [[ "${GITHUB_ENV}" ]]; then
  echo "MS_TAG=${MS_TAG}" >> "${GITHUB_ENV}"
  echo "MS_COMMIT=${MS_COMMIT}" >> "${GITHUB_ENV}"
  echo "RELEASE_VERSION=${RELEASE_VERSION}" >> "${GITHUB_ENV}"
fi

echo "MS_TAG=\"${MS_TAG}\""
echo "MS_COMMIT=\"${MS_COMMIT}\""
echo "RELEASE_VERSION=\"${RELEASE_VERSION}\""
