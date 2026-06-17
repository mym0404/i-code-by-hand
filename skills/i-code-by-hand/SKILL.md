---
name: i-code-by-hand
description: Use at the start of repository-specific coding, review, debugging, refactoring, explanation, and planning tasks to decide whether local AGENTS.md/CLAUDE.md or shared ~/.icodebyhand notes apply. When the user explicitly invokes this skill for guidance or memory work, manage the repo-specific knowledge document under ~/.icodebyhand. Use shared repo-specific notes from ~/.icodebyhand when the project root does not provide AGENTS.md or CLAUDE.md. Also use when the user asks to remember, store, update, bootstrap, or revise repo-specific agent guidance without a clear local-file target. Do not use it to replace explicit requests to create or edit project-local AGENTS.md or CLAUDE.md.
---

# i-code-by-hand

## Overview

Use this skill to keep repo-specific agent guidance outside the project tree. It lets Codex and Claude share one global memory root without adding AGENTS.md or CLAUDE.md to repositories that do not already have them.

Global memory root:

```text
~/.icodebyhand
```

## Decision rules

| Situation | Required behavior |
| --- | --- |
| User explicitly invokes this skill for guidance or memory work | Treat the task as global knowledge-document management under `~/.icodebyhand`. |
| Project has `AGENTS.md` or `CLAUDE.md` | Follow local instructions. Do not read or apply `~/.icodebyhand` for normal work. |
| Project has no local instruction file | Check `~/.icodebyhand/{repo-key}/AGENTS.md` before repo-specific work. |
| Bootstrap asks for an instruction document but the target is unclear | Ask whether to create global `~/.icodebyhand/{repo-key}/AGENTS.md` or a project-local `AGENTS.md`/`CLAUDE.md` before writing. |
| User asks to update global memory | Update only the matching `~/.icodebyhand` file unless they name a local file. |
| User asks to create or edit local `AGENTS.md` or `CLAUDE.md` | Do exactly that local-file task. Do not redirect it to `~/.icodebyhand`. |

## Before repo-specific work

1. Resolve the project root. Prefer the Git worktree root:

```sh
PROJECT_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
```

If that fails, inspect parent directories before accepting `pwd`. Use the nearest parent that looks like a project root, such as a directory containing `.hg`, `.svn`, `package.json`, `pyproject.toml`, `Cargo.toml`, `go.mod`, `Makefile`, or `README.md`. If no parent has a clear project marker, use the current working directory as the project root.

2. Check the project root for local instruction files:

```sh
ls "$PROJECT_ROOT/AGENTS.md" "$PROJECT_ROOT/CLAUDE.md" 2>/dev/null
```

3. If either file exists, follow the local project instructions first. Stop the delegation lookup for normal coding, review, debugging, and repo advice.

4. If neither file exists, compute the repo key from the project root and look for:

```text
~/.icodebyhand/{repo-key}/AGENTS.md
```

5. If that file exists, read it before changing code, reviewing code, debugging, or giving repo-specific advice. Treat this as an automatic pre-work check; do not wait for the user to mention global memory.

6. If it does not exist, do not create it unless the user asks to remember, store, update, or revise memory.

## Local instruction edits

If the user explicitly asks to create, edit, replace, remove, or review project-local `AGENTS.md` or `CLAUDE.md`, the named local file is the target.

- Do not substitute a global memory update for the requested local-file change.
- Do not create or edit `~/.icodebyhand` unless the user also asks for a global memory change.
- Do not copy global memory into the local file unless the user asks to migrate, import, or reuse it.
- If local instructions and global memory both exist, local instructions remain authoritative.

## Bootstrap ambiguity

If the task is an initial setup or bootstrap of agent instructions and the user has not clearly chosen global memory or a project-local instruction file, stop and ask a narrow question before creating or editing files.

Ask the user to choose between:

- Global repo memory: `~/.icodebyhand/{repo-key}/AGENTS.md`
- Project-local instructions: `AGENTS.md` or `CLAUDE.md` in the project root

Do not infer the target from convenience, existing folders, or the current agent. A bootstrap decision changes where future agents will look for instructions, so get an explicit answer first.

## Repo key

Prefer the Git remote owner and repo name:

```sh
git -C "$PROJECT_ROOT" remote get-url origin 2>/dev/null
```

Normalize common GitHub remote formats to `owner/repo`:

```text
https://github.com/owner/repo.git -> owner/repo
git@github.com:owner/repo.git -> owner/repo
```

If there is no usable remote, use the project root basename:

```sh
basename "$PROJECT_ROOT"
```

Examples:

```text
~/.icodebyhand/mym0404/i-code-by-hand/AGENTS.md
~/.icodebyhand/local-folder-name/AGENTS.md
```

## Memory updates

When the user asks to remember or update repo-specific guidance:

1. Compute the repo key.
2. Read the existing global `AGENTS.md` if it exists.
3. Create the parent directory if needed.
4. Write only current repo guidance that should apply in future sessions.
5. Remove duplicate, stale, or conflicting guidance while editing.
6. Keep local project instructions authoritative when they exist.

If the user says only "remember this", "store this for this repo", or "update memory", prefer global memory. If they name `AGENTS.md`, `CLAUDE.md`, "project file", or "local instructions", edit the local file they named.

If the user explicitly invokes this skill while asking to store, revise, or organize guidance, use the global repo memory path even if local instruction files exist. Keep local project instructions authoritative for normal coding behavior, but do not let them prevent global knowledge-document maintenance.

Do not store secrets, credentials, tokens, or private personal data. If a requested memory entry would be risky to persist, explain the risk and ask for a safer wording.

## Priority

Use this order when instructions overlap:

1. Direct user instruction in the current conversation.
2. Project-local `AGENTS.md` or `CLAUDE.md`.
3. Global repo memory from `~/.icodebyhand`.
4. General coding practices.

If global memory conflicts with local project instructions, follow the local project instructions and mention the conflict briefly.
