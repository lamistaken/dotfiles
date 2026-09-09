#!/bin/bash

# 1. Create a temporary file
TMP_FILE=$(mktemp)

# 2. Read the piped selection from stdin and save it to the file
cat >"$TMP_FILE"

# 3. Open in nvim with 'q' to quit, 'y'/'yy' to copy-and-quit, and remove file on exit
#    This is the only line you need to change:
tmux new-window "nvim -R -c 'nnoremap q :q<CR> | vnoremap y \"+y:q<CR> | nnoremap yy \"+yy:q<CR> | normal G' '$TMP_FILE'; rm '$TMP_FILE'"
