#!/usr/bin/env bash

set -euo pipefail

current_script_path=${BASH_SOURCE[0]}
plugin_dir=$(dirname "$(dirname "$current_script_path")")

N_DOWNLOAD_PATH="$plugin_dir/n"

fail() {
	echo -e "asdf-node: $*"
	exit 1
}

n() {
	if [ -n "$(command -v n)" ]; then
		command n "$@"
	elif [ -n "${ASDF_NODE_N_EXECUTABLE:-}" ]; then
		"${ASDF_NODE_N_EXECUTABLE:-}" "$@"
	elif [ -x "$N_DOWNLOAD_PATH" ]; then
		"$N_DOWNLOAD_PATH" "$@"
	else
		curl -fsSL https://raw.githubusercontent.com/tj/n/master/bin/n -o "$N_DOWNLOAD_PATH"
		chmod +x "$N_DOWNLOAD_PATH"
		"$N_DOWNLOAD_PATH" "$@"
	fi
}
