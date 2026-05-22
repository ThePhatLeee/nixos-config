---
name: c-cpp
description: Use for C, C++, systems programming, memory management, CMake, or embedded/low-level code. Triggers on: C, C++, pointer, malloc, CMake, Makefile, header, struct, class, template, RAII, STL, embedded.
---

# C / C++

## C++ — modern style (C++17/20)

```cpp
// RAII everywhere — resources tied to object lifetime
class FileHandle {
    FILE* f;
public:
    explicit FileHandle(const char* path, const char* mode)
        : f(fopen(path, mode)) {
        if (!f) throw std::runtime_error(std::string("Cannot open: ") + path);
    }
    ~FileHandle() { if (f) fclose(f); }
    FileHandle(const FileHandle&) = delete;
    FileHandle& operator=(const FileHandle&) = delete;
    FILE* get() { return f; }
};
```

## Memory — prefer smart pointers, never raw `new`/`delete`

```cpp
// unique_ptr — single ownership
auto buf = std::make_unique<uint8_t[]>(size);
auto widget = std::make_unique<Widget>(args...);

// shared_ptr — shared ownership (prefer unique when possible)
auto shared = std::make_shared<Config>();

// Raw pointers only as non-owning observers
void process(const Widget* w);  // doesn't own, just reads

// stack allocation when size is known and small
std::array<int, 64> buf{};
```

## STL containers

```cpp
// vector for most sequences
std::vector<int> v = {1, 2, 3};
v.reserve(expected_size);  // avoid reallocations when size known upfront

// unordered_map for O(1) lookup by key
std::unordered_map<std::string, int> counts;
counts.try_emplace("key", 0);   // insert-if-absent
++counts["key"];

// string_view — non-owning string reference (avoids copies in APIs)
void process(std::string_view name);

// span — non-owning view of contiguous data
void fill(std::span<int> buf, int val);
```

## Error handling

```cpp
// Exceptions for truly exceptional conditions — not control flow
// std::expected (C++23) or std::optional for expected failures

// C++23 expected:
std::expected<Config, std::string> parse_config(std::string_view path) {
    if (!std::filesystem::exists(path)) return std::unexpected("File not found");
    // ...
}

// Optional for "maybe has a value"
std::optional<User> find_user(int id) {
    auto it = users.find(id);
    if (it == users.end()) return std::nullopt;
    return it->second;
}
auto user = find_user(42);
if (user) { /* use *user */ }
```

## Templates — keep them readable

```cpp
// Concepts (C++20) over SFINAE — self-documenting
template<std::integral T>
T clamp(T val, T lo, T hi) {
    return std::min(std::max(val, lo), hi);
}

// Variadic templates for forwarding
template<typename T, typename... Args>
std::unique_ptr<T> make(Args&&... args) {
    return std::make_unique<T>(std::forward<Args>(args)...);
}
```

## CMake — modern style

```cmake
cmake_minimum_required(VERSION 3.20)
project(myapp VERSION 1.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)   # for clangd LSP

add_executable(myapp src/main.cpp src/engine.cpp)
target_include_directories(myapp PRIVATE include)
target_compile_options(myapp PRIVATE -Wall -Wextra -Wpedantic)

# Dependencies via FetchContent or find_package
find_package(fmt REQUIRED)
target_link_libraries(myapp PRIVATE fmt::fmt)
```

## C — systems / embedded

```c
/* Explicit resource management — every malloc has a free */
char *buf = malloc(size);
if (!buf) { perror("malloc"); return -ENOMEM; }
/* ... */
free(buf);
buf = NULL;   /* null after free — prevents use-after-free */

/* Error returns — Linux kernel style */
int do_thing(struct ctx *ctx) {
    int ret;
    if (!ctx) return -EINVAL;
    ret = step_one(ctx);
    if (ret < 0) return ret;
    ret = step_two(ctx);
    if (ret < 0) goto err_cleanup;
    return 0;
err_cleanup:
    cleanup_one(ctx);
    return ret;
}

/* Struct initialization — zero-initialize with designated init */
struct Config cfg = { .timeout = 30, .retries = 3 };
```

## Undefined behavior — avoid these

```cpp
// Signed integer overflow → UB (use unsigned or check before)
// Accessing out-of-bounds array → UB (use .at() or bounds check)
// Null pointer dereference → UB (check before deref)
// Use after free → UB (smart pointers prevent this in C++)
// Uninitialized read → UB (always initialize)
// Strict aliasing violation → use memcpy for type-punning or -fno-strict-aliasing
```

## Sanitizers — always use during development

```bash
# Address + UB sanitizers — catch memory bugs and UB at runtime
cmake -DCMAKE_CXX_FLAGS="-fsanitize=address,undefined" ..

# Thread sanitizer — catch data races
cmake -DCMAKE_CXX_FLAGS="-fsanitize=thread" ..

# Valgrind — memory leak detection
valgrind --leak-check=full --error-exitcode=1 ./myapp
```

## Performance

- `std::vector` over `std::list` — cache-friendly sequential access
- Avoid virtual functions in hot loops — branch misprediction + cache miss
- `[[likely]]` / `[[unlikely]]` hints for branch prediction
- Measure with `perf stat` / `perf record` before optimizing
- `-O2` for release, `-O0 -g` for debug — never optimize debug builds
