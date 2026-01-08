#!/usr/bin/env bash

set -euo pipefail

current_script_path=${BASH_SOURCE[0]}
plugin_dir="$(dirname "$current_script_path")/../.."

# shellcheck source=./lib/utils.sh
source "${plugin_dir}/lib/utils.sh"

echo shit

if [ -z "${ASDF_INSTALL_PATH:-}" ]; then
	fail "ASDF_INSTALL_PATH is not set. Please ensure you have a Node.js version installed."
fi

if [ ! -d "$ASDF_INSTALL_PATH/bin" ]; then
	fail "Node.js is not installed at $ASDF_INSTALL_PATH. Please install a version first with 'asdf install node <version>'."
fi

echo "Installing default packages for Node.js at $ASDF_INSTALL_PATH"
install_default_packages

if ! asdf reshim node > /dev/null 2>&1; then
	fail "Failed to recreate shims. Try running 'asdf reshim node' manually."
fi
