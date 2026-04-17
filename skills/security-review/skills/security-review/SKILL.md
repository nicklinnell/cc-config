---
name: security-review
description: Review changed code for security vulnerabilities. Use when the user says "security review", "check security", "/security-review", or before committing code. Checks for OWASP Top 10, injection, auth issues, secrets, and unsafe defaults.
---

# Security Review

Scan all code changed in the current session for security vulnerabilities. Produce a structured findings report.

## Workflow

### 1. Identify changed files

Use `git diff --name-only` and `git diff --cached --name-only` to find all modified and staged files. Also check `git status` for untracked files that were created this session.

Filter to source code files only (skip images, lock files, generated files).

### 2. Read and analyse each changed file

For each file, read the full contents and check for:

**Injection**
- SQL injection (string concatenation in queries, missing parameterisation)
- Command injection (unsanitised input in shell commands, exec, eval)
- XSS (unescaped user input in HTML/templates, dangerouslySetInnerHTML)
- Path traversal (user input in file paths without sanitisation)

**Authentication & Authorisation**
- Missing auth checks on endpoints
- Hardcoded credentials, API keys, tokens, passwords
- Secrets in source code or config committed to git
- Weak or missing CSRF protection
- Permissive CORS configuration

**Data Exposure**
- Sensitive data in logs (PII, tokens, passwords)
- Stack traces or internal errors exposed to users
- Overly broad API responses leaking internal fields

**Unsafe Defaults**
- `verify: false` on TLS/SSL
- `eval()` or equivalent dynamic code execution
- Disabled security headers
- Wide-open permissions (chmod 777, world-readable)
- Missing input validation at system boundaries

**Dependencies**
- New dependencies added without clear justification
- Known vulnerable package versions (flag for manual check)

**Cryptography**
- Weak algorithms (MD5, SHA1 for security purposes)
- Hardcoded IVs or keys
- Custom crypto implementations

### 3. Output report

Structure findings as:

```
## Security Review

### [CRITICAL/HIGH/MEDIUM/LOW] <title>
**File:** `path/to/file.ext:line`
**Category:** <category from above>
**Finding:** <what the issue is>
**Fix:** <specific remediation>
```

If no issues found, report: "No security issues found in changed files."

### 4. Summary

End with a one-line summary: number of findings by severity, or clean bill of health.
