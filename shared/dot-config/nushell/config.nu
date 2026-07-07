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

$env.PATH = ($env.PATH | prepend ($env.HOME | path join ".local/bin"))

source ~/.local/share/atuin/init.nu
source kanagawa.nu
source jj.nu
const work_path = ($nu.default-config-dir | path join "work.nu")
source (if ($work_path | path exists) { $work_path } else { "/dev/null" })

const aws_path = ($nu.default-config-dir | path join "aws.nu")
source (if ($aws_path | path exists) { $aws_path } else { "/dev/null" })

const direnv_path = ($nu.default-config-dir | path join "direnv.nu")
source (if ($direnv_path | path exists) { $direnv_path } else { "/dev/null" })

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
