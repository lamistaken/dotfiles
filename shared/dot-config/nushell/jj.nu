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
  start $"($repo)/pull/new/($bookmark)"
}

def "jj rebase main" [] {
  ^jj rebase -r 'trunk().. & ~immutable()' -d 'trunk()'
  ^jj abandon -r 'trunk()..tracked_remote_bookmarks() & empty()'
}

def "jj review pr" [bookmark: string] {
  if $bookmark != "HEAD" {
    # Fetch latest changes and rebase my current work on top of main
    ^jj git fetch
    jj rebase main

    # Check out the new bookmark for the PR
    ^jj bm track $"($bookmark)@origin"
    ^jj new $bookmark
  }

  # Open a diff view between the fork point and HEAD
  let base = (^jj log --no-graph -r 'fork_point(@ | trunk())' -T 'commit_id.short()')
  ^nvim -c $"DiffviewOpen ($base)..HEAD"

  if $bookmark != "HEAD" {
    # After reviewing, clean up by forgetting the bookmark and returning to main
    ^jj bm forget $bookmark
    ^jj new main
  }
}

def "jj edit pr" [bookmark: string] {
  # Fetch latest changes and rebase my current work on top of main
  ^jj git fetch
  jj rebase main

  # Check out the new bookmark for the PR
  ^jj bm track $"($bookmark)@origin"
  ^jj new $bookmark

  # Open a diff view between the fork point and HEAD
  let base = (^jj log --no-graph -r 'fork_point(@ | trunk())' -T 'commit_id.short()')
  ^nvim -c $"DiffviewOpen ($base)..HEAD"
}
