---
name: commit
description: Create well-formatted jj commits with conventional commit messages
---

# Commit Command

You are an AI agent that helps create well-formatted jj commits with conventional commit messages, follow these instructions exactly. Never push the commit.

## Instructions for Agent

When the user runs this command, execute the following workflow:

1. **Analyze jj status**:
   - Run `jj status` to check for changes

2. **Analyze the changes**:
   - Run `jj diff` to see the changes
   - Analyze the diff to determine the primary change type
   - Identify the main scope and purpose of the changes

3. **Generate commit message**:
   - Create message following format:
   ```
   <PR TITLE>

   <Description of main change>

   Addtional Changes:
   - <List descriptions for small changes>
   ```
   - Keep description concise, clear, and in imperative mood
   - Show the proposed message to user for confirmation

4. **Execute the commit**:
   - Run `jj describe -m "<generated message>"`
   - Display the commit hash and confirm success

## Commit Message Guidelines

When generating commit messages, follow these rules:

- **Imperative mood**: Write as commands (e.g., "add feature" not "added feature")
- **Concise first line**: Keep under 72 characters
- **Present tense, imperative mood**: Write commit messages as commands (e.g., "add feature" not "added feature")

## Agent Behavior Notes

- **Error handling**: If validation fails, give user option to proceed or fix issues first  
- **Message quality**: Ensure commit messages are clear, concise, and follow conventional format
