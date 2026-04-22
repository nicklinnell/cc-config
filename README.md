# cc-config

Nick's personal Claude Code marketplace — a collection of skills installable via the Claude Code plugin system.

## Register

```
/plugin marketplace add nicklinnell/cc-config
```

## Install a skill

```
/plugin install <name>@cc-config
```

## Skills

| Name | Description | Category |
|------|-------------|----------|
| `commit` | Create a git commit from staged or unstaged changes | workflow |
| `compress-video-for-github` | Compress any video file into an MP4 suitable for embedding in a GitHub PR | utilities |
| `designing-subagents` | Design effective Claude Code sub-agents following best practices | meta |
| `device-logs` | Show iOS Simulator or Android Emulator device logs | mobile |
| `grill-me` | Interview the user relentlessly about a plan or design until reaching shared understanding | workflow |
| `improve-ticket` | Refine a Linear ticket for clarity, structure, and actionability | workflow |
| `karpathy-guidelines` | Behavioural guidelines to reduce common LLM coding mistakes | meta |
| `review-pr` | Review a GitHub pull request for security issues, bugs, and code quality | code-review |
| `security-review` | Review changed code for security vulnerabilities | code-review |
| `simulator-snapshot` | Capture a screenshot of the running iOS Simulator or Android Emulator | mobile |
| `tdd` | Test-driven development with red-green-refactor loop | workflow |
| `verify-design` | Verify app UI against a Figma design | design |

## Adding a skill

Each skill lives in `skills/<name>/` and needs:

- `skills/<name>/skills/<name>/SKILL.md` — the skill definition
- `skills/<name>/.claude-plugin/plugin.json` — plugin metadata (with `"skills": ["./skills/<name>"]`)

Then add an entry to `.claude-plugin/marketplace.json`.
