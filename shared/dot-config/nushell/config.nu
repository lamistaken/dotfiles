# config.nu
#
# Installed by:
# version = "0.105.1"
#
# This file is used to override default Nushell settings, define
# (or import) custom commands, or run any other startup tasks.
# See https://www.nushell.sh/book/configuration.html
#
# This file is loaded after env.nu and before login.nu
#
# You can open this file in your default editor using:
# config nu
#
# See `help config nu` for more options
#
# You can remove these comments if you want or leave
# them for future reference.

let carapace_completer = {|spans: list<string>|
    carapace $spans.0 nushell ...$spans | from json
}

$env.config = {
  completions: {
    external: {
      enable: true
      completer: $carapace_completer
    }
  }
}

$env.XDG_PICTURES_DIR = $'($env.HOME)/Pictures'

source ~/.local/share/atuin/init.nu
source kanagawa.nu
source jj.nu
source work.nu
source aws.nu
source direnv.nu

use bash-env.nu

alias vim = echo no vim
alias s = sesh connect terminal

def git-clean [] {
    git fetch -p;
    git for-each-ref --format '%(refname),%(upstream:track)' refs/heads |
    from csv --noheaders |
    rename refname upstream:track |
    where upstream:track == '[gone]' |
    get refname |
    str replace "refs/heads/" "" |
    each {|v| git branch -D $v}
}

def --wrapped cfd [...rest] {
  fd ...$rest | collect | lines | each {ls $in} | flatten
}

def gd [] {
  gh dash -c $'($env.HOME)/.config/gh-dash/global-config.yml'
}

source zoxide.nu
