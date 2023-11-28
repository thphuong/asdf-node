#!/usr/bin/env bash

set -euo pipefail

current_script_path=${BASH_SOURCE[0]}
plugin_dir=$(dirname "$(dirname "$current_script_path")")

if [ -f "$plugin_dir/.env" ]; then
	# shellcheck source=./.env
	source "$plugin_dir/.env"
fi

N_DOWNLOAD_PATH="$plugin_dir/n"

fail() {
	echo -e "asdf-node: $*"
	exit 1
}

sort_versions() {
	sed 'h; s/[+-]/./g; s/.p\([[:digit:]]\)/.z\1/; s/$/.z/; G; s/\n/ /' |
		LC_ALL=C sort -t. -k 1,1 -k 2,2n -k 3,3n -k 4,4n -k 5,5n | awk '{print $2}'
}

n() {
	if [ "$(command -v n)" != "n" ]; then
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
