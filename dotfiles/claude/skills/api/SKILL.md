---
name: api
description: Use when designing or building REST APIs, GraphQL, API authentication, versioning, rate limiting, or webhooks. Triggers on: API, REST, endpoint, route, HTTP, JSON, GraphQL, webhook, auth token, Sanctum, JWT.
---

# API Design

## REST conventions

```
GET    /posts           → index (paginated list)
POST   /posts           → store (create)
GET    /posts/{id}      → show (single resource)
PUT    /posts/{id}      → update (full replace)
PATCH  /posts/{id}      → update (partial)
DELETE /posts/{id}      → destroy

GET    /posts/{id}/comments     → nested resource index
POST   /posts/{id}/comments     → nested resource create

POST   /posts/{id}/publish      → action that doesn't map to CRUD
DELETE /posts/{id}/publish      → action (unpublish)
```

Use nouns for resources, verbs only for actions that don't fit CRUD.

## Response envelope

```json
// Single resource
{ "data": { "id": 1, "title": "Hello" } }

// Collection
{ "data": [...], "meta": { "total": 84, "per_page": 20, "current_page": 2 } }

// Error
{ "message": "The given data was invalid.", "errors": { "email": ["The email has already been taken."] } }
```

Never return raw arrays at the top level — breaks extensibility.

## HTTP status codes

```
200 OK              — successful GET, PATCH, PUT
201 Created         — successful POST
204 No Content      — successful DELETE (no body)
400 Bad Request     — malformed request body
401 Unauthorized    — missing/invalid auth
403 Forbidden       — authenticated but not allowed
404 Not Found       — resource doesn't exist
409 Conflict        — state conflict (duplicate, optimistic lock)
422 Unprocessable   — validation failed (Laravel default for form requests)
429 Too Many Requests — rate limited
500 Internal Server Error — unhandled exception
```

## Versioning

```
/api/v1/posts   — version in URL prefix, not Accept header
/api/v2/posts
```

Never break v1 after v2 ships. Deprecate with a `Deprecation` response header.

## Authentication — Laravel Sanctum

```php
// SPA auth: cookie-based (CSRF + session)
Route::post('/sanctum/token', function (Request $request) {
    $request->validate(['email' => 'required|email', 'password' => 'required']);
    if (! Auth::attempt($request->only('email', 'password'))) {
        throw ValidationException::withMessages(['email' => ['Invalid credentials.']]);
    }
    return $request->user()->createToken($request->device_name ?? 'api')->plainTextToken;
});

// Token auth: Bearer in Authorization header
Route::middleware('auth:sanctum')->group(function () {
    Route::get('/user', fn(Request $r) => $r->user());
});
```

## Rate limiting (Laravel)

```php
// routes/api.php
Route::middleware(['auth:sanctum', 'throttle:api'])->group(...);

// AppServiceProvider — named limiters
RateLimiter::for('api', function (Request $request) {
    return Limit::perMinute(60)->by($request->user()?->id ?: $request->ip());
});

RateLimiter::for('login', function (Request $request) {
    return Limit::perMinute(5)->by($request->ip());
});
```

Response headers on 429: `Retry-After`, `X-RateLimit-Limit`, `X-RateLimit-Remaining`.

## Pagination — keyset preferred

```php
// Cursor pagination (keyset) — O(1) regardless of depth
Post::latest()->cursorPaginate(20);
// Returns: { data: [...], next_cursor: "...", prev_cursor: "..." }

// Offset pagination — only for small datasets or when jump-to-page is required
Post::paginate(20);
```

## Filtering and sorting

```php
// Spatie Query Builder — safe, declarative
use Spatie\QueryBuilder\QueryBuilder;

$posts = QueryBuilder::for(Post::class)
    ->allowedFilters(['status', 'user_id', AllowedFilter::partial('title')])
    ->allowedSorts(['created_at', 'title'])
    ->allowedIncludes(['user', 'tags'])
    ->paginate(20);
```

Never `request()->all()` into a query — whitelist everything.

## Webhooks (outgoing)

```php
// Sign payload with HMAC-SHA256
$payload = json_encode($data);
$signature = hash_hmac('sha256', $payload, config('webhooks.secret'));

Http::withHeaders([
    'X-Signature-256' => "sha256={$signature}",
    'Content-Type'    => 'application/json',
])->post($endpoint, $data);
```

Receiving end must verify signature before processing:
```php
$expected = hash_hmac('sha256', $request->getContent(), config('webhooks.secret'));
if (! hash_equals($expected, $request->header('X-Signature-256', ''))) {
    abort(401);
}
```

## GraphQL (when appropriate)

Use REST for: standard CRUD, public APIs, clear resource boundaries.
Use GraphQL for: mobile/SPA with varied data requirements, heavily nested relationships, when clients drive shape.

```graphql
type Post {
  id: ID!
  title: String!
  author: User!
  tags: [Tag!]!
}

type Query {
  posts(first: Int, after: String, filter: PostFilter): PostConnection!
  post(id: ID!): Post
}

type Mutation {
  createPost(input: CreatePostInput!): Post!
  publishPost(id: ID!): Post!
}
```

Avoid GraphQL for: simple APIs, public-facing endpoints needing HTTP caching, teams without GraphQL experience.

## API design checklist

- [ ] All endpoints require explicit auth — no accidental public exposure
- [ ] Input validated at boundary (FormRequest / schema validation)
- [ ] Errors return consistent envelope with `message` + `errors`
- [ ] Collections paginated — never return unbounded lists
- [ ] Sensitive fields stripped from responses (password_hash, tokens)
- [ ] Rate limiting on auth and write endpoints
- [ ] Versioned — `/v1/` prefix from day one even if only one version exists
