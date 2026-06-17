---
name: agentmd-delegate
description: Use shared repo-specific agent notes from ~/.agentsmd when a project does not provide AGENTS.md or CLAUDE.md. Use before coding, reviewing, debugging, or updating memory in repositories that lack local agent instructions, and when the user asks to remember, store, update, or revise repo-specific agent guidance without adding files to the project.
---

# AgentMD Delegate

## Overview

Use this skill to keep repo-specific agent guidance outside the project tree. It lets Codex and Claude share one global memory root without adding AGENTS.md or CLAUDE.md to repositories that do not already have them.

Global memory root:

```text
~/.agentsmd
```

## Before work

1. Check the project root for local instruction files:

```sh
ls AGENTS.md CLAUDE.md 2>/dev/null
```

2. If either file exists, follow the local project instructions first. Read global memory only when the user asks for it or the task clearly needs repo memory outside the project.

3. If neither file exists, compute the repo key and look for:

```text
~/.agentsmd/{repo-key}/AGENTS.md
```

4. If that file exists, read it before changing code, reviewing code, debugging, or giving repo-specific advice.

5. If it does not exist, do not create it unless the user asks to remember, store, update, or revise memory.

## Repo key

Prefer the Git remote owner and repo name:

```sh
git remote get-url origin 2>/dev/null
```

Normalize common GitHub remote formats to `owner/repo`:

```text
https://github.com/owner/repo.git -> owner/repo
git@github.com:owner/repo.git -> owner/repo
```

If there is no usable remote, use the current working directory basename:

```sh
basename "$PWD"
```

Examples:

```text
~/.agentsmd/mym0404/agentmd-delegate/AGENTS.md
~/.agentsmd/local-folder-name/AGENTS.md
```

## Memory updates

When the user asks to remember or update repo-specific guidance:

1. Compute the repo key.
2. Read the existing global `AGENTS.md` if it exists.
3. Create the parent directory if needed.
4. Write only current repo guidance that should apply in future sessions.
5. Remove duplicate, stale, or conflicting guidance while editing.
6. Keep local project instructions authoritative when they exist.

Do not store secrets, credentials, tokens, or private personal data. If a requested memory entry would be risky to persist, explain the risk and ask for a safer wording.

## Priority

Use this order when instructions overlap:

1. Direct user instruction in the current conversation.
2. Project-local `AGENTS.md` or `CLAUDE.md`.
3. Global repo memory from `~/.agentsmd`.
4. General coding practices.

If global memory conflicts with local project instructions, follow the local project instructions and mention the conflict briefly.
