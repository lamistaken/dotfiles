---
name: jj
description: Jujutsu (jj) version control command reference and workflow patterns
---

## Overview

This project uses jj (Jujutsu) colocated with git. All version control
operations MUST use jj commands. Never use git directly.

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

### Bookmarks (Branches)
- `jj bookmark list` - list bookmarks
- `jj bookmark create <name>` - create bookmark at current changeset
- `jj bookmark set <name>` - move bookmark to current changeset

### Conflict Resolution
- `jj status` will show conflicts
- Edit conflicted files, then `jj resolve` or just mark resolved

### Undo
- `jj undo` - undo the last jj operation
- `jj op log` - view operation history

## Forbidden Operations

NEVER run any of these:
- `jj git push` / `jj git fetch` / `jj git import` / `jj git export`
- Any direct `git` command

The user manages all remote synchronization.

## Changeset Conventions

- One changeset per logical unit of work
- Prefer small, focused changesets over large ones
- Use `jj squash` to consolidate related small changes
