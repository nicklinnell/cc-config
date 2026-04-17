---
name: verify-design
description: Use when the user wants to verify the app UI against a Figma design, asks "verify the design", "compare to Figma", "check against the spec", "does this match Figma", or provides a Figma URL alongside a request to check or review the current screen. Takes priority over simulator-snapshot when a Figma URL or the words "Figma", "design", or "spec" are present.
---

# verify-design

Orchestrate the full feedback loop: capture the running app UI, compare it to the Figma design, and optionally verify DB state.

## Requires

- Figma MCP configured in `.claude/settings.local.json`
- `simulator-snapshot` skill available

## Inputs

- **Figma URL** (required): node-level URL, e.g. `figma.com/design/:fileKey/...?node-id=:nodeId`
- **platform** (optional): `ios` | `android` | `both` (default: `both`)
- **DB check** (optional): table name or SQL query. If omitted, Claude infers from context.

## Steps

### 1. Capture simulator screenshots

Run the `simulator-snapshot` skill. If it fails, surface its error and stop.

### 2. Fetch Figma design context

Parse the Figma URL to extract `fileKey` and `nodeId` (convert `-` to `:` in nodeId).

Call `get_design_context` with the fileKey and nodeId.

**Error: Figma MCP not configured** — surface: "Figma MCP is not set up. Add it to `.claude/settings.local.json` and restart Claude Code."

**Error: malformed URL** — surface: "Could not parse Figma node URL. Provide a URL containing `?node-id=`."

### 3. Compare and report

With both the simulator screenshot and Figma design in context, report:

- Layout discrepancies (spacing, alignment, sizing)
- Typography differences (font, size, weight, colour)
- Colour differences (background, text, borders)
- Missing or extra elements

Be specific: "Toggle spacing is 8px in the app vs 12px in the design" is better than "spacing looks off".

### 4. DB verification (optional)

If the user mentioned a table or query, or if the feature clearly writes to a specific table, run a Supabase query to confirm data was saved correctly.

Default query pattern:
```sql
SELECT * FROM <inferred_table> ORDER BY created_at DESC LIMIT 5;
```

The user can override: "check the `engine_modes` table" or provide SQL directly.

**If Supabase MCP is not connected:** skip this step and note it in the report.

## Report format

```
## Visual comparison: <screen name>

### Matches
- [what looks correct]

### Discrepancies
- [specific difference with values where possible]

### DB state (if checked)
- [query run + result summary]
```
