---
name: i-code-by-hand
description: Use before repository-specific coding, review, debugging, refactoring, explanation, or planning to resolve agent guidance from local AGENTS.md/CLAUDE.md or shared ~/.icodebyhand notes. Also use when the user asks to remember, store, organize, update, bootstrap, or revise repo-specific guidance without a clear local-file target. Use the bundled status CLI to decide local, global, or ask. Do not replace explicit requests to edit project-local AGENTS.md or CLAUDE.md.
---

# i-code-by-hand

## Overview

Use this skill to keep repo-specific agent guidance outside the project tree. It lets Codex and Claude share one global memory root without adding AGENTS.md or CLAUDE.md to repositories that do not already have them.

Each repo gets a directory under the global memory root. `AGENTS.md` is the primary entry point in that directory, but it is not the only allowed knowledge file. It may route to other repo-specific notes, checklists, references, or decision records stored beside it.

Global memory root:

```text
~/.icodebyhand
```

## Decision rules

| Situation | Required behavior |
| --- | --- |
| User explicitly invokes this skill for guidance or memory work | Run the status command and use the returned knowledge location. |
| Project has `AGENTS.md` or `CLAUDE.md` | Follow local instructions. Do not read or apply `~/.icodebyhand` for normal work. |
| Project has no local instruction file | Check `~/.icodebyhand/{repo-key}/AGENTS.md` as the external repo-memory entry point before repo-specific work. |
| Bootstrap asks for an instruction document but the target is unclear | Ask whether to create global `~/.icodebyhand/{repo-key}/` memory with an `AGENTS.md` entry point or a project-local `AGENTS.md`/`CLAUDE.md` before writing. |
| User asks to update global memory | Update the matching `~/.icodebyhand/{repo-key}` memory directory unless they name a local file. Keep `AGENTS.md` as the entry point. |
| User asks to create or edit local `AGENTS.md` or `CLAUDE.md` | Do exactly that local-file task. Do not redirect it to `~/.icodebyhand`. |

## Knowledge-location status

For requests to organize, remember, store, update, bootstrap, or revise repo-specific knowledge without a named local file, run this first from this skill directory:

```sh
python3 scripts/i_code_by_hand.py status
```

The command returns JSON for agent use:

```json
{"knowledge_location":"global","knowledge_path":"/Users/mj/.icodebyhand/owner/repo","project_key":"owner/repo","should_ask_user":false}
```

- If `knowledge_location` is `global`, do not create or edit project-local `AGENTS.md`, `CLAUDE.md`, prompt guides, or instruction documents. Store the knowledge under `knowledge_path`.
- If `knowledge_location` is `local`, update the local file at `knowledge_path`.
- If `should_ask_user` is `true`, ask where the knowledge should live before creating or editing files.
- A request that names a specific local file such as `AGENTS.md`, `CLAUDE.md`, or a project-local path may edit that file directly.

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

6. If `AGENTS.md` routes to other files in the same repo-memory directory, read only the routed files that are relevant to the current task.

7. If the entry point does not exist, do not create it unless the user asks to remember, store, update, or revise memory.

## Local instruction edits

If the user explicitly asks to create, edit, replace, remove, or review project-local `AGENTS.md` or `CLAUDE.md`, the named local file is the target.

- Do not substitute a global memory update for the requested local-file change.
- Do not create or edit `~/.icodebyhand` unless the user also asks for a global memory change.
- Do not copy global memory into the local file unless the user asks to migrate, import, or reuse it.
- If local instructions and global memory both exist, local instructions remain authoritative.

## Bootstrap ambiguity

If the task is an initial setup or bootstrap of agent instructions and the user has not clearly chosen global memory or a project-local instruction file, stop and ask a narrow question before creating or editing files.

Run `python3 scripts/i_code_by_hand.py status` first. If it returns `should_ask_user: true`, ask the user to choose the location. Do not create a project-local prompt guide while the status points to `global` or `ask`.

Ask the user to choose between:

- Global repo memory: `~/.icodebyhand/{repo-key}/` with `AGENTS.md` as the entry point
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
~/.icodebyhand/mym0404/i-code-by-hand/notes.md
~/.icodebyhand/mym0404/i-code-by-hand/decisions/api.md
~/.icodebyhand/local-folder-name/AGENTS.md
```

## Memory updates

When the user asks to remember or update repo-specific guidance:

1. Run `python3 scripts/i_code_by_hand.py status`.
2. If `should_ask_user` is `true`, ask where the knowledge should live before creating or editing files.
3. If `knowledge_location` is `local`, update the local file at `knowledge_path`.
4. If `knowledge_location` is `global`, read the existing global `AGENTS.md` entry point if it exists.
5. Read any routed files that are relevant to the requested memory update.
6. Create the repo-memory directory if needed.
7. Store durable guidance in `AGENTS.md` when it is short and central.
8. Store longer or specialized knowledge in additional files under the same repo-memory directory when that lowers cognitive load.
9. Update `AGENTS.md` so it points to any additional files an agent should consult.
10. Remove duplicate, stale, or conflicting guidance while editing.
11. Keep local project instructions authoritative when they exist.

If the user says only "remember this", "store this for this repo", "organize the knowledge docs", or "update memory", use the status command. If they name `AGENTS.md`, `CLAUDE.md`, "project file", or "local instructions", edit the local file they named.

If the user explicitly invokes this skill while asking to store, revise, or organize guidance, still use the status command. Keep local project instructions authoritative for normal coding behavior, but do not create project-local prompt guides unless the status result or the user names a local file.

Do not store secrets, credentials, tokens, or private personal data. If a requested memory entry would be risky to persist, explain the risk and ask for a safer wording.

## Priority

Use this order when instructions overlap:

1. Direct user instruction in the current conversation.
2. Project-local `AGENTS.md` or `CLAUDE.md`.
3. Global repo memory from `~/.icodebyhand`.
4. General coding practices.

If global memory conflicts with local project instructions, follow the local project instructions and mention the conflict briefly.
