---
name: review-pr-comments
description: Critically evaluate reviewer comments on a GitHub pull request to decide which to act on, which to reject, and which to discuss. Dispatches parallel sub-agents to check ticket scope (via Linear), technical correctness, and existing codebase coverage — then produces a grouped decision report. Use this skill whenever the user says "review PR comments", "critique reviewer feedback", "evaluate PR feedback", "should I address this comment", "triage PR comments", "which comments matter", or wants to decide how to respond to code review. Also trigger when the user asks whether a PR comment is valid, relevant, or in scope.
---

# Review PR Comments

Critically evaluate each reviewer comment on a pull request. Use parallel sub-agents to assess scope, technical validity, and codebase coverage, then produce a grouped verdict report.

## Argument

The user may provide a PR number explicitly (e.g. `review-pr-comments 42`) or none — in which case infer it from the current branch. If no PR is associated with the current branch, ask the user for the PR number.

## Workflow

### 1. Fetch PR metadata, comments, and Linear ticket in parallel

Run all three of these concurrently — they are independent:

```bash
# PR metadata + branch name (used for ticket detection)
gh pr view --json number,title,headRefName,body,url

# Inline review comments (on specific lines)
gh api repos/:owner/:repo/pulls/<PR_NUMBER>/comments \
  --jq '[.[] | {id: .id, path: .path, line: .line, body: .body, user: .user.login, diff_hunk: .diff_hunk}]'

# General PR-level comments
gh api repos/:owner/:repo/issues/<PR_NUMBER>/comments \
  --jq '[.[] | {id: .id, body: .body, user: .user.login}]'
```

Note: `gh` automatically substitutes `:owner` and `:repo` from the current remote — no manual resolution needed.

While the comment fetches run, extract the Linear ticket ID from `headRefName` (e.g. `nick/car-586-engine-mode` → `CAR-586`) or from the PR title/body. If a ticket ID is found, fetch it immediately using the Linear MCP tool (`mcp__claude_ai_Linear__get_issue` or `mcp__plugin_linear_linear__get_issue`).

From the ticket, extract only what sub-agents need: the **acceptance criteria and scope description** (not the full raw ticket). This keeps sub-agent prompts lean. If no ticket is found, note this — scope checks will be skipped.

Combine all comments into a single numbered list. Skip: bot comments (`github-actions[bot]`, `linear[bot]`), and praise-only comments ("LGTM", "+1", "nice"). Note the skipped count.

### 2. Pre-fetch file contents for commented files

For each unique file path referenced by inline comments, read the full file once and cache it. Pass this cached content to sub-agents rather than having each agent re-read the same file independently.

### 3. Dispatch parallel sub-agents for each comment

For each comment, dispatch **three sub-agents in parallel**. Pass each agent: the comment text, diff hunk, the pre-fetched file content, and the extracted ticket scope. They run concurrently — do not wait for one before spawning the others.

---

#### Sub-agent A: Ticket-scope checker

**Goal**: Determine whether acting on this comment falls within the ticket's agreed scope.

Instructions to pass:
```
You are a scope checker. Given a Linear ticket scope summary and a PR reviewer comment, decide
whether addressing the comment is within the agreed scope of the ticket.

Ticket scope: <acceptance criteria and scope description — not the full raw ticket>
Comment: <comment text>
File: <path> line <line>

Respond with:
- in_scope: true/false
- confidence: high/medium/low
- reasoning: 1-2 sentences explaining why
- scope_ruling: "In scope" | "Out of scope" | "Unclear — ticket ambiguous"
```

---

#### Sub-agent B: Technical validator

**Goal**: Determine whether the reviewer's claim or suggestion is technically correct.

Instructions to pass:
```
You are a technical validator. Using the provided code context, decide whether the reviewer's
comment is technically correct, partially correct, or wrong.

Diff hunk:
<diff_hunk>

Full file content (already fetched — do not re-read this file):
<file_content>

Comment: <comment text>

Consider:
- Is the claim factually accurate given the code?
- Is the suggested fix valid and idiomatic for this codebase?
- Could acting on it introduce a new bug or regression?

Respond with:
- technically_valid: true/false/partial
- confidence: high/medium/low
- reasoning: 1-3 sentences
- technical_ruling: "Correct" | "Incorrect" | "Partially correct" | "Subjective/preference"
```

