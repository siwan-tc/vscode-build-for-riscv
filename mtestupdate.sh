set -e

# include common functions
. ./utils.sh

# if [[ "${VSCODE_QUALITY}" == "insider" ]]; then
#   cp -rp src/insider/* vscode/
# else
#   cp -rp src/stable/* vscode/
# fi

cp -f LICENSE vscode/LICENSE.txt

cd vscode || { echo "'vscode' dir not found"; exit 1; }

../update_settings.sh
