# Laravel / PHP Guidelines

## PHP
- `declare(strict_types=1)` in every file.
- Typed properties, typed parameters, typed return types everywhere.
- Named arguments for calls with more than 3 parameters or where argument order is non-obvious.
- Constructor property promotion for simple data-holder classes.
- Enums (PHP 8.1+) over class constants for finite value sets.
- No `@` error suppression.

## Laravel architecture
- **Thin controllers**: a controller method should read input, call one Action/Service, return a response.
- **Actions**: single-purpose classes (`CreateInvoice`, `SendWelcomeEmail`). One public `handle()` method. No state.
- **Form Requests**: validation and authorisation for any non-trivial input. Never validate in the controller body.
- **API Resources**: always transform Eloquent models through a Resource before returning from API controllers.
- **Events & Listeners**: for side effects (emails, notifications, audit logs) — keep them out of the main flow.
- **Jobs**: for anything async or slow. Use typed constructor arguments.

## Eloquent
- Eager-load relationships: always `with()` what you know you'll need. No N+1.
- Scopes for reusable query constraints.
- Avoid raw SQL except for complex aggregates that Eloquent can't express cleanly; use `DB::raw()` sparingly.
- Mass assignment: always fill `$fillable` or `$guarded`; prefer `$guarded = []` with awareness.
- Casts: declare `$casts` for booleans, dates, enums, JSON columns.

## Testing (Pest PHP)
- Feature tests over unit tests for Laravel code — test through HTTP.
- `RefreshDatabase` only when you need real DB; prefer `WithoutMiddleware` + mocking for unit-level tests.
- Factory states for complex model setup.
- Assert the HTTP response AND the database state.
- Mock external services; never hit real APIs in tests.

## Database
- Migrations: always reversible (`down()` method implemented).
- Indexes: add for every foreign key and any column used in `WHERE`/`ORDER BY`.
- `EXPLAIN ANALYZE` before shipping a new query on large tables.
- Never use `->get()` where `->cursor()` or chunking would do for large result sets.

## Security
- Validate all input via Form Requests.
- Authorise all actions via Policies or Gates — never trust user-supplied IDs.
- No raw user input in queries — always use Eloquent or parameterised bindings.
- Secrets in `.env`, never committed.
