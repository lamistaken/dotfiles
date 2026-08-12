def "jj push pr" [rev: string] {
  ^jj git push -c $rev

  let repo = (
    ^jj git remote list 
    | split column " " 
    | where column0 == "origin" 
    | get column1
    | first 
    | str replace ".git" ""
  )

  let bookmark = (^jj show $rev -T 'bookmarks' --no-patch)
  let parent = (^jj show -r $"parents\(($rev)\)" -T 'bookmarks' --no-patch)

  mut pr_path = $bookmark
  if ($parent | is-not-empty) {
    $pr_path = $"($parent)...($bookmark)"
  }
  start $"($repo)/pull/new/($pr_path)?expand=1"


}

def "copy-clipboard" [text: string] {
  if ($env.WAYLAND_DISPLAY? | is-not-empty) {
    $text | wl-copy
  } else {
    # OSC 52: passes through zmx (transparent PTY) to the terminal emulator,
    # which sets the system clipboard — works locally and over SSH.
    let b64 = ($text | encode base64)
    $"\e]52;c;($b64)\e\\" | save --raw --force /dev/tty
  }
}

def "jj copy desc" [] {
  let pr_link = (gh pr view (^jj log -r @ -T 'bookmarks' --no-graph) --json url | from json | get url)
  let description = (^jj show -r @ -T 'description' --no-patch)

  copy-clipboard $"($pr_link)

```
($description)
```"
}

def "jj rebase main" [] {
  ^jj rebase -r 'trunk().. & ~immutable()' -d 'trunk()'
  ^jj abandon -r 'trunk():: & empty()'
}

def "jj review pr" [bookmark: string] {
  if $bookmark != "HEAD" {
    # Fetch latest changes and rebase my current work on top of main
    ^jj git fetch
    # jj rebase main

    # Check out the new bookmark for the PR
    ^jj bookmark track $"($bookmark)@origin"
    ^jj new $bookmark
  }

  # Open a diff view between the fork point and HEAD
  # let base = (^jj log --no-graph -r 'fork_point(@ | trunk())' -T 'commit_id.short()')
  let main = (gh pr view (^jj log -r @- -T 'bookmarks' --no-graph) --json baseRefName | from json | get baseRefName)
  let base = (gh api repos/{owner}/{repo}/compare/($main)...($bookmark) --jq '.merge_base_commit.sha')
  # let current = (gh pr view (^jj log -r @- -T 'bookmarks' --no-graph) --json commits | from json |  get commits.oid | last)
  # ^nvim -c $"DiffviewOpen ($base)..HEAD"
  ^nvim -c $"CodeDiff ($base)..."

  if $bookmark != "HEAD" {
    # After reviewing, clean up by forgetting the bookmark and returning to main
    ^jj bookmark forget $bookmark
    ^jj new 'trunk()'
  }
}

def "jj review pr2" [bookmark: string] {
  # Fetch latest changes and check out the new bookmark for the PR
  ^jj git fetch
  ^jj bookmark track $"($bookmark)@origin"
  ^jj new $bookmark

  # Open a diff view between the fork point and the PR bookmark
  let main = (gh pr view (^jj log -r @- -T 'bookmarks' --no-graph) --json baseRefName | from json | get baseRefName)
  let base = (gh api repos/{owner}/{repo}/compare/($main)...($bookmark) --jq '.merge_base_commit.sha')
  ^nvim -c $"DiffBanditReview ($base) ($bookmark)"

  # After reviewing, clean up by forgetting the bookmark and returning to main
  ^jj bookmark forget $bookmark
  ^jj new 'trunk()'
}

def "jj edit pr" [bookmark: string] {
  # Fetch latest changes and rebase my current work on top of main
  ^jj git fetch
  jj rebase main

  # Check out the new bookmark for the PR
  ^jj bookmark track $"($bookmark)@origin"
  ^jj new $bookmark

  # Open a diff view between the fork point and HEAD
  let base = (^jj log --no-graph -r 'fork_point(@ | trunk())' -T 'commit_id.short()')
  ^nvim -c $"DiffviewOpen ($base)..HEAD"
}
