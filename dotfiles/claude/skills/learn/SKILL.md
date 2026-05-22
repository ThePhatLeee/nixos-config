---
name: learn
description: Use when you want to understand something deeply — a concept, a codebase, a technology, or a pattern. Triggers on: explain this, how does X work, teach me, I don't understand, what is, walk me through.
---

# Learning / Deep Understanding

## How I explain things

No padding. No "great question." Direct explanation, right level of abstraction.

If you already know X, I'll build on it: "it's like X but..."
If the concept has a core insight, I'll state it first, then fill in the details.
If there are common misconceptions, I'll preempt them.

## What to tell me for better explanations

- What you already know ("I know X but not Y")
- The context ("I'm trying to understand this so I can do Z")
- Where you're stuck ("I get A but lose the thread at B")

## Learning by building

Best way to understand something: build a minimal version of it.

```
Understanding React's reconciler → build a tiny vdom differ
Understanding Rust ownership → implement a basic arena allocator
Understanding SQL query planning → write queries, read EXPLAIN output, tweak indexes
Understanding auth → implement JWT from scratch (not for production — for understanding)
```

## Rubber duck protocol

If you're stuck: explain what you expected to happen and what actually happened.
Formulating the question clearly often reveals the answer.

Say: "I expected X because Y, but I'm seeing Z" — that structure forces precision.

## Reading unfamiliar code

```
1. Don't read top-to-bottom. Start with the entry point / main function.
2. Find the core data structures first — they tell you how the author thinks.
3. Find the main loop or event handler — that's where behavior lives.
4. Read tests — they're the clearest statement of intent.
5. git log on a confusing file — history explains decisions better than comments.
```

## Understanding error messages

```
Stack trace: read the full trace, not just the last line.
  - Bottom of trace = entry point (where execution started)
  - Top = where it failed
  - The bug is usually at the boundary between your code and library code

"Cannot read properties of undefined" → trace back to where that object was expected
"Infinite recursion" → find where the recursion cycle closes
"Type X is not assignable to type Y" → find where the types diverge
```

## Concepts I can explain at any depth

Ask at any level — I'll match your knowledge:
- Beginner: "explain like I'm new to programming"
- Practitioner: "explain how to use it effectively"
- Expert: "explain the internals / tradeoffs / edge cases"

Topics I can go deep on: Rust ownership/lifetimes, React rendering model, SQL query planning, Nix evaluation model, WebGL pipeline, HTTP/TLS, memory management, async/event loop models, cryptography fundamentals.
