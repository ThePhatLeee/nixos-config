---
name: review-pr
description: Use when reviewing a pull request, doing a code review, or assessing a diff before merge. Triggers on: review this PR, code review, check this diff, review before merge, PR feedback.
---

# Code Review / PR Review

## What a review is for

A review is not proofreading. It answers:
1. **Correctness** — does this do what it claims?
2. **Safety** — does this introduce bugs, security issues, or data loss?
3. **Maintainability** — will this be understandable in 6 months?
4. **Scope** — does this do more or less than it should?

Style is the lowest priority. Automate it with linters; don't spend review comments on it.

## Review process

```
1. Read the PR description first — understand intent before reading code
2. Read the diff top-to-bottom once, just to orient
3. Find the core logic change — that's where bugs hide
4. Check test coverage — missing tests = missing confidence
5. Check edge cases explicitly
6. Write comments
```

## What to look for

**Correctness**
- Does the logic handle all inputs including empty, null, zero, negative?
- Off-by-one errors in loops and pagination
- Race conditions — concurrent writes to shared state
- Is every error handled? Or silently swallowed?
- Are return values being used? (`if (!result)` missing?)

**Security**
- User input used in SQL, HTML, shell commands without escaping?
- New endpoint — is it behind auth?
- Mass assignment — is `$request->all()` anywhere?
- Secrets in code?
- Path traversal — are file paths sanitized?

**Performance**
- N+1 queries introduced (loop calling a query per iteration)
- Missing index on new WHERE clause
- Unbounded query (no LIMIT)
- Large allocation in hot path

**Scope**
- Does the PR do exactly what the ticket describes?
- Are there unrelated changes mixed in? (ask to split)
- Is there dead code added but never called?

## Comment quality

Good review comment = specific + actionable + explains why.

```
# Bad
"this is wrong"

# Bad
"nit: rename this"

# Good
"This will panic if `users` is empty — `users[0]` needs a length check first."

# Good
"This introduces an N+1: `->user` is called inside the loop on line 42.
 Pull it out with `->with('user')` on the query."
```

**Severity signal** (use consistently):
- `blocking:` — must fix before merge
- `suggestion:` — would improve it, non-blocking
- `nit:` — minor, entirely optional

## Approving

Approve when: correctness is solid, tests cover the change, no security issues.
Don't block on style, naming preferences, or "I'd have done it differently."

Request changes when: there's a correctness issue, missing test for a critical path, security concern.

## PR as author — before requesting review

- [ ] Does the PR description explain WHY, not just what?
- [ ] Is the diff the smallest it can be while still being a complete change?
- [ ] Are there tests for the new behavior?
- [ ] Have you read your own diff once?
- [ ] If the change is large: have you added inline comments explaining the non-obvious parts?
