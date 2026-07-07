#!/bin/env bash
set -euo pipefail

STOW_VERSION="2.4.1"
STOW_URL="https://ftp.gnu.org/gnu/stow/stow-${STOW_VERSION}.tar.gz"

NU_VERSION="0.113.1"

JJ_VERSION="0.40.0"

ZOXIDE_VERSION="0.10.0"
ATUIN_VERSION="18.16.1"

NVIM_VERSION="0.12.1"

SESH_VERSION="2.26.2"

CARAPACE_VERSION="1.7.3"

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

install_nushell() {
	# Skip if the desired version is already installed
	if command -v nu >/dev/null 2>&1 && nu --version | grep -q "$NU_VERSION"; then
		echo "nushell $NU_VERSION already installed"
		return
	fi

	# Map uname arch to nushell release target triple
	local arch target
	arch="$(uname -m)"
	case "$arch" in
		x86_64) target="x86_64-unknown-linux-gnu" ;;
		aarch64 | arm64) target="aarch64-unknown-linux-gnu" ;;
		*)
			echo "Unsupported architecture for nushell: $arch" >&2
			return 1
			;;
	esac

	local url="https://github.com/nushell/nushell/releases/download/${NU_VERSION}/nu-${NU_VERSION}-${target}.tar.gz"

	local tmpdir
	tmpdir="$(mktemp -d)"
	trap 'rm -rf "$tmpdir"' RETURN

	echo "Downloading nushell $NU_VERSION..."
	curl -fsSL "$url" -o "$tmpdir/nu.tar.gz"

	echo "Extracting..."
	tar -xzf "$tmpdir/nu.tar.gz" -C "$tmpdir"

	echo "Installing nushell binaries to /usr/local/bin..."
	# The tarball extracts into a directory containing nu and its plugins
	find "$tmpdir" -maxdepth 2 -type f -name 'nu*' -exec sudo install -m 755 {} /usr/local/bin/ \;

	echo "nushell $(nu --version) installed"
}

install_jujutsu() {
	# Skip if the desired version is already installed
	if command -v jj >/dev/null 2>&1 && jj --version | grep -q "$JJ_VERSION"; then
		echo "jujutsu $JJ_VERSION already installed"
		return
	fi

	# Map uname arch to jj release target triple
	local arch target
	arch="$(uname -m)"
	case "$arch" in
		x86_64) target="x86_64-unknown-linux-musl" ;;
		aarch64 | arm64) target="aarch64-unknown-linux-musl" ;;
		*)
			echo "Unsupported architecture for jujutsu: $arch" >&2
			return 1
			;;
	esac

	local url="https://github.com/jj-vcs/jj/releases/download/v${JJ_VERSION}/jj-v${JJ_VERSION}-${target}.tar.gz"

	local tmpdir
	tmpdir="$(mktemp -d)"
	trap 'rm -rf "$tmpdir"' RETURN

	echo "Downloading jujutsu $JJ_VERSION..."
	curl -fsSL "$url" -o "$tmpdir/jj.tar.gz"

	echo "Extracting..."
	tar -xzf "$tmpdir/jj.tar.gz" -C "$tmpdir"

	echo "Installing jj to /usr/local/bin..."
	sudo install -m 755 "$tmpdir/jj" /usr/local/bin/jj

	echo "jujutsu $(jj --version) installed"
}

install_zoxide() {
	# Skip if the desired version is already installed
	if command -v zoxide >/dev/null 2>&1 && zoxide --version | grep -q "$ZOXIDE_VERSION"; then
		echo "zoxide $ZOXIDE_VERSION already installed"
		return
	fi

	# Map uname arch to zoxide release target triple
	local arch target
	arch="$(uname -m)"
	case "$arch" in
		x86_64) target="x86_64-unknown-linux-musl" ;;
		aarch64 | arm64) target="aarch64-unknown-linux-musl" ;;
		*)
			echo "Unsupported architecture for zoxide: $arch" >&2
			return 1
			;;
	esac

	local url="https://github.com/ajeetdsouza/zoxide/releases/download/v${ZOXIDE_VERSION}/zoxide-${ZOXIDE_VERSION}-${target}.tar.gz"

	local tmpdir
	tmpdir="$(mktemp -d)"
	trap 'rm -rf "$tmpdir"' RETURN

	echo "Downloading zoxide $ZOXIDE_VERSION..."
	curl -fsSL "$url" -o "$tmpdir/zoxide.tar.gz"

	echo "Extracting..."
	tar -xzf "$tmpdir/zoxide.tar.gz" -C "$tmpdir"

	echo "Installing zoxide to /usr/local/bin..."
	sudo install -m 755 "$tmpdir/zoxide" /usr/local/bin/zoxide

	echo "zoxide $(zoxide --version) installed"
}

install_atuin() {
	# Skip if the desired version is already installed
	if command -v atuin >/dev/null 2>&1 && atuin --version | grep -q "$ATUIN_VERSION"; then
		echo "atuin $ATUIN_VERSION already installed"
		return
	fi

	# Map uname arch to atuin release target triple
	local arch target
	arch="$(uname -m)"
	case "$arch" in
		x86_64) target="x86_64-unknown-linux-gnu" ;;
		aarch64 | arm64) target="aarch64-unknown-linux-gnu" ;;
		*)
			echo "Unsupported architecture for atuin: $arch" >&2
			return 1
			;;
	esac

	local url="https://github.com/atuinsh/atuin/releases/download/v${ATUIN_VERSION}/atuin-${target}.tar.gz"

	local tmpdir
	tmpdir="$(mktemp -d)"
	trap 'rm -rf "$tmpdir"' RETURN

	echo "Downloading atuin $ATUIN_VERSION..."
	curl -fsSL "$url" -o "$tmpdir/atuin.tar.gz"

	echo "Extracting..."
	tar -xzf "$tmpdir/atuin.tar.gz" -C "$tmpdir"

	echo "Installing atuin to /usr/local/bin..."
	# The tarball extracts into a subdirectory containing the atuin binary
	find "$tmpdir" -type f -name atuin -exec sudo install -m 755 {} /usr/local/bin/atuin \;

	echo "atuin $(atuin --version) installed"
}

