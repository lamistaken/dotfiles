#!/usr/bin/env bash
# xdg-open handler for text/plain. Ghostty's write_*_file:open runs
# `xdg-open <tmp>/history.txt` (or screen.txt/selection.txt). We detect those
# dumps and open them in a read-only nvim pager (mirroring tmux-view-pane.sh),
# and fall back to a normal editable nvim for every other text file.
file="$1"
base="$(basename "$file")"
parent="$(dirname "$file")"
tmproot="${TMPDIR:-/tmp}"

is_dump=0
case "$base" in
  history.txt|screen.txt|selection.txt)
    # Ghostty dump dirs live directly under the tmp root as a random subdir.
    case "$parent" in "$tmproot"/*|/tmp/*) is_dump=1 ;; esac ;;
esac

if [ "$is_dump" = 1 ]; then
  # Read-only pager: q quits, y/yy yank-and-quit, jump to the bottom, and
  # delete the retained temp dir on exit (Ghostty retains the file for us).
  exec ghostty -e nvim -R \
    -c 'nnoremap q :q<CR>' \
    -c 'vnoremap y "+y:q<CR>' \
    -c 'nnoremap yy "+yy:q<CR>' \
    -c 'autocmd VimLeave * call delete(expand("%:p:h"), "rf")' \
    -c 'normal! G' \
    "$file"
else
  exec ghostty -e nvim "$file"
fi
