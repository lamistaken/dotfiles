#!/bin/env bash

# Directory of this script, so we can call the bundled `zp` binary regardless
# of the current working directory or PATH.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Loop launcher: run this in a fresh shell to make it a persistent zmx session
# manager. Pick/create a session and attach; when you detach (ctrl+\) you drop
# straight back into the picker. Cancel the picker (Esc) to exit the launcher.
while true; do
  "$SCRIPT_DIR/zp"
  # 130 = picker cancelled (Esc / no selection); leave the launcher.
  [[ $? -eq 130 ]] && break
done
