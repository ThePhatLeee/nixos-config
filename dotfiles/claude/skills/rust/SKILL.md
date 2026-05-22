---
name: rust
description: Use for Rust code, Cargo, ownership/borrowing, async Rust, Tokio, CLI tools, or systems programming in Rust. Triggers on: Rust, Cargo, ownership, borrowing, lifetimes, Tokio, async/await, trait, enum, Result, Option.
---

# Rust

## Core patterns

```rust
// Result propagation — use ? everywhere, avoid unwrap() in library code
fn read_config(path: &Path) -> Result<Config, ConfigError> {
    let content = fs::read_to_string(path)?;
    let config: Config = toml::from_str(&content)?;
    Ok(config)
}

// Option — prefer map/and_then/unwrap_or over match for simple transforms
let display_name = user.nickname.as_deref().unwrap_or(&user.username);

// Destructuring
let Point { x, y } = point;
let (first, rest) = slice.split_first().ok_or(Error::EmptyInput)?;
```

## Ownership and borrowing

```rust
// Prefer &str over String in function params — avoids forcing allocation
fn greet(name: &str) -> String {
    format!("Hello, {name}!")
}

// Clone sparingly — profile first
// Use Cow<str> when you sometimes need owned, sometimes borrowed
use std::borrow::Cow;
fn normalize(s: &str) -> Cow<str> {
    if s.contains(' ') { Cow::Owned(s.replace(' ', "_")) }
    else { Cow::Borrowed(s) }
}

// Arc<T> for shared ownership across threads, Rc<T> for single-thread
// Mutex<T> for interior mutability across threads, RefCell<T> single-thread
let shared: Arc<Mutex<Vec<i32>>> = Arc::new(Mutex::new(vec![]));
```

## Enums — the core data model tool

```rust
#[derive(Debug, Clone, PartialEq)]
enum Event {
    Click { x: i32, y: i32 },
    KeyPress(char),
    Resize { width: u32, height: u32 },
    Quit,
}

// match is exhaustive — compiler enforces all arms
match event {
    Event::Click { x, y }          => handle_click(x, y),
    Event::KeyPress(c)              => handle_key(c),
    Event::Resize { width, height } => handle_resize(width, height),
    Event::Quit                     => return,
}
```

## Traits

```rust
trait Render {
    fn render(&self) -> String;
    fn render_to(&self, buf: &mut String) { buf.push_str(&self.render()); } // default impl
}

// impl Trait in return position — avoids boxing when concrete type is one
fn make_renderer(kind: &str) -> impl Render {
    HtmlRenderer::new()
}

// Box<dyn Trait> when type is dynamic / varies at runtime
fn make_renderer_dynamic(kind: &str) -> Box<dyn Render> {
    match kind {
        "html" => Box::new(HtmlRenderer::new()),
        _      => Box::new(TextRenderer::new()),
    }
}
```

## Iterators

```rust
// Prefer iterator chains over explicit loops
let total: u64 = orders
    .iter()
    .filter(|o| o.status == Status::Paid)
    .map(|o| o.amount)
    .sum();

// Collect into specific types
let names: Vec<String> = users.iter().map(|u| u.name.clone()).collect();
let by_id: HashMap<u64, &User> = users.iter().map(|u| (u.id, u)).collect();

// Custom iterator
struct Counter { count: u32, max: u32 }
impl Iterator for Counter {
    type Item = u32;
    fn next(&mut self) -> Option<u32> {
        if self.count < self.max { self.count += 1; Some(self.count) }
        else { None }
    }
}
```

## Error handling

```rust
// thiserror for library errors
use thiserror::Error;
#[derive(Debug, Error)]
enum AppError {
    #[error("Config file not found: {0}")]
    ConfigNotFound(PathBuf),
    #[error("Parse failed: {0}")]
    Parse(#[from] toml::de::Error),
    #[error(transparent)]
    Io(#[from] std::io::Error),
}

// anyhow for application/binary entry points
use anyhow::{Context, Result};
fn run() -> Result<()> {
    let config = read_config(path).context("reading config")?;
    Ok(())
}
```

## Async with Tokio

```rust
use tokio::{fs, net::TcpListener, io::{AsyncReadExt, AsyncWriteExt}};

#[tokio::main]
async fn main() -> anyhow::Result<()> {
    let listener = TcpListener::bind("0.0.0.0:8080").await?;
    loop {
        let (mut socket, _) = listener.accept().await?;
        tokio::spawn(async move {
            let mut buf = vec![0; 1024];
            match socket.read(&mut buf).await {
                Ok(n) if n == 0 => return,
                Ok(n)           => { socket.write_all(&buf[..n]).await.ok(); }
                Err(_)          => return,
            }
        });
    }
}

// Concurrent futures
let (a, b) = tokio::join!(fetch_user(id), fetch_settings(id));

// Bounded concurrency
use futures::stream::{self, StreamExt};
stream::iter(ids)
    .map(|id| fetch_user(id))
    .buffer_unordered(10)   // max 10 in-flight
    .collect::<Vec<_>>()
    .await;
```

## Lifetimes — only when compiler demands

```rust
// Only annotate when the compiler can't infer
fn longest<'a>(x: &'a str, y: &'a str) -> &'a str {
    if x.len() > y.len() { x } else { y }
}

// Struct holding references needs lifetime
struct Parser<'a> { input: &'a str, pos: usize }
```

## Cargo conventions

```toml
[profile.release]
opt-level = 3
lto = true      # link-time optimization
strip = true    # strip debug symbols

[profile.dev]
opt-level = 1   # slight opt — faster than 0 for iterators
```

Useful crates: `serde`+`serde_json`, `tokio`, `anyhow`, `thiserror`, `clap`, `reqwest`, `rayon`, `tracing`.

## Performance rules

- Benchmark before optimizing — `criterion` crate
- `Vec::with_capacity` when final size is known
- `String::with_capacity` same
- `Rc<str>` / `Arc<str>` for many clones of the same string (single allocation)
- SIMD via `std::simd` or `packed_simd` only after profiling shows it matters
- `rayon` for CPU-bound parallelism — drop-in par_iter
