#!/usr/bin/env python3
import argparse
import json
import re
import subprocess
from pathlib import Path


def run_git(project_root: Path, args: list[str]) -> str | None:
    result = subprocess.run(
        ["git", "-C", str(project_root), *args],
        check=False,
        capture_output=True,
        text=True,
    )
    if result.returncode != 0:
        return None
    value = result.stdout.strip()
    return value or None


def resolve_project_root(project_root: str | None) -> Path:
    if project_root:
        return Path(project_root).expanduser().resolve()

    cwd = Path.cwd()
    git_root = run_git(cwd, ["rev-parse", "--show-toplevel"])
    if git_root:
        return Path(git_root).resolve()
    return cwd.resolve()


def repo_key(project_root: Path) -> str:
    remote = run_git(project_root, ["remote", "get-url", "origin"])
    if not remote:
        return project_root.name

    match = re.search(r"github\.com[:/](?P<owner>[^/]+)/(?P<repo>[^/]+?)(?:\.git)?$", remote)
    if match:
        return f"{match.group('owner')}/{match.group('repo')}"

    cleaned = remote.removesuffix(".git").rstrip("/")
    parts = [part for part in re.split(r"[:/]", cleaned) if part]
    if len(parts) >= 2:
        return "/".join(parts[-2:])
    return project_root.name


def status(project_root: Path, memory_root: Path) -> dict[str, object]:
    local_files = [
        path
        for path in (project_root / "AGENTS.md", project_root / "CLAUDE.md")
        if path.exists()
    ]
    key = repo_key(project_root)
    global_path = memory_root / key
    global_entry = global_path / "AGENTS.md"

    has_local = bool(local_files)
    has_global = global_entry.exists()

    if has_local and not has_global:
        return {
            "project_key": key,
            "knowledge_location": "local",
            "knowledge_path": str(local_files[0]),
            "should_ask_user": False,
        }

    if has_global and not has_local:
        return {
            "project_key": key,
            "knowledge_location": "global",
            "knowledge_path": str(global_path),
            "should_ask_user": False,
        }

    return {
        "project_key": key,
        "knowledge_location": "ask",
        "knowledge_path": None,
        "should_ask_user": True,
    }


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("command", choices=["status"])
    parser.add_argument("--project-root")
    parser.add_argument("--memory-root", default="~/.icodebyhand")
    args = parser.parse_args()

    project_root = resolve_project_root(args.project_root)
    memory_root = Path(args.memory_root).expanduser().resolve()
    print(json.dumps(status(project_root, memory_root), separators=(",", ":"), sort_keys=True))


if __name__ == "__main__":
    main()
