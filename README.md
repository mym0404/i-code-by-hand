# I Code By Hand

![I Code By Hand hero](./ogimage.png)

`AGENTS.md` or `CLAUDE.md` are powerful ways to instruct AI agents.

> [!NOTE]
> You can use `AGENTS.md` or `CLAUDE.md` placed in outside of the repo.

## Usecase 1: You're required to sneak your AI usage.

But if you put them in the repo and jot down prompts all day long, your boss who think you are slacking off might be angry.

Sneak your AI instructions out of the repo and use it secretely.

## Usecase 2: You're an enthusiastic open-source contributor of a legacy project.

Adding `AGENTS.md` or `CLAUDE.md` to the repo is out of your remit, right? Don't worry.

Stop trying to create PR adding these files and start using the skill instead.

## What it is

An agent skill that manages `AGENTS.md` or `CLAUDE.md` guidance outside of the repo.

Your outside repository knowledge is stored under a repo-specific directory:

```text
~/.icodebyhand/{owner}/{repo}/
```

Use `$i-code-by-hand` to manage repo-specific instructions outside of the repo.

## Install

```sh
# Global (recommended)
npx skills add mym0404/i-code-by-hand -g -s i-code-by-hand

# Project-local
npx skills add mym0404/i-code-by-hand -s i-code-by-hand

# Manual SKILL copy
mkdir -p ~/.agents/skills/i-code-by-hand && curl -fsSL https://raw.githubusercontent.com/mym0404/i-code-by-hand/main/skills/i-code-by-hand/SKILL.md -o ~/.agents/skills/i-code-by-hand/SKILL.md
```

## Notes

| AGENTS.md in project | Work? |
| --- | --- |
| O | X |
| X | O |

- Project-local instructions still take priority.
- Missing global memory entry points are not created automatically.
