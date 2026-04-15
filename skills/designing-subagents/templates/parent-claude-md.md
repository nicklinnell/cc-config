# Parent Agent Orchestration Rules

Add these rules to your project's `CLAUDE.md` to enable effective sub-agent orchestration.

---

```markdown
## Sub-Agent Orchestration

### Context Management

Always maintain a project context file at `.claude/docs/tasks/context-session.md`:
- Create this file at the start of any multi-step feature
- Update it after each implementation phase
- Sub-agents will read and update this file

### Delegation Rules

**Delegate to sub-agents for**:
- Researching implementation approaches
- Analysing existing codebase patterns
- Creating detailed implementation plans
- Gathering documentation and examples

**Handle directly (never delegate)**:
- Actual code implementation
- File modifications
- Bug fixes
- Testing

### Sub-Agent Workflow

1. Before starting a feature, create the context file
2. Delegate research to appropriate sub-agent(s)
3. Wait for sub-agent to complete and create plan file
4. Read the plan file created by sub-agent
5. Implement based on the plan (you do this, not sub-agent)
6. Update context file with implementation progress
7. Repeat for next phase

### Available Sub-Agents

| Agent | Use For | Triggers |
|-------|---------|----------|
| {agent-1} | {purpose-1} | {trigger-phrases-1} |
| {agent-2} | {purpose-2} | {trigger-phrases-2} |

### After Sub-Agent Completes

Always read the documentation file created by the sub-agent before implementing:
- Check `.claude/docs/` for new plan files
- Review the implementation steps
- Follow the plan, don't deviate without reason

### Context File Location

```
.claude/
└── docs/
    └── tasks/
        └── context-session.md    # Shared context
    └── {feature}-plan.md         # Sub-agent outputs
    └── {feature}-research.md     # Research findings
```
```

---

## Usage

1. Copy the rules above into your project's `CLAUDE.md`
2. Replace the `{agent-*}` placeholders with your actual sub-agents
3. Create the `.claude/docs/tasks/` directory structure
4. Start each feature by creating a context file from the template
