# AGENTS.md Delegate

> For contributors who cannot add a `AGENTS.md` or `CLAUDE.md` to the projects they contribute to.

Keep repo-specific agent notes outside the repo.

Some projects do not have `AGENTS.md` or `CLAUDE.md`, and adding one just for your own agent workflow can feel too heavy. `agentmd-delegate` gives Codex and Claude a shared place to look instead:

```text
~/.agentsmd/{owner}/{repo}/AGENTS.md
```

If a project already has `AGENTS.md` or `CLAUDE.md`, the local file wins. If it does not, the skill can read the matching file under `~/.agentsmd`. When you ask the agent to remember repo-specific guidance, it updates that global file instead of changing the project.

## Install

Codex:

```sh
curl -fsSL https://raw.githubusercontent.com/mym0404/agentmd-delegate/main/install.sh | sh -s -- --codex
```

Claude:

```sh
curl -fsSL https://raw.githubusercontent.com/mym0404/agentmd-delegate/main/install.sh | sh -s -- --claude
```

Both:

```sh
curl -fsSL https://raw.githubusercontent.com/mym0404/agentmd-delegate/main/install.sh | sh -s -- --codex --claude
```

The installer copies the skill into the selected global skill folder and creates `~/.agentsmd`.

## How it picks a memory file

The skill prefers the GitHub remote name:

```text
git@github.com:mym0404/agentmd-delegate.git -> ~/.agentsmd/mym0404/agentmd-delegate/AGENTS.md
https://github.com/mym0404/agentmd-delegate.git -> ~/.agentsmd/mym0404/agentmd-delegate/AGENTS.md
```

If there is no Git remote, it uses the current folder name:

```text
~/.agentsmd/current-folder/AGENTS.md
```

## Notes

- Project-local instructions still take priority.
- Missing global memory files are not created automatically.
- Memory updates should describe the current repo state, not a history of changes.
