# Automation Approach Decision Matrix

Quick reference for choosing the right Claude Code automation approach.

## Decision Flow (First Match Wins)

```
User Request
    |
    v
External API/service? ----Yes----> MCP Server
    |
    No
    |
    v
Lifecycle event? --------Yes----> Hook
(before/after tool)
    |
    No
    |
    v
Parallelisation needed? -Yes----> Sub-Agent
    |
    No
    |
    v
Context isolation? ------Yes----> Sub-Agent
(large research)
    |
    No
    |
    v
Automatic domain rules? -Yes----> Skill
(standards, templates)
    |
    No
    |
    v
Manual workflow ------------------> Command
```

## Feature Comparison

| Aspect | Skill | Sub-Agent | Command | MCP | Hook |
|--------|-------|-----------|---------|-----|------|
| **Trigger** | Auto (phrases) | Manual (@) | Manual (/) | Via agents | Auto (tools) |
| **Context** | Persistent | Isolated | Current | Per-call | Ephemeral |
| **Best for** | Domain rules | Research | Workflows | External APIs | Lifecycle |
| **Can parallelise** | No | Yes | No | No | No |
| **Token cost** | ~5k on load | Separate budget | Minimal | Per-call | Injected |

## Keywords to Listen For

**Skill indicators:**
- "automatically", "always", "whenever"
- "enforce", "follow rules", "conventions"
- "templates", "boilerplate", "patterns"

**Sub-Agent indicators:**
- "research", "investigate", "find out"
- "in parallel", "multiple at once"
- "don't want context bloat"

**Command indicators:**
- "when I type", "manual trigger"
- "workflow", "sequence of steps"
- "one-off", "deploy", "commit"

**MCP indicators:**
- Service names: Stripe, GitHub, Supabase, etc.
- "API", "external", "third-party"
- "connect to", "integrate with"

**Hook indicators:**
- "before editing", "after saving"
- "remind me", "warn me", "inject context"
- "lifecycle", "every time I edit"

## Common Scenarios

| Scenario | Approach | Why |
|----------|----------|-----|
| Run tests, fix failures | Sub-Agent | Context isolation, potential parallelisation |
| Enforce coding standards | Skill | Automatic, domain rules |
| Commit workflow | Command | Manual, multi-step |
| Connect to Stripe API | MCP | External service |
| Warn before editing auth | Hook | Lifecycle event |
| Generate boilerplate | Skill | Templates, automatic |
| Research API options | Sub-Agent | Context isolation |
| Deploy to staging | Command | Manual workflow |
