#!/bin/env bash
set -euo pipefail

# Thin bootstrap for a Coder devspace that rebuilds daily.
#
# Only $HOME persists across rebuilds, so everything here is expected to run
# fresh each day. Individual CLI tools are declared in mise
# (shared/dot-config/mise/config.toml -> ~/.config/mise/config.toml) and
# installed with `mise install`. This script only handles the pieces that are
# not "a pinned release binary": building stow, installing mise itself,
# stowing the dotfiles, cloning tpm, setting the default shell, and the
# opencode plugin deps.

STOW_VERSION="2.4.1"
STOW_URL="https://ftp.gnu.org/gnu/stow/stow-${STOW_VERSION}.tar.gz"

MISE_VERSION="2026.7.5"

MISE_BIN="$HOME/.local/bin/mise"
NU_SHIM="$HOME/.local/share/mise/shims/nu"

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"

install_stow() {
	# stow is a Perl program with no release binary, so it is not available via
	# mise's aqua/github backends and is built from source here.

	# Skip if the desired version is already installed
	if command -v stow >/dev/null 2>&1 && stow --version | grep -q "$STOW_VERSION"; then
		echo "stow $STOW_VERSION already installed"
		return
	fi

	echo "Installing build dependencies..."
	sudo apt-get update
	# stow is a Perl program; needs perl + a C toolchain for ./configure
	sudo apt-get install -y build-essential perl curl

	local tmpdir
	tmpdir="$(mktemp -d)"
	trap 'rm -rf "$tmpdir"' RETURN

	echo "Downloading stow $STOW_VERSION..."
	curl -fsSL "$STOW_URL" -o "$tmpdir/stow.tar.gz"

	echo "Extracting..."
	tar -xzf "$tmpdir/stow.tar.gz" -C "$tmpdir"

	echo "Building..."
	(
		cd "$tmpdir/stow-${STOW_VERSION}"
		./configure --prefix=/usr/local
		make
		sudo make install
	)

	echo "stow $(stow --version | head -n1) installed"
}

install_mise() {
	# Skip if the desired version is already installed
	if [ -x "$MISE_BIN" ] && "$MISE_BIN" --version | grep -q "$MISE_VERSION"; then
		echo "mise $MISE_VERSION already installed"
		return
	fi

	echo "Installing mise $MISE_VERSION..."
	# The installer honors MISE_VERSION and installs to ~/.local/bin by default.
	curl -fsSL https://mise.run | MISE_VERSION="v${MISE_VERSION}" sh

	echo "mise $("$MISE_BIN" --version) installed"
}

stow_dotfiles() {
	# Run before mise_install so the global mise config is symlinked into
	# ~/.config/mise/config.toml before `mise install` reads it.
	echo "Stowing dotfiles..."
	(cd "$REPO_DIR" && stow -R --dotfiles shared -t ~ --ignore=.zshrc)
}

mise_install() {
	# Installs every tool declared in ~/.config/mise/config.toml (checksum
	# verified via the aqua registry) and regenerates the shims directory.
	echo "Installing tools from mise config..."
	"$MISE_BIN" install
	"$MISE_BIN" reshim

	echo "mise tools installed:"
	"$MISE_BIN" ls --installed
}

install_tpm() {
	local tpm_dir="$HOME/.tmux/plugins/tpm"

	# tpm is distributed as a git repo, not a release binary
	if ! command -v git >/dev/null 2>&1; then
		echo "Installing git..."
		sudo apt-get install -y git
	fi

	if [ -d "$tpm_dir/.git" ]; then
		echo "Updating tpm..."
		git -C "$tpm_dir" pull --ff-only
		return
	fi

	echo "Cloning tpm to $tpm_dir..."
	git clone https://github.com/tmux-plugins/tpm "$tpm_dir"
}

set_default_shell() {
	# Point at the mise shim rather than a versioned install path so that
	# bumping the nushell pin doesn't require re-registering the shell.
	if [ ! -e "$NU_SHIM" ]; then
		echo "nushell shim not found at $NU_SHIM; did mise_install run?" >&2
		return 1
	fi

	# Register nu as a valid login shell
	if ! grep -qx "$NU_SHIM" /etc/shells; then
		echo "Registering $NU_SHIM in /etc/shells..."
		echo "$NU_SHIM" | sudo tee -a /etc/shells >/dev/null
	fi

	if [ "$(getent passwd "$USER" | cut -d: -f7)" = "$NU_SHIM" ]; then
		echo "Default shell already set to nushell"
		return
	fi

	echo "Setting nushell as the default shell for $USER..."
	sudo chsh -s "$NU_SHIM" "$USER"
}

install_opencode_plugin_deps() {
	# The opencode clipboard plugin imports @opencode-ai/plugin. It is stow-symlinked
	# into ~/.config/opencode/plugins, so opencode's bundler resolves the import from
	# this repo's real path. Provide node_modules at the repo root so it resolves.
	if ! command -v npm >/dev/null 2>&1; then
		echo "npm not found; skipping opencode plugin deps"
		return
	fi

	echo "Installing opencode plugin dependencies..."
	(cd "$REPO_DIR" && npm install)
}

install_stow
install_mise
stow_dotfiles
mise_install
install_tpm
set_default_shell
install_opencode_plugin_deps
