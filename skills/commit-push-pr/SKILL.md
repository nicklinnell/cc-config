---
name: commit-push-pr
description: Commit staged changes, push, and open a PR
model: haiku
disable-model-invocation: true
allowed-tools: Bash(git diff:*), Bash(git status:*), Bash(git log:*), Bash(git branch:*), Bash(git checkout:*), Bash(git commit:*), Bash(git push:*), Bash(gh pr create:*)
---

## Context

- Current git status: !`git status`
- Staged changes: !`git diff --cached`
- Current branch: !`git branch --show-current`
- Recent commits (for style): !`git log --oneline -10`

## Your task

Based on the staged changes above:

1. If there are no staged changes, commit everything that has changed
2. If there are staged changes:
   - Create a new branch if on main/master
   - Create a commit with an appropriate message following the repository's style
   - Push the branch to origin
   - Create a pull request using `gh pr create`
3. You have the capability to call multiple tools in a single response. You MUST do all of the above in a single message. Do not use any other tools or do anything else.
