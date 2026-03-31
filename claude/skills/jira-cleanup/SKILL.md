---
name: jira-cleanup
description: Check Jira tasks assigned to me, cross-reference with GitLab MRs to find merged work still not marked Done, and offer to transition them. Use when user wants to clean up their Jira board, check task status, or sync Jira with merged MRs.
user_invocable: true
allowed-tools: Bash(jira issue list:*), Bash(jira issue move:*), Bash(jira me:*), Bash(glab mr list:*)
---

# Jira Board Cleanup

Efficiently audit assigned Jira tasks against GitLab MR status and transition completed work to Done.

## Steps

### 1. Get assigned issues (single call)

```bash
jira issue list -p CNS -a $(jira me) --status "Under review" --status "Open" --status "In Progress" --plain --columns key,status,summary 2>&1
```

If args fail use: `jira issue list -p CNS -a $(jira me) --plain --columns key,status,summary`

### 2. Batch-check merged MRs (single call)

For all non-Done issues, check merged MRs in one loop:

```bash
for key in KEY1 KEY2 ...; do echo "=== $key ==="; glab mr list --search="$key" -M 2>&1 | head -3; echo; done
```

### 3. Check open MRs for remaining items

For issues without merged MRs, check open MRs in one batch:

```bash
for key in KEY1 KEY2 ...; do echo "=== $key ==="; glab mr list --search="$key" 2>&1 | head -3; echo; done
```

### 4. Present results as table

Show two tables:
- **Should move to Done** — merged MR found, still in non-Done status
- **Still in progress** — open/draft MR or no MR

### 5. Transition on confirmation

After user confirms, move all applicable issues in parallel:

```bash
jira issue move KEY "Done"
```

Run all `jira issue move` calls in parallel using separate Bash tool invocations.

## Key details

- User email: `jira me` (don't hardcode)
- Project: CNS (default, can be overridden via `/jira-cleanup PROJECT`)
- GitLab: use `glab mr list --search="KEY" -M` for merged, no flag for open
- Minimize token usage: `head -3` on mr list output, `--plain` on jira output
- Skip issues already in Done/Canceled status
