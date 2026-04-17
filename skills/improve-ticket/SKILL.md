---
name: improve-ticket
description: Refine a Linear ticket for clarity, structure, and actionability so it can be used effectively as a development spec. Use when the user says "improve ticket", "refine ticket", "improve issue", "refine issue", or provides a Linear ticket ID (e.g. CAR-123) and wants it improved or refined. Output is always printed to screen only — never written back to Linear automatically.
---

## Your task

Fetch a Linear ticket, apply refinement rules to improve its clarity and structure, then print the result to screen.

## Steps

1. **Fetch the ticket** — use the Linear MCP `get_issue` tool to retrieve the full ticket details: title, description, acceptance criteria, links, status, type, and priority.

2. **Identify open questions** — review the ticket for ambiguities, missing information, or assumptions that need clarifying. If there are any, use the `AskUserQuestion` tool to ask them **before** proceeding. Incorporate the user's answers into the refined output.

3. **Refine the ticket** — apply the rules below to produce an improved version of each field.

4. **Print to screen only** — output the result as a single markdown block. Never call any Linear write tools.

---

## Refinement rules

### Improved summary
- Short, specific, and outcome-focused
- Starts with an action verb where appropriate
- Avoids internal jargon unless necessary

### Improved description
Structure as three named sections:
- **Context / Background** — why this matters
- **Problem / Current behaviour** — what is wrong or missing
- **Desired outcome / Target behaviour** — what success looks like

Rewrite for clarity and concision. Preserve all URLs and critical domain language.

### Acceptance criteria
- Use bullet points with clear, testable statements
- Prefer "Given / When / Then" style where it helps
- Infer reasonable criteria from the description when missing, but do not change the feature's scope

### Constraints and notes
- Keep all technical details, IDs, and links intact
- Do not invent new business rules — only clarify what is already implied
- If something is ambiguous or missing, it should have been asked via `AskUserQuestion` in step 2. Any questions the user could not answer should be surfaced under an "Open questions" section in the output

---

## Output format

Produce one block per ticket using this exact structure:

```
### [ISSUE KEY]

**Summary**
<rewritten summary>

**Description**

Context / Background
<why this matters>

Problem / Current behaviour
<what is wrong or missing>

Desired outcome / Target behaviour
<what success looks like>

**Acceptance criteria**
- [ ] <criterion 1>
- [ ] <criterion 2>
- [ ] …

**Open questions (if any)**
1. …
2. …
```

If multiple tickets are provided, repeat the block for each one.

---

## Style rules

- Use British English spelling
- Be concise — cut any word that does not add meaning
- Preserve all URLs and domain-specific terminology exactly as written
- Do not invent requirements or acceptance criteria that go beyond the original scope
- Do not add sections that are entirely empty — omit "Open questions" if there are none
