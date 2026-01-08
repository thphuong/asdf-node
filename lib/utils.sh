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

# Parse package list file and output packages matching the specified mode
# Usage: parse_packages <file_path> <mode>
# mode: "isolated" for version-specific packages, "global" for #mode:global packages
parse_packages() {
	local file="$1"
	local filter_mode="$2"

	[ ! -f "$file" ] && return 0

	while IFS= read -r line || [ -n "$line" ]; do
		# Skip empty lines and comment-only lines
		[[ -z "$line" || "$line" =~ ^[[:space:]]*# ]] && continue

		# Parse package and check for #mode:global
		local package mode=""
		if [[ "$line" =~ ^([^#]+)#mode:global ]]; then
			package="${BASH_REMATCH[1]}"
			package="${package%"${package##*[![:space:]]}"}" # trim trailing whitespace
			mode="global"
		else
			package="${line%%#*}" # Remove any comments
			package="${package%"${package##*[![:space:]]}"}" # trim trailing whitespace
			mode="isolated"
		fi

		# Skip if package is empty or doesn't match the filter
		[[ -z "$package" ]] && continue
		[[ "$mode" != "$filter_mode" ]] && continue

		echo "$package"
	done < "$file"
}

install_default_packages() {
	# Ensure node is in PATH for package managers (they use #!/usr/bin/env node)
	export PATH="${ASDF_INSTALL_PATH}/bin:$PATH"

	# Set up environment for isolated global package installations
	export NPM_CONFIG_PREFIX="${ASDF_INSTALL_PATH}/libexec/npm"
	export PNPM_HOME="${ASDF_INSTALL_PATH}/libexec/pnpm"
	export YARN_GLOBAL_FOLDER="${ASDF_INSTALL_PATH}/libexec/yarn"

	# Default global paths for #mode:global packages (user's normal global install locations)
	local user_npm_prefix="${NPM_PREFIX:-${HOME}/.npm-global}"
	local user_pnpm_home="${PNPM_HOME_OVERRIDE:-${HOME}/.local/share/pnpm}"
	local user_yarn_folder="${YARN_GLOBAL_FOLDER_OVERRIDE:-${HOME}/.yarn}"

	local npm_packages="${HOME}/.npm-default-packages"
	local pnpm_packages="${HOME}/.pnpm-default-packages"
	local yarn_packages="${HOME}/.yarn-default-packages"

	# Install npm packages
	if [ -f "$npm_packages" ]; then
		# Install isolated packages
		local packages
		packages=$(parse_packages "$npm_packages" "isolated")
		if [ -n "$packages" ]; then
			echo "Installing default npm packages..."
			# shellcheck disable=SC2086
			"$ASDF_INSTALL_PATH/bin/npm" install -g $packages || echo "Failed to install some npm packages"
		fi

		# Install global packages
		packages=$(parse_packages "$npm_packages" "global")
		if [ -n "$packages" ]; then
			echo "⚠️  Warning: Global npm packages will be installed to $user_npm_prefix"
			echo "   Make sure $user_npm_prefix/bin is in your PATH"
			echo "Installing npm packages (global)..."
			# shellcheck disable=SC2086
			(NPM_CONFIG_PREFIX="$user_npm_prefix" PATH="$user_npm_prefix/bin:$PATH" "$ASDF_INSTALL_PATH/bin/npm" install -g $packages) || echo "Failed to install some global npm packages"
		fi
	fi

	# Install pnpm packages
	if [ -f "$pnpm_packages" ]; then
		# Install isolated packages
		local packages
		packages=$(parse_packages "$pnpm_packages" "isolated")
		if [ -n "$packages" ]; then
			echo "Installing default pnpm packages..."
			mkdir -p "${ASDF_INSTALL_PATH}/libexec/pnpm"
			# shellcheck disable=SC2086
			PATH="${ASDF_INSTALL_PATH}/libexec/pnpm:$PATH" "$ASDF_INSTALL_PATH/bin/pnpm" add -g $packages 2>&1 || echo "Failed to install some pnpm packages"
		fi

		# Install global packages
		packages=$(parse_packages "$pnpm_packages" "global")
		if [ -n "$packages" ]; then
			echo "⚠️  Warning: Global pnpm packages will be installed to $user_pnpm_home"
			echo "   Make sure $user_pnpm_home is in your PATH"
			echo "Installing pnpm packages (global)..."
			mkdir -p "$user_pnpm_home"
			# shellcheck disable=SC2086
			PNPM_HOME="$user_pnpm_home" PATH="$user_pnpm_home:$PATH" "$ASDF_INSTALL_PATH/bin/pnpm" add -g $packages 2>&1 | grep -v "is not in PATH" || echo "Failed to install some global pnpm packages"
		fi
	fi

	# Install yarn packages
	if [ -f "$yarn_packages" ]; then
		# Install isolated packages
		local packages
		packages=$(parse_packages "$yarn_packages" "isolated")
		if [ -n "$packages" ]; then
			echo "Installing default yarn packages..."
			# shellcheck disable=SC2086
			"$ASDF_INSTALL_PATH/bin/yarn" global add $packages || echo "Failed to install some yarn packages"
		fi

		# Install global packages
		packages=$(parse_packages "$yarn_packages" "global")
		if [ -n "$packages" ]; then
			echo "⚠️  Warning: Global yarn packages will be installed to $user_yarn_folder"
			echo "   Make sure $user_yarn_folder/bin is in your PATH"
			echo "Installing yarn packages (global)..."
			# shellcheck disable=SC2086
			(YARN_GLOBAL_FOLDER="$user_yarn_folder" PATH="$user_yarn_folder/bin:$PATH" "$ASDF_INSTALL_PATH/bin/yarn" global add $packages) || echo "Failed to install some global yarn packages"
		fi
	fi
}
