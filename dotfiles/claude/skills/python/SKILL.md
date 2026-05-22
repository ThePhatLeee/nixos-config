---
name: python
description: Use for Python scripts, automation, data processing, CLI tools, FastAPI, or any Python work. Triggers on: Python, pip, venv, FastAPI, pandas, script, .py, asyncio, dataclass, pytest.
---

# Python

## Version: 3.11+ assumed

## Style

```python
# Type hints always — they're documentation that tools can check
def process_users(users: list[dict[str, str]], limit: int = 100) -> list[str]:
    return [u["name"] for u in users[:limit]]

# Dataclasses over plain dicts for structured data
from dataclasses import dataclass, field

@dataclass
class Config:
    host: str
    port: int = 8080
    tags: list[str] = field(default_factory=list)
    debug: bool = False
```

## Error handling

```python
# Specific exceptions — never bare except:
try:
    data = json.loads(raw)
except json.JSONDecodeError as e:
    logger.error("Invalid JSON: %s", e)
    raise ValueError(f"Malformed response from {url}") from e

# Context managers for resources
with open(path, "r", encoding="utf-8") as f:
    content = f.read()

# pathlib over os.path
from pathlib import Path
config_path = Path.home() / ".config" / "app" / "config.toml"
config_path.parent.mkdir(parents=True, exist_ok=True)
```

## Itertools and comprehensions

```python
from itertools import groupby, chain, islice

# List comprehension over map/filter for simple transforms
emails = [u["email"] for u in users if u.get("active")]

# Generator for large sequences — avoid materializing full list
def read_chunks(path: Path, size: int = 8192):
    with open(path, "rb") as f:
        while chunk := f.read(size):
            yield chunk

# Dict comprehension
by_id = {u["id"]: u for u in users}

# groupby — sort first, groupby is not a hash groupby
data.sort(key=lambda x: x["category"])
groups = {k: list(v) for k, v in groupby(data, key=lambda x: x["category"])}
```

## Async

```python
import asyncio
import httpx  # async http — never requests in async context

async def fetch_all(urls: list[str]) -> list[dict]:
    async with httpx.AsyncClient(timeout=10.0) as client:
        tasks = [client.get(url) for url in urls]
        responses = await asyncio.gather(*tasks, return_exceptions=True)
        return [r.json() for r in responses if not isinstance(r, Exception)]

# Semaphore for concurrency limiting
sem = asyncio.Semaphore(10)
async def fetch_one(client, url):
    async with sem:
        return await client.get(url)
```

## FastAPI

```python
from fastapi import FastAPI, Depends, HTTPException, status
from pydantic import BaseModel

app = FastAPI()

class PostCreate(BaseModel):
    title: str
    body: str

class PostResponse(BaseModel):
    id: int
    title: str
    body: str

    model_config = {"from_attributes": True}

@app.post("/posts", response_model=PostResponse, status_code=status.HTTP_201_CREATED)
async def create_post(data: PostCreate, db: Session = Depends(get_db)):
    post = Post(**data.model_dump())
    db.add(post)
    db.commit()
    db.refresh(post)
    return post

@app.get("/posts/{post_id}", response_model=PostResponse)
async def get_post(post_id: int, db: Session = Depends(get_db)):
    post = db.get(Post, post_id)
    if not post:
        raise HTTPException(status_code=404, detail="Post not found")
    return post
```

## Scripts and CLI

```python
import argparse
import sys

def main():
    parser = argparse.ArgumentParser(description="Process files")
    parser.add_argument("files", nargs="+", type=Path, help="Input files")
    parser.add_argument("-o", "--output", type=Path, default=Path("out"))
    parser.add_argument("-v", "--verbose", action="store_true")
    args = parser.parse_args()

    logging.basicConfig(level=logging.DEBUG if args.verbose else logging.INFO)
    # ...

if __name__ == "__main__":
    main()
```

## Testing with pytest

```python
import pytest

@pytest.fixture
def sample_config(tmp_path):
    config_file = tmp_path / "config.toml"
    config_file.write_text('[server]\nport = 9090\n')
    return config_file

def test_parses_port(sample_config):
    config = load_config(sample_config)
    assert config.port == 9090

def test_missing_file_raises():
    with pytest.raises(FileNotFoundError):
        load_config(Path("/nonexistent"))

# Parametrize for table-driven tests
@pytest.mark.parametrize("inp,expected", [
    ("hello world", "hello_world"),
    ("  spaces  ", "spaces"),
    ("", ""),
])
def test_normalize(inp, expected):
    assert normalize(inp) == expected
```

## Environment and packaging

```toml
# pyproject.toml (not setup.py)
[build-system]
requires = ["hatchling"]
build-backend = "hatchling.build"

[project]
name = "myapp"
version = "0.1.0"
requires-python = ">=3.11"
dependencies = ["httpx>=0.27", "pydantic>=2.0"]

[project.scripts]
myapp = "myapp.cli:main"
```

```bash
# uv for fast venv + deps (preferred over pip/poetry)
uv venv && source .venv/bin/activate
uv pip install -e ".[dev]"
```

## Common pitfalls

- Mutable default arguments: `def f(x=[])` — use `None` and set inside
- `datetime.utcnow()` is deprecated (Python 3.12) — use `datetime.now(UTC)`
- `dict` iteration order is guaranteed insertion-order (Python 3.7+) — no need for OrderedDict
- `is` vs `==`: `is None` (identity), `== "string"` (equality) — never `is "string"`
- `requests` in async context blocks the event loop — use `httpx` or `aiohttp`
