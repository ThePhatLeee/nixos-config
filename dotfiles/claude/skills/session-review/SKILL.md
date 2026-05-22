---
name: session-review
description: Use at the end of a work session to review what was accomplished, extract patterns, and update skills/memory. Triggers on: session review, end of session, what did we learn, update skills, wrap up session.
---

# Session Review

Run this at the end of a productive session to close the loop and make the next session better.

## What to capture

**Decisions made** — architectural choices, tradeoffs accepted, approaches rejected.
Why these matter: next session starts cold. Capturing the why prevents re-litigating settled questions.

**Patterns that worked** — approaches that turned out to be right, tools that saved time, sequences that worked well.
These become candidates for skill updates.

**Corrections received** — anything I got wrong that you corrected.
These become feedback memories or skill fixes — highest priority to capture.

**Blocked items** — things we couldn't finish and why.
Capture enough context that future-me can pick up without re-investigating.

## Process

1. **List what changed** — files edited, features built, problems solved
2. **Extract learnings** — what's worth keeping vs what was context-specific
3. **Identify skill gaps** — did I apply a skill incorrectly? Is a skill missing something?
4. **Update skills** — if a pattern belongs in a skill, write it now while it's fresh
5. **Update memory** — user preferences, project state, decisions that persist

## Skill update triggers

Update a skill when:
- You corrected me on something the skill didn't cover or got wrong
- We discovered a pattern that worked exceptionally well
- We found a common pitfall not documented in the skill
- A skill's guidance was wrong for this context

Update memory when:
- You stated a preference ("always do X", "never do Y")
- The project state changed (major milestone, new constraint, new decision)
- I made an assumption that turned out to be wrong

## Output format

```markdown
## Session: [date]

### Accomplished
- [specific thing 1]
- [specific thing 2]

### Skill updates triggered
- /skill-name: [what to add/change]

### Memory updates
- [type]: [what to remember]

### Blocked / deferred
- [item]: [why blocked, what's needed to unblock]
```

## What NOT to capture

- The full task list (it's in git history)
- Code that was written (it's in the files)
- Context that's obvious from reading the files
- Temporary state that won't matter next session
