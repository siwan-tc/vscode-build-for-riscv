#!/usr/bin/env bash

export APP_NAME="VSCode"
export ASSETS_REPOSITORY="siwan-tc/vscode-build-for-riscv"
export BINARY_NAME="code"
export DISABLE_UPDATE="yes"
export OS_NAME="linux"
export VERSIONS_REPOSITORY="siwan-tc/versions"
export VSCODE_QUALITY="stable"
export BUILD_SOURCEVERSION="b79341ff9131ec6057b179222fcab295e229137f"
export MS_COMMIT="89de5a8d4d6205e5b11647eb6a74844ca23d2573"
export MS_TAG="1.90.0"
export RELEASE_VERSION="1.90.0.24247"
export SHOULD_BUILD="yes"
export SHOULD_DEPLOY="no"
export VSCODE_ARCH="riscv64"
export SHOULD_BUILD_APPIMAGE="no"
export SHOULD_BUILD_DEB="no"
export SHOULD_BUILD_DMG=""
export SHOULD_BUILD_EXE_SYS=""
export SHOULD_BUILD_EXE_USR=""
export SHOULD_BUILD_MSI=""
export SHOULD_BUILD_MSI_NOUP=""
export SHOULD_BUILD_REH=""
export SHOULD_BUILD_RPM="no"
export SHOULD_BUILD_TAR=""
export SHOULD_BUILD_ZIP=""
export SHOULD_BUILD_SRC=""
export npm_config_arch="riscv64"
# export GITHUB_TOKEN="xxx"需要设置
#使用docker
#setup node.js environment 18.17.1
. check_tags.sh
#install libkrb5-dev
#下载mycompile编译好的vscode
if [[ -e vscode ]]; then
  rm -rf vscode
fi
. ./package_linux_bin.sh

