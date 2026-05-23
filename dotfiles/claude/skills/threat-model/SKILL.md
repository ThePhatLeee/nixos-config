---
name: threat-model
description: Use BEFORE implementation when designing any system that handles user input, authentication, external integrations, or runs in production. STRIDE + trust boundaries + OWASP Top 10 mapping. Pairs with /spec — threat model output goes in the spec's Security section. Auto-triggers on: threat model, STRIDE, OWASP, trust boundary, secure design, attack surface.
---

# Threat Modeling

Run this BEFORE writing code. The output is a table that goes in the spec, not a separate doc that rots.

## STRIDE

| Letter | Threat                 | Property        | Example                                |
|--------|------------------------|-----------------|----------------------------------------|
| **S**  | Spoofing               | Authentication  | Stolen session cookie                  |
| **T**  | Tampering              | Integrity       | Modifying POST body in transit         |
| **R**  | Repudiation            | Non-repudiation | "I didn't make that payment"           |
| **I**  | Information disclosure | Confidentiality | SQL injection dumps `users` table      |
| **D**  | Denial of service      | Availability    | Unbounded resource consumption         |
| **E**  | Elevation of privilege | Authorization   | Path traversal becomes RCE             |

## Process — 30 minutes per feature

### 1. Data flow diagram
- **Entities** (outside your trust): users, browsers, third-party APIs, scrapers
- **Processes** (your code): controllers, workers, cron, edge functions
- **Stores**: databases, caches, S3, sessions, files
- **Flows** (arrows): label with what's transmitted ("user creds", "JWT", "webhook body")

### 2. Mark trust boundaries
Anywhere data crosses from less-trusted to more-trusted, draw a line. Each crossing requires:
- **AuthN**: who is the caller?
- **AuthZ**: are they allowed to do this *specific* thing on this *specific* resource?
- **Validation**: does the data match the expected shape, size, encoding?

Common lines: `user → server`, `server → DB`, `server → third-party API`, `worker → outgoing webhook`, `untrusted file → parser`.

### 3. Enumerate STRIDE per crossing
Don't try to list everything. List what's plausible for your stack and your realistic attacker (script kiddie, opportunist scraper, motivated insider, nation-state — pick one).

### 4. Pick mitigations from established patterns
Never invent crypto. Mitigations go in spec under "Security considerations" with owners.

## OWASP Top 10 (2021) — per-feature checklist

- **A01 Broken Access Control** — AuthZ at every endpoint. `WHERE user_id = ?` on every query. Laravel policies/gates, no "trust the URL".
- **A02 Cryptographic Failures** — TLS in transit, bcrypt (cost ≥ 12) for passwords, AES-GCM for data at rest. No MD5/SHA1 for security purposes.
- **A03 Injection** — Parameterized queries always. Eloquent is safe; raw `DB::statement` MUST use bindings. Validate file uploads (MIME + magic bytes + size + extension).
- **A04 Insecure Design** — That's literally what this skill prevents.
- **A05 Security Misconfiguration** — `APP_DEBUG=false` in prod, CSP + HSTS + X-Frame-Options + X-Content-Type-Options + Referrer-Policy, close default credentials, disable directory listing.
- **A06 Vulnerable Components** — `composer audit`, `npm audit --production`, watch CVE feeds for stack.
- **A07 Identification & Authentication Failures** — Rate-limit login (5/min/IP), MFA for admins/elevated roles, rotate session ID on login + privilege change, secure cookie flags (Secure + HttpOnly + SameSite=Lax/Strict).
- **A08 Software & Data Integrity Failures** — Verify package signatures, no `curl | sh` in CI, pin GitHub Actions to commit SHA not tag.
- **A09 Security Logging & Monitoring Failures** — Log: auth success/failure, privilege changes, sensitive data access, payment events. Format: machine-parseable, no PII in plaintext.
- **A10 SSRF** — Validate user-supplied URLs against an allowlist BEFORE fetching server-side. Block private CIDR (10/8, 172.16/12, 192.168/16, 169.254/16, 127/8, ::1).

## CWE quick reference

| CWE  | Name                  | Where it bites                       |
|------|-----------------------|--------------------------------------|
| 79   | XSS                   | Frontend output of user content      |
| 89   | SQL injection         | Query strings built from input       |
| 22   | Path traversal        | File downloads, log readers          |
| 287  | Improper auth         | Login flow, session handling         |
| 352  | CSRF                  | State-changing requests w/o token    |
| 918  | SSRF                  | Server fetches user URL              |
| 384  | Session fixation      | Not rotating session on login        |
| 400  | DoS via exhaustion    | Unbounded loops, no rate limit       |
| 502  | XML XXE               | Untrusted XML with entity expansion  |
| 611  | XXE                   | XML parser without DTD disabled      |
| 798  | Hardcoded credentials | Secrets in source/config             |
| 862  | Missing authorization | Authenticated but not authorized     |

## Output format (paste into spec)

```markdown
## Security considerations

### Trust boundaries
1. Browser → API
2. API → Postgres
3. API → Stripe webhook (inbound)

### Threats
| Boundary       | STRIDE | Threat                       | Likelihood | Impact | Mitigation                                            |
|----------------|--------|------------------------------|------------|--------|-------------------------------------------------------|
| Browser→API    | S      | Session theft via XSS        | M          | H      | CSP `default-src 'self'` + HttpOnly + SameSite=Strict |
| Browser→API    | T      | CSRF on POST /orders         | H          | H      | Sanctum CSRF token                                    |
| API→Stripe     | T      | Forged inbound webhook       | M          | H      | Verify HMAC sig with `Stripe-Signature` + secret      |
| API→Postgres   | I      | SQL injection                | L          | C      | Eloquent everywhere; raw queries use bindings         |
| API→Postgres   | D      | Unbounded query exhausts pool| M          | H      | Per-route rate limit + query timeout                  |
```

L/M/H/C for likelihood and impact; C only for catastrophic (full breach, irreversible data loss).

## Anti-patterns

- "We'll add auth later" — auth retrofit always misses something
- Hand-rolled crypto, hand-rolled session management, hand-rolled JWT verification
- Threat model based on what's easy to enumerate, not what's likely
- Mitigations without owner ("the framework handles it" — *verify* it does)
- Skipping STRIDE because "this is internal" — insider threats are real and often most damaging
- Per-feature threat model but no cross-feature view — entire-app threat model once per quarter
