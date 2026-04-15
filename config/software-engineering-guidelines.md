---
name: software-engineering-guidelines
description: Enforces software engineering best practices for code quality and maintainability. Use when writing production code, reviewing pull requests, designing system architecture, refactoring legacy code, or making technical decisions. Triggers on code review requests, architecture discussions, refactoring tasks, dependency decisions, error handling patterns, or testing strategy questions.
---

# Software Engineering Standards

Core principles for production code quality.

## Core Principles

- Clarity > cleverness. Explicit > implicit. Maintainability first.
- Use standard library before adding dependencies.
- Make it work → make it right → make it fast.
- Ship practical solutions over theoretical perfection.

## Problem-Solving Approach

1. Check standard library/existing code first
2. Start with straightforward linear logic
3. Extract abstractions only after 3rd duplication (Rule of Three)
4. Question requirements before adding complexity
5. Optimise only with profiling data

## Design Patterns

- **Naming**: Descriptive, self-explanatory
- **Control flow**: Early returns over deep nesting
- **Functions**: Single responsibility, one thing well
- **Composition** over inheritance
- **Coupling**: Minimise cross-module dependencies
- **Structure**: Start flat, add hierarchy only when needed
- Direct function calls before events/messaging

## Dependencies

- Can standard library/existing dependencies solve this?
- Every dependency = maintenance + security risk
- Prefer: mature, active, focused libraries over frameworks
- Don't add unless explicitly needed

## Error Handling & Logging

- **Expected errors**: Use Result types/error values when idiomatic
- **Unexpected errors**: Let bubble to logging boundary
- **Messages**: Clear, actionable, with context (no secrets/PII)
- **User-facing**: Never expose stack traces/internals
- **Logging**: Include IDs, types, key inputs for debugging

## Performance

- Correctness first, then optimise bottlenecks with metrics
- Consider Big-O before micro-optimisations
- Comment non-trivial optimisations with rationale

## Testing Strategy

- Test public interfaces and observable behaviour
- **Skip**: Trivial assertions, "does not crash" tests
- **Priority**: 1) Happy paths 2) Edge cases 3) Failure modes
- One behaviour per test with clear names
- **Structure**: Arrange → Act → Assert
- Mock I/O/external services, not pure logic
- Keep tests fast

## Documentation

- **Comments**: Explain why, not what
- **README**: Purpose, setup, usage, key concepts
- **APIs**: JSDoc/docstrings with examples
- Keep in sync; don't document non-existent features

## Security Checklist

- Validate all external input
- Use least privilege
- No hardcoded secrets (use env/secret manager)
- Avoid unsafe defaults (verify: false, wide CORS, eval)
- Check dependency vulnerabilities

## Production Readiness

- Structured logging with correlation IDs
- Make errors traceable
- Avoid magic/hidden side effects

## Legacy Code

- Incremental improvements over rewrites
- Add characterisation tests before changes
- Leave code better than found: refactor, clarify, reduce duplication
