# I Code By Hand

![I Code By Hand hero](./ogimage.png)

`AGENTS.md` or `CLAUDE.md` are powerful way to instruct your cute AI agents.

## Usecase 1: You're required to sneak your AI usage.

But if you put them in the repo and jot down prompts all day long, your boss who think you are slacking off might be angry.

Sneak your AI into your repo and use it secretely.

## Usecase 2: You're an enthusiastic open-source contributor of a legacy project.

Adding `AGENTS.md` or `CLAUDE.md` to the repo is out of your remit, right? Don't worry.

Stop trying to create PR adding these files and start using the skill instead.

## What it is

A agent skill that manage `AGENTS.md` or `CLAUDE.md` outside of the repo and automatically manage it.

Your outside repository knowledges will be stored in the below path.

```text
~/.icodebyhand/{owner}/{repo}/AGENTS.md
```

If a project already has `AGENTS.md` or `CLAUDE.md`, the local file wins. If it does not, the skill can read the matching file under `~/.icodebyhand`. When you ask the agent to remember repo-specific guidance, it updates that global file instead of changing the project.

## Install


```sh
npx skills add mym0404/i-code-by-hand -g -s i-code-by-hand
```

The `skills` CLI installs the skill into the selected agent's global skill folder. Create `~/.icodebyhand` when you add the first repo memory file.

## Notes

- Project-local instructions still take priority.
- Missing global memory files are not created automatically.
