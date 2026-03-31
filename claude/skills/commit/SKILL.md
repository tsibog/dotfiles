---
name: commit
description: Create a git commit with formatter, message generation, and user confirmation
---

# Commit Workflow

I generate commit messages, get confirmation, then commit.

## My Principles

- I never mention Claude or add Co-Authored-By attribution
- I always show the user the full message before committing
- I never commit without user confirmation
- I always use heredoc format to preserve message formatting
- I respect line length limits: 50 chars for subject (hard limit 72), 72 chars for body

## What I Do

### 0. Resolve Paths

CWD may not be the git root or the console project root. Resolve both upfront:

```bash
GIT_ROOT=$(git rev-parse --show-toplevel)
CONSOLE_ROOT="$GIT_ROOT/src/private/console"
```

All git commands use `git -C "$GIT_ROOT"`. All pnpm/prettier commands run from `$CONSOLE_ROOT`. All file paths passed to `git add` are relative to `$GIT_ROOT`.

### 1. Format Changed Files

I format first, before anything else. Run from `$CONSOLE_ROOT`:

```bash
cd "$CONSOLE_ROOT" && pnpm prettier -w file1.svelte file2.ts file3.ts
```

File paths passed to prettier are relative to `$CONSOLE_ROOT` (strip the `src/private/console/` prefix from git's output).

### 2. Gather Context

I run these in parallel (all using `git -C "$GIT_ROOT"`):

- `git status` - see all changes
- `git diff --staged` - staged changes
- `git diff` - unstaged changes
- `git log --oneline -10` - recent commits for style

### 3. Generate Message

I follow this template:

```
Console: very brief description

<BODY - 2-3 sentences max>
```

I add `Test: pnpm run test` only if relevant testing info is needed.

**How I write the body:**

- Brief and casual - 2-3 sentences maximum
- WHY-focused - I explain the problem solved, not implementation details
- No detailed change lists or bullet points
- If referencing Jira ticket: `Issue: CNS-1234` or `Issue: TNK-456`

### 4. Ask Confirmation

Use `AskUserQuestion` with the `preview` field on each option so the commit message is visible in the side panel. All three options get the same preview (the full commit message):

- **Commit** - proceed with this message (preview: the commit message)
- **Edit message** - provide a custom message (preview: the commit message)
- **Cancel** - abort (preview: the commit message)

### 5. Execute Commit

Only if approved, I:

- Stage files using paths relative to git root: `git -C "$GIT_ROOT" add <files>`
- Commit using heredoc format:

```bash
git -C "$GIT_ROOT" commit -m "$(cat <<'EOF'
{message here}
EOF
)"
```

- Run `git -C "$GIT_ROOT" status` to verify
