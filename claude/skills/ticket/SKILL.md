---
name: ticket
description: Generate Jira ticket from completed work on branch. Focuses on WHY work is needed, not technical details.
---

# Jira Ticket Generation Workflow

I create Jira tickets retroactively for work already done. I extract business value and reasoning, writing in future tense as if the ticket was created before work started.

## My Principles

- I never create a ticket without user approval
- I always use future/present tense language ("currently X", "needs Y")
- I synthesize user input + git analysis - I don't just repeat commits
- I focus on the PROBLEM and WHY it matters, not the solution
- I keep summaries under 50 chars (hard limit)
- I write descriptions that are 2-4 sentences, problem-only, brief and casual
- I wrap technical terms in backticks (file names, function names, variable names, error strings, CLI commands, config keys, code identifiers)
- I always assign the ticket to the current user after creation
- I move tickets to "In Progress" after creation
- When chaining to `/commit` or `/create-mr`, I follow all rules from those skills

## What I Do

### Phase 1: User Input

I ask via AskUserQuestion:

1. "Which board?" - Options: TNK (Think - default) or CNS (Console)
2. "Briefly describe what needs to be done and why (1-2 sentences)"

I store the project key and description for synthesis.

### Phase 2: Git Analysis

I run these in parallel:

```bash
git log --oneline origin/main..HEAD
git log origin/main..HEAD --format="%B"
git diff --stat origin/main..HEAD
```

For context, I sample key changed files with `git diff` (I don't overwhelm with full diff).

**I analyze for:**

- **Scope**: Which areas touched (backend, frontend, api, db, config)
- **Type signals**:
  - **Bug**: "fix", "bug", error handling, crash fixes
  - **Story**: new features, user-facing changes, new capabilities
  - **Task**: refactors, cleanup, config, internal improvements
- **Impact**: User-facing vs internal

### Phase 3: Draft Generation

**Type**: I infer from analysis (Story/Task/Bug)

**Summary** (max 50 chars):

- Action verb + concise outcome
- Examples: "Add metric export", "Fix dashboard crash", "Refactor API client"

**Description** (1 paragraph, 2-4 sentences, future tense):

I describe ONLY the problem/gap, not the solution or how it will be fixed.

Template:

```
Currently, [describe current state/problem that exists].

[Why this is a problem - user/business impact].

[Optional: What needs to happen at high level, if not obvious from problem].
```

**How I write descriptions:**

- **PROBLEM ONLY**: I never describe solution, implementation, or how it was/will be fixed
- Future/present tense: "currently X", "needs Y" (not "did", "added", "fixed")
- Focus on WHY this is a problem, user/business impact
- 2-4 sentences maximum - brief and casual
- I synthesize user description + commit patterns to understand the problem
- No code/technical jargon unless essential

### Phase 4: Confirmation

I present the draft:

```
Project: [KEY]
Type: [Story|Task|Bug]
Summary: [generated summary]

Description:
[generated description]
```

Use `AskUserQuestion` with the `preview` field on each option showing the full ticket draft (project, type, summary, description):

- **Create ticket** - proceed with jira CLI
- **Edit description** - let user provide modified description
- **Edit summary** - let user provide modified summary
- **Cancel** - abort

If user selects edit options, I loop back with updated content.

### Phase 5: Create Ticket

Only if approved:

**1. Create the ticket:**

```bash
jira issue create \
  -p"[PROJECT_KEY]" \
  -t"[Type]" \
  -s"[Summary]" \
  -b"[Description]" \
  --no-input
```

**2. Assign to current user:**

```bash
jira issue assign [TICKET_KEY] $(jira me)
```

**3. Move to In Progress:**

```bash
jira issue move [TICKET_KEY] "Started" || jira issue move [TICKET_KEY] "In Progress"
```

After creation, I:

- Display ticket key (e.g., TNK-123, CNS-456)
- Display Jira URL
- Confirm assignment
- Note if "In Progress" transition failed (may not be available)

## Edge Cases

**No commits on branch:**

- I check for staged/unstaged changes with `git status` and `git diff`
- I rely more heavily on user description
- I ask additional context questions if needed

**Many commits (>10):**

- I group by theme/area
- I focus on overall narrative, not individual commits
- I synthesize main purpose across all changes

**Branch name already has ticket key:**

- I note it but proceed with new ticket creation
- User can manually link tickets if needed

**No changes from main:**

- I alert user that branch has no divergence from main
- I ask if they want to proceed anyway
