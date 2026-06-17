#!/bin/sh
set -eu

REPO_RAW_URL="${AGENTMD_DELEGATE_RAW_URL:-https://raw.githubusercontent.com/mym0404/agentmd-delegate/main}"
SKILL_NAME="agentmd-delegate"
INSTALL_CODEX=0
INSTALL_CLAUDE=0

usage() {
  cat <<'EOF'
Usage: install.sh [--codex] [--claude]

Options:
  --codex   Install the skill into ~/.codex/skills/agentmd-delegate
  --claude  Install the skill into ~/.claude/skills/agentmd-delegate
  --help    Show this help
EOF
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --codex)
      INSTALL_CODEX=1
      ;;
    --claude)
      INSTALL_CLAUDE=1
      ;;
    --help|-h)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
  shift
done

if [ "$INSTALL_CODEX" -eq 0 ] && [ "$INSTALL_CLAUDE" -eq 0 ]; then
  echo "Choose at least one target: --codex or --claude" >&2
  usage >&2
  exit 1
fi

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" 2>/dev/null && pwd)
LOCAL_SKILL_DIR="$SCRIPT_DIR/skills/$SKILL_NAME"
TMP_DIR=$(mktemp -d)
trap 'rm -rf "$TMP_DIR"' EXIT INT HUP TERM

fetch_skill() {
  if [ -f "$LOCAL_SKILL_DIR/SKILL.md" ]; then
    cp -R "$LOCAL_SKILL_DIR" "$TMP_DIR/$SKILL_NAME"
    return
  fi

  if ! command -v curl >/dev/null 2>&1; then
    echo "curl is required for remote installation." >&2
    exit 1
  fi

  mkdir -p "$TMP_DIR/$SKILL_NAME/agents"
  curl -fsSL "$REPO_RAW_URL/skills/$SKILL_NAME/SKILL.md" -o "$TMP_DIR/$SKILL_NAME/SKILL.md"
  curl -fsSL "$REPO_RAW_URL/skills/$SKILL_NAME/agents/openai.yaml" -o "$TMP_DIR/$SKILL_NAME/agents/openai.yaml"
}

install_skill() {
  target_dir="$1"
  mkdir -p "$(dirname "$target_dir")"
  rm -rf "$target_dir"
  cp -R "$TMP_DIR/$SKILL_NAME" "$target_dir"
  echo "Installed $SKILL_NAME to $target_dir"
}

fetch_skill
mkdir -p "$HOME/.agentsmd"

if [ "$INSTALL_CODEX" -eq 1 ]; then
  install_skill "$HOME/.codex/skills/$SKILL_NAME"
fi

if [ "$INSTALL_CLAUDE" -eq 1 ]; then
  install_skill "$HOME/.claude/skills/$SKILL_NAME"
fi

echo "Global memory root is $HOME/.agentsmd"
