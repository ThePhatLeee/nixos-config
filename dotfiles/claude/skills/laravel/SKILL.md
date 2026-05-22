---
name: laravel
description: Use for Laravel, PHP, Eloquent, Blade, Livewire, Pest, or any backend PHP work. Triggers on: Laravel, Eloquent, artisan, Blade, migration, controller, middleware, Pest, PHP.
---

# Laravel / PHP

## Versions assumed: Laravel 12, PHP 8.3+

## Controller — resource style
```php
// Thin controllers. Logic in services or actions.
class PostController extends Controller
{
    public function store(StorePostRequest $request): RedirectResponse
    {
        $post = Post::create($request->validated());
        return redirect()->route('posts.show', $post);
    }
}
```

Never put business logic in controllers. One controller method = one action.

## Form request validation
```php
class StorePostRequest extends FormRequest
{
    public function authorize(): bool
    {
        return $this->user()->can('create', Post::class);
    }

    public function rules(): array
    {
        return [
            'title'   => ['required', 'string', 'max:255'],
            'body'    => ['required', 'string'],
            'tags'    => ['array', 'max:5'],
            'tags.*'  => ['string', 'exists:tags,slug'],
        ];
    }
}
```

## Eloquent patterns
```php
// Relationships — return types always declared
class Post extends Model
{
    protected $fillable = ['title', 'body', 'user_id', 'published_at'];
    protected $casts = ['published_at' => 'datetime', 'meta' => 'array'];

    public function user(): BelongsTo    { return $this->belongsTo(User::class); }
    public function tags(): BelongsToMany { return $this->belongsToMany(Tag::class); }
    public function comments(): HasMany  { return $this->hasMany(Comment::class); }

    // Scope — named like query conditions
    public function scopePublished(Builder $query): void
    {
        $query->whereNotNull('published_at')->where('published_at', '<=', now());
    }
}

// Query — eager load to avoid N+1
Post::with(['user', 'tags'])
    ->published()
    ->latest('published_at')
    ->paginate(20);

// Never: Post::all() then loop with ->user or ->comments
```

## Service/action pattern
```php
// One action per use-case — no fat services
class PublishPost
{
    public function execute(Post $post, User $publisher): Post
    {
        throw_unless($publisher->can('publish', $post), AuthorizationException::class);

        $post->update(['published_at' => now()]);
        PublishPostJob::dispatch($post);
        event(new PostPublished($post));

        return $post;
    }
}
```

## Migrations
```php
Schema::create('posts', function (Blueprint $table) {
    $table->id();
    $table->foreignId('user_id')->constrained()->cascadeOnDelete();
    $table->string('title');
    $table->text('body');
    $table->timestamp('published_at')->nullable()->index();
    $table->timestamps();
});
```

- Always `constrained()->cascadeOnDelete()` or `nullOnDelete()` — explicit, never silent
- Index every column used in `WHERE` or `ORDER BY`
- Nullable foreign keys use `nullOnDelete()`

## API resources
```php
class PostResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id'           => $this->id,
            'title'        => $this->title,
            'published_at' => $this->published_at?->toIso8601String(),
            'author'       => new UserResource($this->whenLoaded('user')),
            'tags'         => TagResource::collection($this->whenLoaded('tags')),
        ];
    }
}
```

`whenLoaded()` prevents N+1 in resource collections.

## Routes
```php
// routes/api.php — versioned, grouped, resource
Route::prefix('v1')->middleware('auth:sanctum')->group(function () {
    Route::apiResource('posts', PostController::class);
    Route::post('posts/{post}/publish', [PostController::class, 'publish'])->name('posts.publish');
});
```

No route closures in production — use named controllers.

## Pest tests
```php
// Feature test — hits DB
it('creates a post', function () {
    $user = User::factory()->create();

    $response = actingAs($user)
        ->postJson('/api/v1/posts', ['title' => 'Hello', 'body' => 'World'])
        ->assertCreated()
        ->assertJsonPath('data.title', 'Hello');

    expect(Post::count())->toBe(1);
});

// Unit test — no DB
it('formats published_at as ISO 8601', function () {
    $post = new Post(['published_at' => Carbon::parse('2025-01-15 12:00:00')]);
    expect($post->published_at->toIso8601String())->toBe('2025-01-15T12:00:00+00:00');
});
```

Use `RefreshDatabase` trait on feature tests. `DatabaseTransactions` for tests that don't need schema reset.

## Queue jobs
```php
class ProcessVideoUpload implements ShouldQueue
{
    use Queueable, Dispatchable, InteractsWithQueue, SerializesModels;

    public int $tries = 3;
    public int $backoff = 60; // seconds between retries

    public function __construct(private readonly Video $video) {}

    public function handle(VideoProcessor $processor): void
    {
        $processor->transcode($this->video);
    }

    public function failed(Throwable $e): void
    {
        $this->video->update(['status' => 'failed']);
        Log::error("Video processing failed: {$e->getMessage()}", ['video_id' => $this->video->id]);
    }
}
```

## Common pitfalls
- `Model::all()` in loops → N+1. Always eager load or use `select`.
- `request()->all()` in `create()`/`update()` → mass assignment vulnerability. Always `validated()`.
- Implicit route model binding without policy check → authorization bypass.
- `Carbon::now()` in migration defaults → not reproducible. Use `useCurrent()` or `nullable()`.
- Missing `->withTimestamps()` on many-to-many pivot → no created_at/updated_at tracking.
