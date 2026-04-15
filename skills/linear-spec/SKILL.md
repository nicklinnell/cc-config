---
name: linear-spec
description: Generate a high-level specification summary for a Linear ticket, formatted for pasting into the ticket description. Use this skill whenever the user says "linear-spec", "write spec for", "generate spec", "create specification summary", or provides a Linear ticket ID (e.g. CAR-123) and wants a structured technical breakdown. The output is always printed to screen only — never written to Linear automatically.
---

## Your task

Generate a high-level specification summary for the Linear ticket provided as an argument.

## Steps

1. **Fetch the ticket** — use the Linear MCP tool to get the full ticket details including description, title, and any attachments.

2. **Find the plan file** — check `docs/superpowers/plans/` for a file matching the ticket ID (e.g. `*car-589*`). If one exists, read it — it contains detailed implementation notes that will enrich the spec. If none exists, rely on the ticket and your codebase knowledge.

3. **Generate the spec** — write a concise specification summary using the format below.

4. **Print to screen only** — output the spec as a markdown code block so the user can copy and paste it into the Linear ticket manually. Never call any Linear write tools.

---

## Output format

The spec must follow this exact structure, modelled on a real example. Start with a one-sentence summary of what the feature does, then use the sections below. **Only include a section if it is relevant** — omit sections that don't apply (e.g. no "Notifications" section if there are no notifications).

```
<one-sentence summary of what the feature does and who it's for>

### Database Changes

* <change 1>
* <change 2>
* (or: "None.")

### API Changes

New endpoints:

* METHOD /path — description

Modified endpoints:

* METHOD /path — what changes and why

Permissions: (only if relevant)

* Create: ...
* Update: ...
* Delete: ...

### Mobile App Changes

* <screen or component change>
* <new component>
* <behaviour change>

### Notifications (omit if not applicable)

* <notification type and trigger>
* New activity type: ACTION_TYPE_NAME

### Content Safeguards (omit if not applicable)

* <safety rule>

### Out of Scope

* <deferred feature>
* <explicit exclusion>
```

---

## Style rules

**Write at specification level, not implementation level.** The spec describes what the product does and what users experience — not how the code is written internally. A developer reading the spec should understand the feature; they don't need to know which Redux reducer handles it or what the component's prop types are.

- **API Changes**: name the actual endpoint paths and describe what they do. Schema field names are fine (they're part of the contract). Internal service methods, helper functions, or file names are not.
- **Mobile App Changes**: describe what users see and what they can do — new screens, UI controls, visible behaviours. Do not list state management details, Redux actions/reducers/selectors, component prop names, or file paths.
- **Database Changes**: column names and types are appropriate (they're part of the data model). Migration file names are not.
- Use present tense ("Returns paginated list", not "Will return")
- Each bullet is one distinct change or decision — don't combine multiple things in one bullet
- Keep bullets short (one line where possible)
- Mirror the tone of the example: terse, readable, scannable
- "Out of Scope" is always the last section — include it even if it's just one item

**Good vs bad examples for Mobile App Changes:**

Good (user-facing, functional):
* Scrollable feed of recent public carvatars, each showing owner name, like count, car photo, and most recent comment
* Horizontal "Upcoming Events" strip below the second feed card
* Unauthenticated users see featured carvatars with a sign-in prompt

Bad (implementation detail):
* New HomeFeedList container replaces FeaturedCarvatarList
* Feed state added to carvatar Redux slice: feedCarvatars, isFeedRefreshing, feedHasMore
* New selectors: selectFeedCarvatars, selectIsFeedRefreshing

---

## Example (CAR-583 — use as a style reference, not content)

> Allow authenticated users to add text-only pin drops to Carvatars they don't own. Owners can delete community pins; community authors can edit/delete their own.
>
> ### Database Changes
> * Add `is_community` boolean to `pindrops` table (default: false)
> * Add `community_pindrop_notifications` boolean to `user_profiles` (default: true)
> * Community pins hard-delete with Carvatar or if author deletes account
>
> ### API Changes
> Modified endpoints:
> * `GET /pindrops` — add `type` filter: owner | community | all
> * `POST /pindrops` — add `is_community` field; validate caller is NOT owner for community pins
> * `DELETE /pindrops/{id}` — author OR Carvatar owner can delete
>
> Permissions:
> * Create: any authenticated user (unless blocked by owner)
> * Update: author only
> * Delete: author or Carvatar owner
>
> ### Mobile App Changes
> * Different pin marker colour for community pins in 3D viewer
> * Segmented filter control: Owner | Community | All (default: Owner)
> * "Add Pin" button when viewing others' Carvatars
>
> ### Notifications
> * Push notification to owner when community pin is created (if enabled)
> * New activity type: `COMMUNITY_PINDROP_CREATED`
>
> ### Content Safeguards
> * Users blocked by the owner cannot create community pins
> * Community pins from blocked users are hidden from the current user
>
> ### Out of Scope
> * Reporting/flagging system
> * Rate limiting
> * Per-Carvatar community pin settings
