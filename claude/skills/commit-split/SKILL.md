---
name: commit-split
description: Split changes into atomic commits with formatting. Use when you have multiple unrelated changes that should be separate commits.
---

# Commit Split Workflow

## Template

```
Console: {brief description}

{Casual body - omit obvious details, focus on why/impact}

Issue: TNK-###
Test: pnpm run test
```

## Workflow

### Phase 0: Format Changed Files

**CRITICAL: Format FIRST before any other steps.**

Format only changed files:

```bash
pnpm prettier -w file1.svelte file2.ts file3.ts
```

Pass all modified/unstaged files explicitly to format them.

### Phase 1: Analyze Changes

1. Run `git diff` to see unstaged changes
2. Identify logical groupings (related functionality, similar refactors)
3. Consider file relationships and dependencies

### Phase 2: Propose Atomic Commits

Group changes following these principles:

**Group together:**

- Same functionality across files (e.g., Form.Label standardization in ModelForm.svelte + SizeSlider.svelte)
- Related utils and their usage (e.g., name-generation.ts + ModelNameInput.svelte changes)
- Component refactors (e.g., moving fields within single component)

**Split apart:**

- Unrelated features (e.g., ButtonIcon refactor vs ModelsTable new feature)
- Different issue numbers (TNK-340 vs TNK-336)
- Different concerns (UI changes vs business logic)

### Phase 3: Create Commits

Present proposed commits to user before executing:

```
Commit 1: Console: {description}
- file1.svelte
- file2.svelte
Issue: TNK-###

Commit 2: Console: {description}
- file3.svelte
Issue: TNK-###
```

### Phase 4: Reformat Existing Commits (if needed)

Use interactive rebase to reword commits:

```bash
# Start rebase from parent of first commit to reword
GIT_SEQUENCE_EDITOR="sed -i.bak 's/^pick/edit/'" git rebase -i <parent-hash>

# For each commit:
git commit --amend -m "$(cat <<'EOF'
Console: {title}

{body}

Issue: TNK-###
Test: pnpm run test
EOF
)"
git rebase --continue
```

## Examples

### Good Commits

```
Console: Use Form.Label component, fix typo

Standardize form labels across ModelForm and SizeSlider components.
Fix typo: "Availble Models" → "Available Models"

Issue: TNK-340
Test: pnpm run test
```

```
Console: Add quick-access actions column for start/stop

Move start/stop actions from dropdown menu to dedicated column with icon buttons
for improved discoverability and faster access.

Issue: TNK-336
Test: pnpm run test
```

### Bad Commits (avoid)

```
❌ TNK-340: fix labels
(Missing Console prefix, no body explaining why)

❌ Console: Update files
(Too vague, no context)

❌ Console: Use Form.Label and refactor ButtonIcon and add ModelsTable actions
(Multiple unrelated changes in one commit)
```

## Rules

- **Always** use "Console:" prefix
- **Never** mention Claude or Claude Code
- **Ask** for Issue # if unknown
- **Run** tests before committing (can be implied, don't need to actually run)
- **Keep** body casual but informative (why/impact, not what - code shows what)
- **Group** related changes, **split** unrelated features