install_neovim() {
	# Skip if the desired version is already installed
	if command -v nvim >/dev/null 2>&1 && nvim --version | grep -q "v$NVIM_VERSION"; then
		echo "neovim $NVIM_VERSION already installed"
		return
	fi

	# Map uname arch to neovim release asset
	local arch asset
	arch="$(uname -m)"
	case "$arch" in
		x86_64) asset="nvim-linux-x86_64" ;;
		aarch64 | arm64) asset="nvim-linux-arm64" ;;
		*)
			echo "Unsupported architecture for neovim: $arch" >&2
			return 1
			;;
	esac

	local url="https://github.com/neovim/neovim/releases/download/v${NVIM_VERSION}/${asset}.tar.gz"

	local tmpdir
	tmpdir="$(mktemp -d)"
	trap 'rm -rf "$tmpdir"' RETURN

	echo "Downloading neovim $NVIM_VERSION..."
	curl -fsSL "$url" -o "$tmpdir/nvim.tar.gz"

	echo "Extracting..."
	tar -xzf "$tmpdir/nvim.tar.gz" -C "$tmpdir"

	echo "Installing neovim to /opt/nvim..."
	# Replace any previous install and symlink the binary onto PATH
	sudo rm -rf /opt/nvim
	sudo mv "$tmpdir/$asset" /opt/nvim
	sudo ln -sf /opt/nvim/bin/nvim /usr/local/bin/nvim

	echo "neovim $(nvim --version | head -n1) installed"
}

install_sesh() {
	# Skip if the desired version is already installed
	if command -v sesh >/dev/null 2>&1 && sesh --version | grep -q "$SESH_VERSION"; then
		echo "sesh $SESH_VERSION already installed"
		return
	fi

	# Map uname arch to sesh release asset
	local arch asset
	arch="$(uname -m)"
	case "$arch" in
		x86_64) asset="sesh_Linux_x86_64" ;;
		aarch64 | arm64) asset="sesh_Linux_arm64" ;;
		*)
			echo "Unsupported architecture for sesh: $arch" >&2
			return 1
			;;
	esac

	local url="https://github.com/joshmedeski/sesh/releases/download/v${SESH_VERSION}/${asset}.tar.gz"

	local tmpdir
	tmpdir="$(mktemp -d)"
	trap 'rm -rf "$tmpdir"' RETURN

	echo "Downloading sesh $SESH_VERSION..."
	curl -fsSL "$url" -o "$tmpdir/sesh.tar.gz"

	echo "Extracting..."
	tar -xzf "$tmpdir/sesh.tar.gz" -C "$tmpdir"

	echo "Installing sesh to /usr/local/bin..."
	sudo install -m 755 "$tmpdir/sesh" /usr/local/bin/sesh

	echo "sesh $(sesh --version) installed"
}

install_carapace() {
	# Skip if the desired version is already installed
	if command -v carapace >/dev/null 2>&1 && carapace --version | grep -q "$CARAPACE_VERSION"; then
		echo "carapace $CARAPACE_VERSION already installed"
		return
	fi

	# Map uname arch to carapace release asset
	local arch arch_name
	arch="$(uname -m)"
	case "$arch" in
		x86_64) arch_name="amd64" ;;
		aarch64 | arm64) arch_name="arm64" ;;
		*)
			echo "Unsupported architecture for carapace: $arch" >&2
			return 1
			;;
	esac

	local asset="carapace-bin_${CARAPACE_VERSION}_linux_${arch_name}"
	local url="https://github.com/carapace-sh/carapace-bin/releases/download/v${CARAPACE_VERSION}/${asset}.tar.gz"

	local tmpdir
	tmpdir="$(mktemp -d)"
	trap 'rm -rf "$tmpdir"' RETURN

	echo "Downloading carapace $CARAPACE_VERSION..."
	curl -fsSL "$url" -o "$tmpdir/carapace.tar.gz"

	echo "Extracting..."
	tar -xzf "$tmpdir/carapace.tar.gz" -C "$tmpdir"

	echo "Installing carapace to /usr/local/bin..."
	sudo install -m 755 "$tmpdir/carapace" /usr/local/bin/carapace

	echo "carapace $(carapace --version) installed"
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
	local nu_path
	nu_path="$(command -v nu)"

	# Register nu as a valid login shell
	if ! grep -qx "$nu_path" /etc/shells; then
		echo "Registering $nu_path in /etc/shells..."
		echo "$nu_path" | sudo tee -a /etc/shells >/dev/null
	fi

	if [ "$(getent passwd "$USER" | cut -d: -f7)" = "$nu_path" ]; then
		echo "Default shell already set to nushell"
		return
	fi

	echo "Setting nushell as the default shell for $USER..."
	sudo chsh -s "$nu_path" "$USER"
}

install_stow
install_nushell
install_jujutsu
install_zoxide
install_atuin
install_neovim
install_sesh
install_carapace
install_tpm
set_default_shell

stow -R --dotfiles shared -t ~ --ignore=.zshrc
