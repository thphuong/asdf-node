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

## Yarn global packages

After installing global Yarn package with `yarn global add` you need to run `asdf reshim node` for them to be accessible
in yout commandline.
