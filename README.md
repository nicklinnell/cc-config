# cc-config

Personal Claude Code configuration: skills, hooks, and global settings.

## Setup

```bash
git clone https://github.com/nicklinnell/cc-config ~/work/cc-config
cd ~/work/cc-config
chmod +x install.sh
./install.sh
```

This symlinks `CLAUDE.md`, `software-engineering-guidelines.md`, hooks, and all skills into `~/.claude/`.

## Managing skills

```bash
./install.sh list              # show available skills (* = installed)
./install.sh install <skill>   # install a single skill
./install.sh remove <skill>    # remove an installed skill
./install.sh update            # pull latest and refresh all symlinks
```

## Structure

```
config/         Global CLAUDE.md, guidelines, and hooks
commands/       Slash commands (e.g. /ticket)
skills/         Individual skills — each is independently installable
```

## Adding as a marketplace

Register this repo in your `~/.claude/settings.json`:

```json
"extraKnownMarketplaces": {
  "cc-config": {
    "source": {
      "source": "github",
      "repo": "nicklinnell/cc-config"
    }
  }
}
```

Then install skills via:

```
/plugin marketplace add nicklinnell/cc-config
```
