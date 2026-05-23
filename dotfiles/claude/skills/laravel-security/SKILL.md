---
name: laravel-security
description: Use for Laravel-specific security: Sanctum/Passport auth, policies & gates, CSRF/CORS, validation rules, rate limiting, file uploads, mass assignment, Pest security tests. Complements /laravel (app structure) and /threat-model (design). Auto-triggers on: laravel security, sanctum, policy, gate, csrf, laravel auth, eloquent fillable, validation, rate limit.
---

# Laravel Security

Laravel ships safe defaults — most CVEs in Laravel apps are developer-introduced. This skill catalogs the patterns that hold up.

## Authentication

### Sanctum (SPA + first-party API)

```php
// config/sanctum.php
'stateful' => env('SANCTUM_STATEFUL_DOMAINS') ? explode(',', env('SANCTUM_STATEFUL_DOMAINS')) : [],

// .env
SANCTUM_STATEFUL_DOMAINS=app.example.com,admin.example.com
SESSION_DOMAIN=.example.com
SESSION_SECURE_COOKIE=true
SESSION_SAME_SITE=lax  // 'strict' breaks SSO callbacks
```

Routes:
```php
// routes/api.php
Route::middleware(['auth:sanctum'])->group(function () {
    Route::get('/me', [UserController::class, 'show']);
});

// routes/web.php (Sanctum SPA — cookie-based, automatic CSRF)
Route::middleware(['auth:sanctum'])->group(/* ... */);
```

Token issuing (for mobile/CLI clients):
```php
$token = $user->createToken('mobile-app', ['orders:read'])->plainTextToken;
// Always abilities/scopes — never an unscoped token
```

### Passport (full OAuth server)

Use only if you're hosting third-party clients. Otherwise Sanctum.

### Session config (always check)

```php
// config/session.php
'lifetime' => 120,          // minutes; balance UX vs theft window
'expire_on_close' => false, // 'true' if you want strictest
'encrypt' => true,           // encrypt session driver content
'secure' => env('SESSION_SECURE_COOKIE', true),
'http_only' => true,
'same_site' => 'lax',        // 'strict' if no cross-site SSO
'partitioned' => true,       // CHIPS for 3rd-party iframe contexts
```

## Authorization — policies > checks

```php
// app/Policies/OrderPolicy.php
class OrderPolicy
{
    public function view(User $user, Order $order): bool
    {
        return $user->id === $order->user_id || $user->hasRole('admin');
    }

    public function update(User $user, Order $order): bool
    {
        return $user->id === $order->user_id && $order->status === 'draft';
    }

    public function before(User $user, string $ability): ?bool
    {
        return $user->banned ? false : null;  // null = continue with policy
    }
}

// Register
Gate::policy(Order::class, OrderPolicy::class);
```

Controller:
```php
public function update(UpdateOrderRequest $req, Order $order)
{
    $this->authorize('update', $order);  // throws 403 if denied
    $order->update($req->validated());
    return $order;
}
```

Or shorthand:
```php
Route::patch('/orders/{order}', [OrderController::class, 'update'])
    ->middleware('can:update,order');
```

Form request authorization:
```php
class UpdateOrderRequest extends FormRequest
{
    public function authorize(): bool
    {
        return $this->user()->can('update', $this->route('order'));
    }
}
```

**Rule**: every controller action must have either `$this->authorize()`, `->middleware('can:...')`, or `$request->authorize()`. No exceptions for "internal" routes.

## CSRF — what Laravel does for you

- All `web` routes auto-verify the `_token` field
- Sanctum SPA: cookie-based, the `XSRF-TOKEN` cookie + `X-XSRF-TOKEN` header pair is automatic with axios/fetch credentials
- `api` middleware group SKIPS CSRF — token auth is the protection

Common mistake: putting a state-changing route in `api.php` that uses session auth → CSRF disabled silently. Either use `auth:sanctum` token (no session) or put it in `web.php`.

## CORS

```php
// config/cors.php
'paths' => ['api/*', 'sanctum/csrf-cookie', 'login', 'logout'],
'allowed_methods' => ['*'],
'allowed_origins' => [env('FRONTEND_URL')],  // never '*' with credentials
'allowed_origins_patterns' => [],
'allowed_headers' => ['*'],
'exposed_headers' => [],
'max_age' => 0,
'supports_credentials' => true,  // required for Sanctum cookies
```

## Input validation

Form Requests over inline validation — they're testable and reusable.

```php
class StoreOrderRequest extends FormRequest
{
    public function rules(): array
    {
        return [
            'customer_id' => ['required', 'integer', 'exists:customers,id'],
            'items'       => ['required', 'array', 'min:1', 'max:100'],
            'items.*.sku' => ['required', 'string', 'max:64', 'exists:products,sku'],
            'items.*.qty' => ['required', 'integer', 'min:1', 'max:999'],
            'notes'       => ['nullable', 'string', 'max:1000'],
            'currency'    => ['required', 'string', Rule::in(['USD','EUR','GBP'])],
        ];
    }

    public function prepareForValidation(): void
    {
        $this->merge(['notes' => trim((string) $this->notes)]);
    }
}
```

Always:
- Bound integers (`min`/`max`)
- Bound arrays (`min`/`max` count)
- Bound strings (`max`)
- Whitelist enums with `Rule::in([...])` or `Enum::class`
- Existence checks with `exists:table,column`

## File uploads — never trust extension

