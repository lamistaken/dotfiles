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
  shell_integration: {
    # Disable the built-in OSC 2 title (hardcoded to pwd); we emit our own
    # title from the pre_prompt hook below so it can include the zmx session.
    osc2: false
  }
  completions: {
    external: {
      enable: true
      completer: $carapace_completer
    }
  }
}

$env.XDG_PICTURES_DIR = $'($env.HOME)/Pictures'

$env.PATH = ($env.PATH | prepend ($env.HOME | path join ".local/bin"))
# mise-managed tools are exposed via its shims directory. Prepending it here
# puts every mise tool on PATH for this shell and all child processes
# (nvim, opencode, bash -c tool calls, ...), which inherit it.
$env.PATH = ($env.PATH | prepend ($env.HOME | path join ".local/share/mise/shims"))

$env.EDITOR = "nvim"
$env.OPENCODE_CONFIG = ($env.HOME | path join ".config/opencode/personal.json")
$env.OPENCODE_TUI_CONFIG = ($env.HOME | path join ".config/opencode/personal-tui.json")
$env.ZP_ROOT = ($env.HOME | path join "repos")

$env.SHELL = $nu.current-exe

# Prefix the prompt with the current zmx session (if any)
let default_left_prompt = $env.PROMPT_COMMAND
$env.PROMPT_COMMAND = {||
    let base = (do $default_left_prompt)
    if 'ZMX_SESSION' in $env {
        $"(ansi magenta_bold)($env.ZMX_SESSION)(ansi reset) ($base)"
    } else {
        $base
    }
}

# Set the terminal tab title (OSC 2), including the zmx session when present.
# Replaces nushell's built-in osc2 (disabled above) which is hardcoded to pwd.
$env.config.hooks.pre_prompt = ($env.config.hooks.pre_prompt | default [] | append {||
    let dir = ($env.PWD | str replace $nu.home-dir "~")
    let title = if 'ZMX_SESSION' in $env {
        $env.ZMX_SESSION
    } else {
        $dir
    }
    print -rn $"(ansi title)($title)(char -i 0x1b)(char -i 0x5c)"
})

source ~/.local/share/atuin/init.nu
source kanagawa.nu
source jj.nu
const work_path = ($nu.default-config-dir | path join "work.nu")
source (if ($work_path | path exists) { $work_path } else { "/dev/null" })

const aws_path = ($nu.default-config-dir | path join "aws.nu")
source (if ($aws_path | path exists) { $aws_path } else { "/dev/null" })

const direnv_path = ($nu.default-config-dir | path join "direnv.nu")
source (if ($direnv_path | path exists) { $direnv_path } else { "/dev/null" })

const mise_path = ($nu.default-config-dir | path join "mise.nu")
source (if ($mise_path | path exists) { $mise_path } else { "/dev/null" })

const zmx_path = ($nu.default-config-dir | path join "zmx.nu")
source (if ($zmx_path | path exists) { $zmx_path } else { "/dev/null" })

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
