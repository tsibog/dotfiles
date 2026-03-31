---
name: create-mr
description: Create GitLab MR with auto-generated description, assignee, and reviewers
---

# GitLab MR Creation Workflow

I create GitLab merge requests with auto-generated titles and descriptions.

## My Principles

- I never create an MR without user confirmation
- I always copy the Slack message to clipboard after MR creation - this is essential, not optional
- I always auto-assign to the current user
- I always request review from bsaxon, hkitz, rdevane, oturner
- I always target main branch
- I auto-push if the branch isn't already pushed
- I wrap syntax terms in backticks naturally (functions, variables, components, file names, CLI commands)
- I keep descriptions casual and WHY-focused
- I respect title max 72 chars

## What I Do

### Phase 0: Resolve Paths

CWD may not be the git root. Resolve upfront:

```bash
GIT_ROOT=$(git rev-parse --show-toplevel)
```

All git commands use `git -C "$GIT_ROOT"`.

### Phase 1: Analysis

I run these as **separate** commands (not chained with `&&`/`||` in one block):

```bash
git -C "$GIT_ROOT" branch --show-current
```

```bash
git -C "$GIT_ROOT" rev-parse --abbrev-ref @{upstream} 2>/dev/null || echo "NOT_PUSHED"
```

```bash
git -C "$GIT_ROOT" log origin/main..HEAD --oneline
git -C "$GIT_ROOT" log origin/main..HEAD --format="%B"
git -C "$GIT_ROOT" diff --stat origin/main..HEAD
git -C "$GIT_ROOT" log origin/main..HEAD --format="%B" | grep -o 'Issue: [A-Z]\+-[0-9]\+' | cut -d' ' -f2 | sort -u
```

I analyze for:

- Current branch name
- Whether branch is pushed to remote
- All commits on branch
- Full commit messages
- Changed files summary
- Issue keys referenced in commits (e.g., CNS-1412, TNK-456)

### Phase 2: Generate & Confirm

**Title Generation** (max 72 chars):

I synthesize from all commits on branch - action verb + concise outcome:

- "Console: Fix button keyboard navigation"
- "Console: Add metrics export feature"
- "Console: Refactor alert dialog components"

**Description Generation**:

```markdown
{Flowing narrative, 1-2 paragraphs. Reads like a human explaining to a colleague what was wrong and what we did about it. Naturally weaves together the problem, root cause, and what changed — no rigid separation between "context" and "changes".}

Issue: {ISSUE_KEYS}
```

**How I write descriptions:**

- NO markdown headers, bullet points, dashes, or test plans
- Casual, flowing prose, like explaining the change to a teammate
- Weave problem + root cause + fix into a natural narrative, not separate sections
- NEVER use em-dashes (—). Use commas, periods, or parentheses instead.
- Wrap syntax terms in backticks naturally (`$state`, `resourceVersion`, `DetachSecurityGroupButton`)
- 1-2 paragraphs, not a wall of text
- If commits contain `Issue: XXX-###`, I extract and include as `Issue: CNS-1412 TNK-456`
- If no issues found, I omit the "Issue:" line entirely

**Confirmation**

I present to user:

```
Title: {generated title}

Description:
{generated description}

Assignee: {current user}
Reviewers: @bsaxon, @hkitz, @rdevane, @oturner
Target: main
```

Use `AskUserQuestion` with the `preview` field on each option showing the full MR draft (title, description, assignee, reviewers, target):

- **Create MR** - proceed with glab CLI
- **Edit title** - let user provide modified title
- **Edit description** - let user provide modified description
- **Cancel** - abort

If user selects edit options, I loop back with updated content.

### Phase 3: Execute

Only if approved:

**1. Push branch if needed:**

```bash
# Only if upstream check returned NOT_PUSHED in Phase 1
git -C "$GIT_ROOT" push -u origin $(git -C "$GIT_ROOT" branch --show-current)
```

**2. Get current username:**

```bash
glab api user | jq -r '.username' 2>/dev/null || glab api user | grep -o '"username":"[^"]*"' | cut -d'"' -f4
```

**3. Create MR:**

```bash
glab mr create \
  --title "{title}" \
  --description "{description}" \
  --assignee "{current_username}" \
  --reviewer "bsaxon,hkitz,rdevane,oturner" \
  --target-branch "main" \
  --yes
```

**4. Move Jira tickets to In Review:**

If issue keys were found in Phase 1:

```bash
jira issue move [TICKET_KEY] "Started" && jira issue move [TICKET_KEY] "Under review"
```

Jira requires two transitions: "Started" first, then "Under review" becomes available. If already started, the first move may fail — that's fine, try "Under review" regardless. If both fail, note it but continue.

**5. Copy Slack message to clipboard:**

```bash
MERGE_BASE=$(git -C "$GIT_ROOT" merge-base origin/main HEAD)
STATS=$(git -C "$GIT_ROOT" diff --shortstat $MERGE_BASE..HEAD)
INS=$(echo "$STATS" | grep -oE '[0-9]+ insertion' | grep -oE '[0-9]+' || echo "0")
DEL=$(echo "$STATS" | grep -oE '[0-9]+ deletion' | grep -oE '[0-9]+' || echo "0")
BRIEF="Brief description here"
printf "MR: %s \`+%s | -%s\`\n%s" "$BRIEF" "$INS" "$DEL" "$MR_URL" | pbcopy
```

Format: `MR: {brief description} \`+X | -Y\`\n{MR_URL}`

- I use `git merge-base origin/main HEAD` for correct diff (only this branch's changes)
- Brief description: derived from title, remove prefix like "Console: "
- Line diff in backticks
- MR URL on second line

**6. Display result:**

- Show MR URL from glab output
- Confirm: "Assigned to you, reviewers: @bsaxon, @hkitz, @rdevane, @oturner"
- Confirm Jira tickets moved to In Review (if applicable)
- Confirm: "Slack message copied to clipboard"

## Edge Cases

**No commits on branch:**

- I alert user that branch has no commits beyond main
- I ask if they want to proceed with manual title/description
- If yes, I prompt for both via AskUserQuestion

**Branch already has MR:**

- I check with `glab mr list -s $(git branch --show-current)`
- If MR exists, I alert user and show existing MR URL
- I ask if they want to open existing MR or create another

**Not authenticated with glab:**

- I check `glab auth status`
- If not authenticated, I instruct user to run `glab auth login`

**Push fails:**

- If `git push` fails, I show the error and suggest manual resolution
