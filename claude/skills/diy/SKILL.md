---
name: diy
description: Explain how the user would solve the current problem independently — debug, build, or reason through it. Teaches patterns and mental models, not just answers.
user_invocable: true
---

# DIY — "How would I solve this myself?"

After helping the user with a problem or before starting implementation, break down how they'd approach it independently. The goal is to transfer _thinking patterns_, not just solutions.

## When Invoked

Look at the current conversation context — what problem was just solved, what feature is being built, or what bug was just fixed. Use that as the basis.

## Output Format

### Mental Model

One paragraph max. The high-level principle or perspective shift that makes this class of problem tractable. Think: "what's the insight that turns this from confusing to obvious?"

### Approach

3-5 numbered steps. Each step is one concrete action (search for X, read Y, check Z). No fluff. Include what tool/command/search they'd use.

### Rule of Thumb

One sentence. A reusable heuristic they can carry forward to similar problems. Format: "When [trigger], [action], because [reason]."

## Principles

- **Teach the pattern, not the instance.** "Trace the request path" is better than "look at metrics-proxy/internal/promql/query.go".
- **Name the mental model.** If there's a known concept (data flow tracing, layer peeling, rubber ducking), name it so they can look it up.
- **Be honest about what's hard.** If the only way to find something is grepping the monorepo for a keyword, say that. Don't pretend there's a cleaner path.
- **Calibrate to a frontend engineer.** The user works primarily in Console (SvelteKit). Backend services (Go) are not their daily driver — explain just enough to navigate, not to become an expert.
- **Acknowledge the monorepo.** The user works in `src/private/console` but the full monorepo contains all backend services. For Think-related backend (models, keys, router), the `engineering/think` repo is one level above (`../think` relative to the monorepo, or accessible via `glab` in `engineering/think`). Point to where in the monorepo or think repo they'd look.

## Tone

Direct, casual, peer-to-peer. Like a senior colleague sketching on a whiteboard. No motivational fluff.
