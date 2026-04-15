#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
CLAUDE_DIR="$HOME/.claude"
SKILLS_DIR="$CLAUDE_DIR/skills"
HOOKS_DIR="$CLAUDE_DIR/hooks"
COMMANDS_DIR="$CLAUDE_DIR/commands"

usage() {
  cat <<EOF
Usage: $0 [command] [skill]

Commands:
  install          Symlink all config files and install all skills (default)
  install <skill>  Install a single skill by name
  remove <skill>   Remove an installed skill
  list             List available skills and their install status
  update           Pull latest changes and refresh symlinks

EOF
}

symlink() {
  local src="$1" dst="$2"
  mkdir -p "$(dirname "$dst")"
  ln -sfn "$src" "$dst"
  echo "  linked: $dst"
}

link_config() {
  echo "Linking config files..."
  symlink "$REPO_DIR/config/CLAUDE.md" "$CLAUDE_DIR/CLAUDE.md"
  symlink "$REPO_DIR/config/software-engineering-guidelines.md" "$CLAUDE_DIR/software-engineering-guidelines.md"
  symlink "$REPO_DIR/config/hooks/simplify-check.py" "$HOOKS_DIR/simplify-check.py"
  symlink "$REPO_DIR/commands/ticket.md" "$COMMANDS_DIR/ticket.md"
}

install_skill() {
  local name="$1"
  local skill_src="$REPO_DIR/skills/$name"
  if [ ! -d "$skill_src" ]; then
    echo "Error: skill '$name' not found in $REPO_DIR/skills/" >&2
    exit 1
  fi
  symlink "$skill_src" "$SKILLS_DIR/$name"
  echo "  installed: $name"
}

remove_skill() {
  local name="$1"
  local skill_dst="$SKILLS_DIR/$name"
  if [ -L "$skill_dst" ]; then
    rm "$skill_dst"
    echo "  removed: $name"
  elif [ -d "$skill_dst" ]; then
    echo "  skipped: $name is a directory (not a managed symlink)"
  else
    echo "  not installed: $name"
  fi
}

list_skills() {
  echo "Available skills (* = installed):"
  for skill_dir in "$REPO_DIR/skills"/*/; do
    local name
    name=$(basename "$skill_dir")
    if [ -L "$SKILLS_DIR/$name" ]; then
      echo "  * $name"
    else
      echo "    $name"
    fi
  done
}

install_all() {
  link_config
  echo "Installing skills..."
  mkdir -p "$SKILLS_DIR"
  for skill_dir in "$REPO_DIR/skills"/*/; do
    local name
    name=$(basename "$skill_dir")
    install_skill "$name"
  done
  echo "Done."
}

cmd="${1:-install}"

case "$cmd" in
  install)
    if [ -n "${2:-}" ]; then
      install_skill "$2"
    else
      install_all
    fi
    ;;
  remove)
    [ -z "${2:-}" ] && { echo "Error: specify a skill name"; usage; exit 1; }
    remove_skill "$2"
    ;;
  list)
    list_skills
    ;;
  update)
    git -C "$REPO_DIR" pull --ff-only
    install_all
    ;;
  help|--help|-h)
    usage
    ;;
  *)
    echo "Unknown command: $cmd"
    usage
    exit 1
    ;;
esac
