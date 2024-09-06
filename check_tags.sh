#!/usr/bin/env bash
# shellcheck disable=SC2129

set -ex

# if [[ -z "${GITHUB_TOKEN}" ]]; then
#   echo "Will not build because no GITHUB_TOKEN defined"
#   exit 0
# fi

APP_NAME_LC="$( echo "${APP_NAME}" | awk '{print tolower($0)}' )"

if [[ "${SHOULD_DEPLOY}" == "no" ]]; then
  ASSETS="null"
else
  GITHUB_RESPONSE=$( curl -s -H "Authorization: token ${GITHUB_TOKEN}" "https://api.github.com/repos/${ASSETS_REPOSITORY}/releases/latest" )
  LATEST_VERSION=$( echo "${GITHUB_RESPONSE}" | jq -c -r '.tag_name' )
  RECHECK_ASSETS="${SHOULD_BUILD}"

  if [[ "${LATEST_VERSION}" =~ ^([0-9]+\.[0-9]+\.[0-9]+) ]]; then
    if [[ "${MS_TAG}" != "${BASH_REMATCH[1]}" ]]; then
      echo "New VSCode version, new build"
      export SHOULD_BUILD="yes"
    elif [[ "${NEW_RELEASE}" == "true" ]]; then
      echo "New release build"
      export SHOULD_BUILD="yes"
    elif [[ "${VSCODE_QUALITY}" == "insider" ]]; then
      BODY=$( echo "${GITHUB_RESPONSE}" | jq -c -r '.body' )

      if [[ "${BODY}" =~ \[([a-z0-9]+)\] ]]; then
        if [[ "${MS_COMMIT}" != "${BASH_REMATCH[1]}" ]]; then
          echo "New VSCode Insiders version, new build"
          export SHOULD_BUILD="yes"
        fi
      fi
    fi

    if [[ "${SHOULD_BUILD}" != "yes" ]]; then
      export RELEASE_VERSION="${LATEST_VERSION}"
      echo "RELEASE_VERSION=${RELEASE_VERSION}" >> "${GITHUB_ENV}"

      echo "Switch to release version: ${RELEASE_VERSION}"

      ASSETS=$( echo "${GITHUB_RESPONSE}" | jq -c '.assets | map(.name)?' )
    elif [[ "${RECHECK_ASSETS}" == "yes" ]]; then
      export SHOULD_BUILD="no"

      ASSETS=$( echo "${GITHUB_RESPONSE}" | jq -c '.assets | map(.name)?' )
    else
      ASSETS="null"
    fi
  else
    echo "can't check assets"
    exit 1
  fi
fi

contains() {
  # add " to match the end of a string so any hashs won't be matched by mistake
  echo "${ASSETS}" | grep "${1}\""
}

# shellcheck disable=SC2153
if [[ "${CHECK_ASSETS}" == "no" ]]; then
  echo "Don't check assets, yet"
elif [[ "${ASSETS}" != "null" ]]; then
  if [[ "${IS_SPEARHEAD}" == "yes" ]]; then
    if [[ -z $( contains "${APP_NAME}-${RELEASE_VERSION}-src.tar.gz" ) || -z $( contains "${APP_NAME}-${RELEASE_VERSION}-src.zip" ) ]]; then
      echo "Building because we have no SRC"
      export SHOULD_BUILD="yes"
      export SHOULD_BUILD_SRC="yes"
    fi
  # linux
  elif [[ "${OS_NAME}" == "linux" ]]; then

    if [[ "${CHECK_ONLY_REH}" == "yes" ]]; then
      if [[ -z $( contains "${APP_NAME_LC}-reh-linux-${VSCODE_ARCH}-${RELEASE_VERSION}.tar.gz" ) ]]; then
        echo "Building on Linux ${VSCODE_ARCH} because we have no REH archive"
        export SHOULD_BUILD="yes"
      else
        echo "Already have the Linux REH ${VSCODE_ARCH} archive"
        export SHOULD_BUILD_REH="no"
      fi
    else

      # linux-riscv64
      if [[ "${VSCODE_ARCH}" == "riscv64" || "${CHECK_ALL}" == "yes" ]]; then
        export SHOULD_BUILD_DEB="no"
        export SHOULD_BUILD_RPM="no"
        export SHOULD_BUILD_APPIMAGE="no"

        if [[ -z $( contains "${APP_NAME}-linux-riscv64-${RELEASE_VERSION}.tar.gz" ) ]]; then
          echo "Building on Linux RISC-V 64 because we have no TAR"
          export SHOULD_BUILD="yes"
        else
          export SHOULD_BUILD_TAR="no"
        fi

        if [[ -z $( contains "${APP_NAME_LC}-reh-linux-riscv64-${RELEASE_VERSION}.tar.gz" ) ]]; then
          echo "Building on Linux RISC-V 64 because we have no REH archive"
          export SHOULD_BUILD="yes"
        else
          export SHOULD_BUILD_REH="no"
        fi

        if [[ "${SHOULD_BUILD}" != "yes" ]]; then
          echo "Already have all the Linux riscv64 builds"
        fi
      fi
    fi
  fi
