---
name: mr-breakdown
description: Thorough commit-by-commit MR review using GitLab CLI. Finds bugs, architectural issues, and code quality problems. Use when reviewing someone else's MR or performing pre-merge review.
user_invocable: true
allowed-tools: Bash(glab:*), Bash(git:*), Bash(jq:*), Bash(wc:*), Read, Grep, Glob, Agent, Write
---

# MR Breakdown Review

Deep commit-by-commit MR review. Finds real bugs, not style nits.

## Input

`/mr-breakdown <MR_NUMBER_OR_URL>`

Extract MR number from URL or use directly. If no arg, ask user.

## Phase 1: Reconnaissance (single batch)

Run these in parallel:

```bash
# MR overview
glab mr view <N> 2>/dev/null | head -40

# Commit list (chronological)
glab api projects/engineering%2Fmonorepo/merge_requests/<N>/commits 2>/dev/null | jq -r '.[] | "\(.short_id) \(.title)"'

# Total file count
glab api "projects/engineering%2Fmonorepo/merge_requests/<N>/diffs?per_page=100" 2>/dev/null | jq length
```

If file count = 100, fetch page 2+ to get full count. Report to user: `Reviewing MR !<N>: "<title>" — <X> files, <Y> commits`.

## Phase 2: Commit-by-commit review

Fetch the branch and get full commit hashes:

```bash
git fetch origin <branch> -q 2>/dev/null
git log --format="%H %s" --reverse main..origin/<branch> 2>/dev/null
```

### Per-commit strategy

For each commit (oldest first):

1. **Get stat first** — `git show --stat <SHA> | tail -20` to understand scope
2. **Read diff** — `git diff <SHA>^..<SHA> --no-color` — pipe to file for large diffs
3. **For diffs > 500 lines**: split reading into chunks or focus on non-trivial files (skip pure renames, test fixture data, auto-generated)

### What to look for (priority order)

1. **Bugs** — wrong operators, impossible conditions, null/undefined access, broken reactivity, race conditions
2. **Logic errors** — inverted conditions, off-by-one, wrong variable referenced, missing error handling on critical paths
3. **API/protocol misuse** — wrong query syntax, incorrect HTTP methods, mismatched request/response types
4. **Architectural problems** — circular deps, store reads at wrong lifecycle point, SSR/client mismatch
5. **Consistency breaks** — diverges from established patterns without clear reason

### What NOT to flag

- Style preferences without concrete failure modes
- Missing types that TS can infer
- "Could be cleaner" without explaining what breaks
- Missing comments/docs unless genuinely confusing logic

## Phase 3: Sanity check

**Critical step.** Before writing the report, verify every finding:

For each issue found:
1. Read the **final state** of the file on the branch tip: `git show <HEAD_SHA>:<filepath>`
2. Confirm the issue still exists (wasn't fixed in a later commit)
3. If the issue references specific values (operator `~=`, missing map key), verify by reading the actual code
4. Determine which commit introduced it

Drop any issue that doesn't survive verification.

## Phase 4: Report

Write `REVIEW.md` in working directory with this structure:

```markdown
# MR !<N> Review — `<title>`

<1-line summary: file count, commit count, what the MR does>

---

## Commit <N>: `<short_sha>` — <commit message>

### <SEVERITY>: <Issue title>
- **File**: `<relative_path>:<line>`
- <1-3 sentence explanation of what's wrong and why it matters>
- **Fix**: <concrete suggestion> (only for bugs)

---

## Summary

| Severity | Count | Issues |
|----------|-------|--------|
| **Bug** | N | brief list |
| **Medium** | N | brief list |
| **Low** | N | brief list |
```

### Severity levels

- **Bug**: will cause runtime error, wrong data, or broken UI
- **Medium**: won't crash but degrades correctness, testability, or maintainability in measurable ways
- **Low**: inconsistency, minor UX issue, or unnecessary code

## Parallelisation guidance

- Phase 1 calls: all parallel
- Phase 2: process 2-3 commits in parallel when they touch different files
- Phase 3 verification: batch `git show` calls for multiple files in parallel
- Use Agent tool for deep-dive on complex commits (>20 files changed) — dispatch subagent per logical area

## Token efficiency

- `--stat` before full diff — skip commits that are pure renames or config-only
- For large diffs: `> /tmp/mr-commitN.diff` then `head`/`tail` to read in chunks
- `git show <SHA>:<file>` is cheaper than full diff when verifying final state
- Use `grep -n` on diff files to jump to specific patterns
- Never dump full test fixture files or auto-generated code into context
