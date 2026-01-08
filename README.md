# asdf-node

[![Build](https://github.com/thphuong/asdf-node/actions/workflows/build.yml/badge.svg)](https://github.com/thphuong/asdf-node/actions/workflows/build.yml) [![Lint](https://github.com/thphuong/asdf-node/actions/workflows/lint.yml/badge.svg)](https://github.com/thphuong/asdf-node/actions/workflows/lint.yml)

Node.js plugin for the [asdf version manager](https://asdf-vm.com) which uses [n](https://github.com/tj/n) to install.

## Dependencies

- `bash`, `curl`, `tar`, and [POSIX utilities](https://pubs.opengroup.org/onlinepubs/9699919799/idx/utilities.html).

## Install

```sh
asdf plugin add node https://github.com/thphuong/asdf-node.git
```

## Use

```sh
# Show all installable versions
asdf list-all node

# Install specific version
asdf install node latest

# Set a version globally (on your ~/.tool-versions file)
asdf global node latest

# Now node commands are available
node --version
```

Check [asdf](https://github.com/asdf-vm/asdf) readme for more instructions on how to
install & manage versions.

## Global Package Installation

### Isolated Global Packages

This plugin provides isolation for global packages installed via npm, pnpm, and yarn. Each Node.js version managed by asdf will have its own isolated global package directory, preventing conflicts between different Node.js versions.

Global packages are stored in:

- npm: `$ASDF_INSTALL_PATH/libexec/npm`
- pnpm: `$ASDF_INSTALL_PATH/libexec/pnpm`
- yarn: `$ASDF_INSTALL_PATH/libexec/yarn`

After installing global packages with `npm install -g`, `pnpm add -g`, or `yarn global add`, run `asdf reshim node` to make them accessible in your command line.

### Default Global Packages

You can specify default packages to be automatically installed whenever you install a new Node.js version. Create one or more of these files in your home directory:

- `~/.npm-default-packages` - packages to install with npm
- `~/.pnpm-default-packages` - packages to install with pnpm
- `~/.yarn-default-packages` - packages to install with yarn

Each file should contain one package name per line. Lines starting with `#` are treated as comments.

**Package Syntax:**

- Basic package: `typescript`
- Specific version: `eslint@8.50.0`
- Latest version: `prettier@latest`

**Global Mode:**
Packages marked with `#mode:global` will be installed in a shared location that persists across all Node.js versions. This is useful for tools you want available globally regardless of the Node.js version.

Example `~/.npm-default-packages`:

```text
# Development tools (version-specific)
typescript@latest
eslint
prettier

# System tools (shared across all Node.js versions)
npm-check-updates #mode:global
serve #mode:global
```

The packages will be automatically installed when you run `asdf install node <version>`.

To manually install default packages for the current Node.js version:

```sh
asdf node install-default-packages
```
