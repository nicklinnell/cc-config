---
name: review-pr
description: Review a GitHub pull request by number. Creates a git worktree from the PR's branch, analyses all changed files for security issues, bugs, code quality problems, and performance concerns, then prints a structured report with file paths and line numbers. Use this skill whenever the user says "review PR", "review pull request", "/review-pr", "check PR", "look at PR", or provides a PR number and wants code review. Also trigger when the user mentions they want to audit, inspect, or analyse a pull request.
---

# PR Review

Review a pull request by fetching the diff, reading all changed files, and producing a structured findings report with severity levels, type tags, and specific line number citations.

## Argument

The user provides a PR number, e.g. `/review-pr 123` or "review PR 123". Extract the number from wherever it appears.

## Workflow

### 1. Fetch PR metadata

```bash
gh pr view <PR_NUMBER> --json number,title,headRefName,baseRefName,author,body
```

This gives you the branch name (`headRefName`) and base branch (`baseRefName`).

### 2. Get the full diff

```bash
gh pr diff <PR_NUMBER>
```

Parse the unified diff to identify:
- Which files changed
- Which line numbers were added (lines starting with `+`, excluding `+++`)

Focus the review on **added and modified lines** — removed lines are gone and rarely need review.

### 3. Set up an isolated view (optional but preferred)

If Bash is available, create a worktree so you can read the full files in their final state from an isolated copy:

```bash
git fetch origin
git worktree add /tmp/review-pr-<PR_NUMBER> origin/<headRefName>
```

Read files from `/tmp/review-pr-<PR_NUMBER>/<file_path>`.

If Bash is not available or the worktree command fails, skip this step and read files directly from the current working directory — the diff gives you all the context needed to locate issues.

### 4. Read changed files

For each changed file in the diff, read the **full file** (not just the diff chunk). Full context is essential — many bugs and security issues only become visible when you can see how a function is called, what imports are present, or how data flows through the module.

### 5. Review each file

For every changed file, look for issues in these four categories:

**Security**
- Injection vulnerabilities (SQL, shell, LDAP, XPath)
- Authentication/authorisation bypasses
- Hardcoded secrets, tokens, or credentials
- Insecure defaults (CORS *, verify=False, eval, pickle)
- Sensitive data logged or exposed in error messages
- Path traversal, open redirect, SSRF
- Missing input validation at system boundaries

**Bugs**
- Logic errors and off-by-one mistakes
- Unhandled error cases or swallowed exceptions
- Incorrect null/None handling
- Race conditions or missing locks
- Wrong variable used, copy-paste errors
- Misuse of async/await

**Code Quality**
- Functions doing too many things (violates single responsibility)
- Deep nesting that obscures control flow
- Misleading names that contradict what code actually does
- Magic numbers/strings without explanation
- Dead code included in the PR
- Missing edge-case handling that will obviously be needed

**Performance**
- N+1 query patterns
- Unnecessary repeated computation inside loops
- Loading large datasets into memory when streaming would work
- Missing database indexes for new query patterns
- Blocking I/O on async paths

### 6. Clean up worktree (if created)

```bash
git worktree remove /tmp/review-pr-<PR_NUMBER> --force
```

### 7. Generate the report

Print the report to the terminal. Use this structure exactly:

```
# PR Review: #<NUMBER> — <TITLE>
Author: <author>   Branch: <headRefName> -> <baseRefName>

## Summary
<N> issue(s) found across <M> file(s) reviewed. <1-2 sentence human overview of the PR's purpose and overall quality — e.g. "The implementation is clean overall, with one significant gap in the soft-delete filtering logic.">

## Findings

### High severity
(or "No high-severity issues." if none)

#### [<type>] <short description> — `<file_path>:<line_number>`

<1-2 sentences written as an inline code review comment at that line — concise, direct, addressed to the author. State what's wrong and what to do instead. Assume the author knows the codebase; no need to over-explain.>

### Medium severity
...

### Low severity
...
```

**Severity guide:**
- **High** — exploitable security flaw, data loss risk, crash in normal operation
- **Medium** — incorrect behaviour under realistic conditions, latent security weakness, significant performance regression
- **Low** — code quality concern, minor inefficiency, style issue with real maintenance impact

**Line numbers:** Always cite the line number from the changed file where the issue appears. If the issue spans a range, cite the first line. The citation goes in the finding heading: `file.py:42`.

**Finding tone:** Write each finding as if leaving an inline comment on that exact line in a GitHub PR — short, human, addressed to the author. State the problem and the fix in one or two sentences. Don't pad with background explanation the author already knows.

**Be specific, not generic.** "This could cause a SQL injection" with no code reference is useless. Name the exact variable or function and say what goes wrong. If you find nothing genuinely wrong with a file, skip it — don't list it anywhere.
