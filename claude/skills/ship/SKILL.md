---
name: ship
description: Ship work end-to-end by chaining /ticket → /commit or /commit-split → /create-mr
---

# Ship Workflow

I chain the existing skills in sequence. Each sub-skill owns its own behavior — I just orchestrate.

## Flow

### Step 0: Check branch

```bash
git branch --show-current
```

If on `main`, prompt the user to create a new branch. Suggest a name starting with `dand/console-` followed by a brief kebab-case description of the work (e.g., `dand/console-fix-object-uri-encoding`). Create the branch after confirmation.

### Step 1: Analyze branch state

```bash
git diff --stat origin/main..HEAD
git log --oneline origin/main..HEAD
git diff --stat
git status --short
```

From this I determine:

- Whether there are uncommitted changes that need committing
- Whether commits already exist on the branch
- Whether to suggest `/commit` or `/commit-split`

**Commit vs commit-split heuristic:**

- If uncommitted changes touch unrelated areas (e.g., different features, separate bug fixes) → suggest `/commit-split`
- If all changes are related to a single concern → suggest `/commit`
- If commits already exist and nothing is uncommitted → skip commit step entirely
- Present the suggestion to the user, let them decide

### Step 2: Ask for board

Ask which Jira board (CNS or TNK) via AskUserQuestion — this is the only input I need before kicking off the chain. The sub-skills handle their own prompts.

### Step 3: Execute chain

1. **`/ticket`** on the chosen board — skill handles description generation and confirmation
2. **`/commit`** or **`/commit-split`** — skill handles formatting, message generation, and confirmation. Pass the ticket key from step 1 so it's included in the Issue line.
3. **`/create-mr`** — skill handles title/description generation, push, reviewers, Slack message, and confirmation

Each skill runs its own approval loop. I pass context forward (ticket key → commit → MR) but don't duplicate any logic.

## When to use

- Default workflow when done with a chunk of work
- Replaces manually running `/ticket` → `/commit` → `/create-mr` in sequence

## When NOT to use

- If you've already done some steps (e.g., already committed) — just run the remaining skills directly
- If you want to skip a step (e.g., no ticket needed) — run individual skills
