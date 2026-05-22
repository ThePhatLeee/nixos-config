---
name: fix-issue
description: Use when investigating and fixing a bug, error, or broken behavior. Triggers on: bug, error, broken, not working, crash, exception, fix this, something wrong, failing test.
---

# Fixing an Issue

## Process

1. **Reproduce first.** If you can't reproduce it, you don't understand it.
2. **Read the error.** The full stack trace, not just the last line.
3. **Hypothesize one cause.** Make a specific prediction, then test it.
4. **Fix the root cause.** Not the symptom.
5. **Verify the fix.** Reproduce the original issue and confirm it's gone.
6. **Check for regressions.** Run the test suite. Check adjacent code.

## Reproduction

```bash
# Isolate: smallest possible case that triggers the bug
# Binary search: comment out half the code until bug disappears
# Environment: does it reproduce in production but not locally? → env/config/data diff
# Timing: flaky? → race condition, network timeout, cache miss
```

## Reading errors

```
PHP:    line number + file, trace goes bottom-up (entry point at bottom)
JS:     check browser console, not just terminal — they're often different
Python: trace reads top-down, exception at the bottom
Rust:   compiler errors are the best in the industry — read them fully
SQL:    "column X does not exist" often means wrong table alias, not typo
Nix:    "infinite recursion" → module importing itself via config.X in option.X
        "is not a function" → missing parentheses in function application
```

## Common root causes by symptom

```
Works locally, fails in CI/prod:
  → Missing env variable
  → Different package version (lock file not committed)
  → DB migration not run
  → File path relative instead of absolute
  → Race condition masked by local latency

Works for me, not for them:
  → Permission / role issue
  → Browser/OS specific
  → Locale / timezone difference
  → Cached data (tell them to hard-refresh or clear cache)

Intermittent / flaky:
  → Race condition (shared mutable state, concurrent writes)
  → Timing dependency (sleep in test, polling loop)
  → Memory leak causing eventual OOM
  → Unhandled edge case in production data

Performance regression:
  → N+1 query introduced (check query count)
  → Missing index on new WHERE clause
  → Unbounded query (forgot pagination)
  → Large allocation in hot loop
```

## Debugging tools

```bash
# Laravel
php artisan tinker              # REPL with app context
tail -f storage/logs/laravel.log
DB::enableQueryLog(); ... dd(DB::getQueryLog());

# JS / React
console.trace()                 # full call stack at a point
debugger;                       # breakpoint — needs DevTools open
performance.mark / measure      # timing

# Python
import pdb; pdb.set_trace()     # interactive debugger
breakpoint()                    # same, Python 3.7+

# Nix
nix eval .#nixosConfigurations.nixos.config.<option> --show-trace
nix repl '<nixpkgs>'            # interactive nix REPL

# SQL
EXPLAIN ANALYZE <query>         # show query plan + actual timings
```

## Fixing

- Change one thing at a time. Two fixes at once means you don't know which worked.
- Smallest possible change that fixes the root cause.
- No "defensive" fixes that hide the real problem.
- If the fix feels like a hack, it probably is — dig deeper.

## After the fix

- Add a test that would have caught this
- Check if the same bug pattern exists elsewhere in the codebase
- If the bug lived in production: estimate impact (how many users, how long)
- Update the ticket with: root cause, fix description, tests added
