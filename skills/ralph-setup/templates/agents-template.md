# AGENTS.md Template

Use this template to generate project-specific AGENTS.md files. Replace placeholders with detected commands.

---

# AGENTS.md

Operational reference for autonomous development. Commands only - no status updates.

## Build

```bash
{build-command}
```

## Test

**Full suite:**
```bash
{test-command}
```

**Targeted (single file):**
```bash
{targeted-test-command} {path}
```

**Watch mode (if available):**
```bash
{test-watch-command}
```

## Lint

```bash
{lint-command}
```

**Auto-fix:**
```bash
{lint-fix-command}
```

## Typecheck

```bash
{typecheck-command}
```

## Format

```bash
{format-command}
```

## Patterns

### Project Structure

```
{detected-structure}
```

### Code Conventions

- {convention-1}
- {convention-2}
- {convention-3}

### Test Patterns

- Test files: `{test-file-pattern}`
- Test naming: `{test-naming-convention}`
- Mocking: `{mocking-approach}`

---

## Placeholder Values by Language

### Node.js (npm/yarn/pnpm/bun)

**Build:** `npm run build` / `yarn build` / `pnpm build` / `bun run build`
**Test:** `npm test` / `yarn test` / `pnpm test` / `bun test`
**Targeted test:** `npm test -- {path}` / `yarn test {path}` / `bun test {path}`
**Lint:** `npm run lint` / `eslint .` / `biome check .`
**Lint fix:** `npm run lint -- --fix` / `eslint . --fix` / `biome check . --write`
**Typecheck:** `npx tsc --noEmit` / `npm run typecheck`
**Format:** `prettier --write .` / `biome format . --write`

### Python

**Build:** `pip install -e .` / `poetry install`
**Test:** `pytest` / `python -m pytest`
**Targeted test:** `pytest {path}` / `pytest -k {name}`
**Lint:** `ruff check .` / `flake8`
**Lint fix:** `ruff check . --fix`
**Typecheck:** `mypy .` / `pyright`
**Format:** `ruff format .` / `black .`

### Go

**Build:** `go build ./...`
**Test:** `go test ./...`
**Targeted test:** `go test {package}` / `go test -run {name}`
**Lint:** `golangci-lint run`
**Lint fix:** `golangci-lint run --fix`
**Typecheck:** (included in build)
**Format:** `gofmt -w .` / `goimports -w .`

### Rust

**Build:** `cargo build`
**Test:** `cargo test`
**Targeted test:** `cargo test {name}`
**Lint:** `cargo clippy`
**Lint fix:** `cargo clippy --fix`
**Typecheck:** (included in build)
**Format:** `cargo fmt`
