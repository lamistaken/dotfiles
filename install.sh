#!/bin/env bash
set -euo pipefail

STOW_VERSION="2.4.1"
STOW_URL="https://ftp.gnu.org/gnu/stow/stow-${STOW_VERSION}.tar.gz"

install_stow() {
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

install_stow

stow -R --dotfiles shared -t ~