else
  if [[ "${IS_SPEARHEAD}" == "yes" ]]; then
    export SHOULD_BUILD_SRC="yes"
  elif [[ "${OS_NAME}" == "linux" ]]; then
    if [[ "${VSCODE_ARCH}" == "ppc64le" ]]; then
      SHOULD_BUILD_DEB="no"
      SHOULD_BUILD_RPM="no"
      SHOULD_BUILD_TAR="no"
    elif [[ "${VSCODE_ARCH}" == "riscv64" ]]; then
      SHOULD_BUILD_DEB="no"
      SHOULD_BUILD_RPM="no"
    fi
    if [[ "${VSCODE_ARCH}" != "x64" ]]; then
      export SHOULD_BUILD_APPIMAGE="no"
    fi
  elif [[ "${OS_NAME}" == "windows" ]]; then
    if [[ "${VSCODE_ARCH}" == "arm64" ]]; then
      export SHOULD_BUILD_REH="no"
    fi
  fi

  echo "Release assets do not exist at all, continuing build"
  export SHOULD_BUILD="yes"
fi

if [[ -f GITHUB_ENV ]]; then
  echo "SHOULD_BUILD=${SHOULD_BUILD}" >> "${GITHUB_ENV}"
  echo "SHOULD_BUILD_APPIMAGE=${SHOULD_BUILD_APPIMAGE}" >> "${GITHUB_ENV}"
  echo "SHOULD_BUILD_DEB=${SHOULD_BUILD_DEB}" >> "${GITHUB_ENV}"
  echo "SHOULD_BUILD_DMG=${SHOULD_BUILD_DMG}" >> "${GITHUB_ENV}"
  echo "SHOULD_BUILD_EXE_SYS=${SHOULD_BUILD_EXE_SYS}" >> "${GITHUB_ENV}"
  echo "SHOULD_BUILD_EXE_USR=${SHOULD_BUILD_EXE_USR}" >> "${GITHUB_ENV}"
  echo "SHOULD_BUILD_MSI=${SHOULD_BUILD_MSI}" >> "${GITHUB_ENV}"
  echo "SHOULD_BUILD_MSI_NOUP=${SHOULD_BUILD_MSI_NOUP}" >> "${GITHUB_ENV}"
  echo "SHOULD_BUILD_REH=${SHOULD_BUILD_REH}" >> "${GITHUB_ENV}"
  echo "SHOULD_BUILD_RPM=${SHOULD_BUILD_RPM}" >> "${GITHUB_ENV}"
  echo "SHOULD_BUILD_TAR=${SHOULD_BUILD_TAR}" >> "${GITHUB_ENV}"
  echo "SHOULD_BUILD_ZIP=${SHOULD_BUILD_ZIP}" >> "${GITHUB_ENV}"
  echo "SHOULD_BUILD_SRC=${SHOULD_BUILD_SRC}" >> "${GITHUB_ENV}"
else
  echo "SHOULD_BUILD=${SHOULD_BUILD}"
  echo "SHOULD_BUILD_APPIMAGE=${SHOULD_BUILD_APPIMAGE}"
  echo "SHOULD_BUILD_DEB=${SHOULD_BUILD_DEB}"
  echo "SHOULD_BUILD_DMG=${SHOULD_BUILD_DMG}"
  echo "SHOULD_BUILD_EXE_SYS=${SHOULD_BUILD_EXE_SYS}"
  echo "SHOULD_BUILD_EXE_USR=${SHOULD_BUILD_EXE_USR}"
  echo "SHOULD_BUILD_MSI=${SHOULD_BUILD_MSI}"
  echo "SHOULD_BUILD_MSI_NOUP=${SHOULD_BUILD_MSI_NOUP}"
  echo "SHOULD_BUILD_REH=${SHOULD_BUILD_REH}"
  echo "SHOULD_BUILD_RPM=${SHOULD_BUILD_RPM}"
  echo "SHOULD_BUILD_TAR=${SHOULD_BUILD_TAR}"
  echo "SHOULD_BUILD_ZIP=${SHOULD_BUILD_ZIP}"
  echo "SHOULD_BUILD_SRC=${SHOULD_BUILD_SRC}"
fi
