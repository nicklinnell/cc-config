#!/bin/bash
# Scans ~/.claude/ for existing automation features
# Outputs summary of skills, commands, agents, and hooks
# Usage: bash scan-existing-setup.sh

CLAUDE_DIR="${HOME}/.claude"

echo "=== Existing Claude Code Automations ==="
echo ""

# Skills
echo "## Skills"
if [ -d "$CLAUDE_DIR/skills" ]; then
  skill_count=0
  while IFS= read -r -d '' file; do
    skill_count=$((skill_count + 1))
    name=$(grep -m1 "^name:" "$file" 2>/dev/null | sed 's/name:[[:space:]]*//')
    desc=$(grep -m1 "^description:" "$file" 2>/dev/null | sed 's/description:[[:space:]]*//' | cut -c1-80)
    echo "- $name"
    echo "  $desc..."
  done < <(find "$CLAUDE_DIR/skills" -name "SKILL.md" -print0 2>/dev/null)

  if [ $skill_count -eq 0 ]; then
    echo "  (none found)"
  fi
else
  echo "  (skills directory not found)"
fi
echo ""

# Commands
echo "## Commands"
if [ -d "$CLAUDE_DIR/commands" ]; then
  cmd_count=0
  for file in "$CLAUDE_DIR/commands"/*.md; do
    if [ -f "$file" ]; then
      cmd_count=$((cmd_count + 1))
      name=$(basename "$file" .md)
      desc=$(grep -m1 "^description:" "$file" 2>/dev/null | sed 's/description:[[:space:]]*//' | cut -c1-60)
      if [ -n "$desc" ]; then
        echo "- /$name: $desc"
      else
        echo "- /$name"
      fi
    fi
  done

  if [ $cmd_count -eq 0 ]; then
    echo "  (none found)"
  fi
else
  echo "  (commands directory not found)"
fi
echo ""

# Agents (from plugins)
echo "## Sub-Agents"
agent_found=0
if [ -d "$CLAUDE_DIR/plugins" ]; then
  while IFS= read -r -d '' file; do
    agent_found=1
    name=$(basename "$file" .md)
    echo "- @agent-$name"
  done < <(find "$CLAUDE_DIR/plugins" -path "*/agents/*.md" -print0 2>/dev/null)
fi

if [ -d "$CLAUDE_DIR/agents" ]; then
  while IFS= read -r -d '' file; do
    agent_found=1
    name=$(basename "$file" .md)
    echo "- @agent-$name"
  done < <(find "$CLAUDE_DIR/agents" -name "*.md" -print0 2>/dev/null)
fi

if [ $agent_found -eq 0 ]; then
  echo "  (none found)"
fi
echo ""

# Hooks
echo "## Hooks"
hook_found=0
for hooks_file in "$CLAUDE_DIR/hooks/hooks.json" "$CLAUDE_DIR/plugins/"*/hooks/hooks.json; do
  if [ -f "$hooks_file" ]; then
    hook_found=1
    echo "- Found: $hooks_file"
    # Extract hook types if jq available
    if command -v jq &> /dev/null; then
      jq -r '.hooks | keys[]' "$hooks_file" 2>/dev/null | while read -r hook_type; do
        echo "  - $hook_type"
      done
    fi
  fi
done

if [ $hook_found -eq 0 ]; then
  echo "  (none found)"
fi
echo ""

# MCP Servers
echo "## MCP Servers"
mcp_found=0
for mcp_file in "$CLAUDE_DIR/claude_code_config.json" "$CLAUDE_DIR/.mcp.json"; do
  if [ -f "$mcp_file" ]; then
    mcp_found=1
    echo "- Config: $mcp_file"
    if command -v jq &> /dev/null; then
      jq -r '.mcpServers // {} | keys[]' "$mcp_file" 2>/dev/null | while read -r server; do
        echo "  - $server"
      done
    fi
  fi
done

if [ $mcp_found -eq 0 ]; then
  echo "  (none configured)"
fi

echo ""
echo "=== End of Scan ==="
