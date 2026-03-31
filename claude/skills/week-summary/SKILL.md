---
name: week-summary
description: Generate weekly work summary from git commits and GitLab MRs for team updates
allowed-tools: Bash, Write, TodoWrite
---

# Week Summary Skill

Generate weekly work summary from Monday of current week to now for engineering managers and team leads.

## Workflow

### Phase 1: Data Collection

1. Check glab auth status: `glab auth status` (silently handle if expired)
2. Calculate Monday of current week
3. Get user's MRs from GitLab directly: `glab mr list --author=@me --per-page=100`
4. Filter MRs by date (created/merged since Monday)
5. Get user's git commits without MR refs for local work context

### Phase 2: Analysis

1. For each MR from GitLab:
   - Parse state (merged/open)
   - Parse title
   - Group by theme/area (not by MR number)
2. Identify work themes from commit messages

### Phase 3: Output Generation

Write `week-summary-YYYY-MM-DD.md` in current working directory. Use plain text (no markdown) — ready to paste into an email.

**Structure:**

```
Week Summary — <Monday Date> to <Friday Date>


Shipped

[Theme/Area Name]
- What was addressed/fixed/created in general terms
- Outcome-focused descriptions
- Group related work together

[Another Theme]
- More outcomes


In Progress

[Theme]
- Current work items


Up next
- High-level upcoming work
- Themes or focus areas


Summary: One-line recap of main focus areas
```

## Key Commands

**Check glab auth:**

```bash
glab auth status 2>&1
```

**Get Monday of week:**

```bash
date -v -$(($(date +%u) - 1))d +%Y-%m-%d  # macOS
date -d "monday this week" +%Y-%m-%d  # Linux
```

**List merged MRs:**

```bash
glab mr list --author=@me -M --per-page=100 2>&1
```

**List open MRs:**

```bash
glab mr list --author=@me --per-page=100 2>&1
```

**Get MR details:**

```bash
glab mr view <number> --output=json 2>&1 | jq -r '.merged_at'
```

## Writing Style

**Executive summary tone:**

- Theme-based grouping, not MR-based
- Outcome-focused: what was addressed/fixed/created
- No counting (don't mention "6 MRs" or quantities)
- Conversational, not bullet-point heavy
- General terms over specific technical details

**Sections:**

- `Shipped` - What was completed, grouped by theme
- `Up next` - Forward-looking, high-level upcoming work
- `Summary` - One-line recap of main focus

**Avoid:**

- Listing MR numbers or counts
- Technical implementation details
- Branch names
- "In Progress" sections with specifics
- Overly structured or verbose descriptions
