---
name: spec
description: Use when writing a technical specification, planning a feature, or designing a system before implementation. Triggers on: spec, specification, design doc, plan this feature, architecture, how should we build, before we start.
---

# Writing a Spec

A spec answers three questions before any code is written:
1. **What** exactly are we building?
2. **Why** — what problem does it solve, for whom?
3. **How** — what's the shape of the solution, what are the constraints?

## Structure

```markdown
# Feature: <Name>

## Problem
One paragraph. Who has this problem, what is it, why does it matter?
No solution language here — just the problem.

## Goals
- [ ] Concrete, testable outcome #1
- [ ] Concrete, testable outcome #2

## Non-goals (explicit scope boundary)
- We are NOT building X
- We are NOT handling Y in this iteration

## Proposed solution
Architecture or flow in plain language. Include a diagram if it helps clarity.
Call out the key decisions and why.

## Data model changes
New tables / columns / types. Schema sketches, not full migrations.

## API / interface changes
New endpoints, changed signatures, events emitted.

## Edge cases and failure modes
- What happens when X is empty?
- What happens when the external service is down?
- What's the rollback plan if this breaks?

## Open questions
- [ ] Do we need pagination on this list?
- [ ] Who owns notification delivery?

## Out of scope / future work
Things acknowledged but intentionally deferred.
```

## Spec discipline rules

- Write the spec before estimating. You can't estimate what you haven't defined.
- If two people read the spec and disagree on what to build, the spec is wrong.
- Specs are not PRDs — no marketing language. Technical audience only.
- Open questions must be resolved before implementation starts, not during.
- Non-goals are as important as goals — they prevent scope creep mid-build.
- A spec that describes a single wrong solution wastes less time than no spec at all.

## When a spec is not needed

- Bug fixes with a clear root cause
- Visual tweaks (spacing, colors)
- Adding a field to an existing form/API
- Configuration changes

The threshold: if two people could independently build different things from the same request, write a spec.