---

#### Sub-agent C: Codebase searcher

**Goal**: Determine whether the concern is already handled elsewhere in the codebase.

Instructions to pass:
```
You are a codebase searcher. Given a PR comment raising a concern, search the codebase to
determine whether that concern is already addressed.

The following file content is already available — do not re-read it:
<file_content>

Comment: <comment text>
File: <path>

Search the wider codebase (other files, tests, utilities) for:
- Existing handling of the same pattern, error case, or validation
- Tests that already cover the scenario
- Comments or TODOs that acknowledge the issue

Respond with:
- already_handled: true/false/partial
- confidence: high/medium/low
- reasoning: 1-2 sentences with file paths if relevant
- coverage_ruling: "Already handled" | "Not handled" | "Partially handled"
```

---

### 4. Synthesise a verdict per comment

After all three sub-agents return, decide the verdict. **Low confidence from any sub-agent takes priority — if confidence is low on any axis, default to Discuss rather than Reject**, then apply the remaining rules:

| Verdict | Meaning |
|---------|---------|
| **Implement** | Valid, in scope, not already handled — act on it |
| **Reject** | One or more hard blockers with medium/high confidence |
| **Discuss** | Conflicting signals, low confidence, or architectural judgement call |

**Decision rules** (apply in order — first match wins):
1. If any sub-agent returned `confidence = low` → **Discuss**
2. If `technically_valid = false` → **Reject** (Technically incorrect)
3. If `in_scope = false` (confidence medium+) → **Reject** (Out of ticket scope)
4. If `already_handled = true` (confidence medium+) → **Reject** (Already handled)
5. If `already_handled = partial` → **Discuss**
6. If `technically_valid = partial` → **Discuss**
7. If all rulings are favourable → **Implement**

**Rejection reasons** (use the most specific applicable):
- Out of ticket scope
- Technically incorrect
- Style preference (no objective benefit)
- Already handled in codebase

### 5. Produce the grouped report

Print a structured report to the terminal. Use this format:

```
# PR Comment Review: #<NUMBER> — <TITLE>

<N> comments reviewed (<M> skipped). Summary: <1 sentence overview>

---

## Implement (<count>)
Comments that are valid, in scope, and not already handled. Prioritise these.

### 1. [<file>:<line>] <reviewer>
> "<comment text, truncated to ~120 chars>"

Verdict: Implement
Scope: In scope | Technical: Correct | Coverage: Not handled
Rationale: <1-2 sentences — why this matters and what to do>

---

## Discuss (<count>)
Comments with conflicting signals, low confidence, or architectural opinions that need a conversation before acting.

### 2. [<file>:<line>] <reviewer>
> "<comment text>"

Verdict: Discuss
Scope: <ruling> | Technical: <ruling> | Coverage: <ruling>
Rationale: <1-2 sentences — what the disagreement or ambiguity is>
Suggested response: <1 sentence — what you'd say to the reviewer>

---

## Reject (<count>)
Comments that are out of scope, technically wrong, already handled, or purely subjective. You do not need to implement these.

### 3. [PR-level] <reviewer>
> "<comment text>"

Verdict: Reject — <Rejection reason>
Scope: <ruling> | Technical: <ruling> | Coverage: <ruling>
Rationale: <1-2 sentences — why this is being rejected>
Suggested response: <1 sentence — polite reply to leave on the PR>

---

## Quick reference table

| # | File:Line | Reviewer | Verdict | Rejection reason |
|---|-----------|----------|---------|-----------------|
| 1 | auth.py:42 | alice | Implement | — |
| 2 | utils.py:17 | bob | Reject | Out of ticket scope |
| 3 | (PR-level) | carol | Discuss | — |
```

Note: Implement entries do not include a `Suggested response` — no reply to the reviewer is needed when you are acting on their comment.

## Notes on tone

When rejecting a comment, the rationale should be specific and evidence-based. When suggesting a reply, keep it collegial: acknowledge the point, explain the decision.