```php
$request->validate([
    'avatar' => [
        'required',
        'file',
        'image',                            // checks MIME type
        'mimes:jpg,png,webp',               // double-check MIME
        'extensions:jpg,jpeg,png,webp',     // and extension
        'max:5120',                         // 5MB
        'dimensions:max_width=4000,max_height=4000',
    ],
]);

// Store with generated name; never $request->file('avatar')->getClientOriginalName()
$path = $request->file('avatar')->store('avatars', 'public');
```

For non-public uploads:
```php
$path = $request->file('contract')->store('contracts', 'private');
// Serve via signed temp URL:
return Storage::disk('private')->temporaryUrl($path, now()->addMinutes(5));
```

Never serve uploaded files from a public directory with the original filename.

## Mass assignment — `$fillable` discipline

```php
class Order extends Model
{
    protected $fillable = ['customer_id', 'currency', 'notes'];
    // status, total, user_id are server-set, not fillable
}
```

NEVER use `protected $guarded = []`. Even `Model::unguard()` only in seeders.

Use `$request->validated()` (returns only the rules-passed fields), not `$request->all()`.

## SQL — Eloquent is safe; raw queries need bindings

```php
// Safe
User::where('email', $request->email)->first();
User::whereIn('id', $request->ids)->get();

// Raw must bind
DB::select('SELECT * FROM users WHERE email = ?', [$request->email]);
DB::statement('UPDATE users SET banned = ? WHERE id = ?', [true, $id]);

// Never
DB::select("SELECT * FROM users WHERE email = '$email'");  // SQLi
```

`whereRaw`/`orderByRaw` need bindings too:
```php
User::whereRaw('LOWER(email) = ?', [strtolower($email)])->first();
```

## Rate limiting

```php
// In RouteServiceProvider or routes file
RateLimiter::for('login', function (Request $req) {
    return Limit::perMinute(5)->by($req->ip());
});

RateLimiter::for('api', function (Request $req) {
    return $req->user()
        ? Limit::perMinute(60)->by($req->user()->id)
        : Limit::perMinute(20)->by($req->ip());
});

// Route
Route::middleware('throttle:login')->post('/login', /* ... */);
```

Login endpoint should ALSO throttle by username, not just IP — attackers rotate IPs:
```php
RateLimiter::for('login', function (Request $req) {
    return [
        Limit::perMinute(5)->by($req->ip()),
        Limit::perMinute(5)->by(strtolower($req->input('email'))),
    ];
});
```

## Sensitive data

```php
// Hide in API responses
class User extends Authenticatable {
    protected $hidden = ['password', 'remember_token', 'two_factor_secret'];
}

// Encrypt at rest
protected $casts = [
    'ssn' => 'encrypted',
    'medical_notes' => 'encrypted',
    'config' => 'encrypted:json',
];
```

## Headers (middleware)

```php
// app/Http/Middleware/SecurityHeaders.php
public function handle(Request $req, Closure $next): Response
{
    $resp = $next($req);
    $resp->headers->set('X-Content-Type-Options', 'nosniff');
    $resp->headers->set('X-Frame-Options', 'DENY');
    $resp->headers->set('Referrer-Policy', 'strict-origin-when-cross-origin');
    $resp->headers->set('Permissions-Policy', 'camera=(), microphone=(), geolocation=()');
    $resp->headers->set('Strict-Transport-Security', 'max-age=63072000; includeSubDomains; preload');
    $resp->headers->set('Content-Security-Policy', "default-src 'self'; ...");
    return $resp;
}
```

## Pest security tests

```php
// tests/Feature/AuthorizationTest.php
it('forbids viewing other users orders', function () {
    $alice = User::factory()->create();
    $bob   = User::factory()->create();
    $order = Order::factory()->for($alice)->create();

    actingAs($bob)
        ->get("/api/orders/{$order->id}")
        ->assertForbidden();
});

it('rate limits login after 5 attempts', function () {
    for ($i = 0; $i < 5; $i++) {
        post('/login', ['email' => 'a@b.c', 'password' => 'wrong'])->assertStatus(422);
    }
    post('/login', ['email' => 'a@b.c', 'password' => 'wrong'])->assertStatus(429);
});

it('rejects mass assignment of status field', function () {
    $user  = User::factory()->create();
    $order = Order::factory()->for($user)->create(['status' => 'draft']);

    actingAs($user)
        ->patch("/api/orders/{$order->id}", ['status' => 'completed', 'notes' => 'x'])
        ->assertOk();

    expect($order->fresh()->status)->toBe('draft');  // status protected
    expect($order->fresh()->notes)->toBe('x');       // notes accepted
});

it('strips XSS from user-controlled output', function () {
    $u = User::factory()->create(['bio' => '<script>alert(1)</script>']);
    get("/users/{$u->id}")
        ->assertSee('&lt;script&gt;', false)
        ->assertDontSee('<script>', false);
});
```

## Anti-patterns

- `protected $guarded = []` "for convenience" — guaranteed mass-assignment vuln
- `$request->all()` straight into `Model::create()` — same problem
- Authorization in views (`@if($user->id === $order->user_id)`) — controller leak
- `csrf-token` exposed to JS, then re-submitted via JS — defeats double-submit; use cookie pair
- Trusting `getClientOriginalName()` for file storage
- `DB::raw` interpolating any user input
- "Internal" admin routes without policy checks
- Sanctum stateful + JWT — pick one
- Email-as-id in URLs — predictable, harvestable; UUIDs
