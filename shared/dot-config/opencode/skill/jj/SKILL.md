---
name: jj
description: Jujutsu (jj) version control command reference and workflow patterns
---

## Overview

This project uses jj (Jujutsu) colocated with git. All version control
operations MUST use jj commands. Never use git directly.

Mental model: unlike git, jj has no staging area and no "uncommitted
changes". The working copy IS a commit (`@`) that jj snapshots automatically
at the start of every command. You amend/squash work into changesets rather
than committing on top, so history is rewritten freely and `jj undo` covers
mistakes.

## Discovering Commands and Syntax

jj evolves quickly — prefer checking built-in help over assuming flags:
- `jj help` — command overview
- `jj <command> --help` — full usage; always check before using unfamiliar flags
- `jj help -k <keyword>` — search help topics (e.g. `jj help -k revsets`,
  `jj help -k templates`)
- `jj config list` / `jj config get <key>` — inspect effective config
- Official docs: https://docs.jj-vcs.dev

## Command Reference

### Inspecting State
- `jj status` - working copy changes
- `jj log` - changeset history (graph view)
- `jj log -r 'all()'` - all changesets
- `jj diff` - diff of current changeset
- `jj diff -r <rev>` - diff of a specific changeset
- `jj show <rev>` - show a changeset's diff and description

### Creating and Organizing Changes
- `jj new` - start a new empty changeset on top of current
- `jj new <rev>` - start a new changeset on top of a specific revision
- `jj describe -m "message"` - set description on current changeset
- `jj commit -m "message"` - finalize current change, start new empty one
- `jj edit <rev>` - switch working copy to an existing changeset
- `jj squash` - fold current changeset into parent
- `jj squash --into <rev>` - fold current changeset into a specific revision
- `jj split` - interactively split current changeset into two
- `jj abandon <rev>` - discard a changeset

### Revsets (addressing changesets)
- `@` - the current working-copy commit
- `<workspace-name>@` - the working-copy commit of a named workspace
- Ranges, ancestors/descendants, and functions like `all()` exist — see
  `jj help -k revsets`

### Bookmarks (Branches)
- `jj bookmark list` - list bookmarks
- `jj bookmark create <name>` - create bookmark at current changeset
- `jj bookmark set <name>` - move bookmark to current changeset

### Workspaces (multiple working copies)
Workspaces are additional working copies attached to the same repo (like git
worktrees). Common uses: run a slow build or test in one workspace while
editing in another, or work on two independent changes in parallel. Each
workspace has its own working-copy commit, shown as `<name>@` in `jj log`,
and its own sparse patterns.

- `jj workspace add <destination>` - create a workspace (see `--help` for
  naming, parent revision, description, sparse-pattern, and colocate options)
- `jj workspace list` - list workspaces, their paths, and working-copy commits
- `jj workspace root [--name <n>]` - print a workspace's root directory
- `jj workspace rename <new>` - rename the current workspace
- `jj workspace update-stale` - resync a workspace whose working copy went
  stale (e.g. another workspace rewrote commits it was based on). jj will
  prompt you when this is needed — run it from inside the stale workspace.
- `jj workspace remove <name>` - delete a workspace AND its files from disk
  (state is snapshotted first; the main workspace can't be removed)
- `jj workspace forget [names]` - DANGEROUS: stops tracking a workspace
  WITHOUT touching its files, and with no arguments forgets the CURRENT
  workspace. Prefer `remove` unless you specifically want the files left
  behind untracked.

In colocated repos, each workspace may get a corresponding git worktree —
check `jj workspace add --help` for the colocate flags.

### Conflict Resolution
- `jj status` will show conflicts
- Edit conflicted files, then `jj resolve` or just mark resolved

### Undo and the Operation Log
Nearly every mistake is reversible because jj records all repo changes as
operations:
- `jj undo` - undo the last jj operation
- `jj op log` - view operation history; find the op ID from just before a
  mistake, and inspect repo state at any operation with `--at-op`
- `jj op restore <op>` - restore the repo to its state at an earlier operation

## Forbidden Operations

NEVER run any of these:
- `jj git push` / `jj git fetch` / `jj git import` / `jj git export`
- Any direct `git` command

The user manages all remote synchronization.

## Changeset Conventions

- One changeset per logical unit of work
- Prefer small, focused changesets over large changes
- Use `jj squash` to consolidate related small changes

