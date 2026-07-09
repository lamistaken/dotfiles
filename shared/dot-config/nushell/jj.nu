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

def "jj copy desc" [] {
  let pr_link = (gh pr view (^jj log -r @ -T 'bookmarks' --no-graph) --json url | from json | get url)
  let description = (^jj show -r @ -T 'description' --no-patch)

  $"($pr_link)

```
($description)
```" | wl-copy
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
    ^jj bm track $"($bookmark)@origin"
    ^jj new $bookmark
  }

  # Open a diff view between the fork point and HEAD
  # let base = (^jj log --no-graph -r 'fork_point(@ | trunk())' -T 'commit_id.short()')
  let base = (gh api repos/{owner}/{repo}/compare/main...($bookmark) --jq '.merge_base_commit.sha')
  # let current = (gh pr view (^jj log -r @- -T 'bookmarks' --no-graph) --json commits | from json |  get commits.oid | last)
  # ^nvim -c $"DiffviewOpen ($base)..HEAD"
  ^nvim -c $"CodeDiff ($base) HEAD"

  if $bookmark != "HEAD" {
    # After reviewing, clean up by forgetting the bookmark and returning to main
    ^jj bm forget $bookmark
    ^jj new 'trunk()'
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
