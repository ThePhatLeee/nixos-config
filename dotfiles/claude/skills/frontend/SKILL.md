---
name: frontend
description: Use when building web UIs, React components, JavaScript/JSX, HTML/CSS, Tailwind. Triggers on: React, component, JSX, useState, useEffect, Tailwind, DOM, web UI, JavaScript frontend, hook, context.
---

# Frontend Guidelines — JavaScript / React / Tailwind

JavaScript only. No TypeScript. Use JSDoc `/** @param {string} name */` where type info genuinely helps — sparingly, not everywhere.

## React — component model

```jsx
// Single responsibility, one component per file
// Props: destructure at signature, defaults inline
function Card({ title, description, variant = 'default', onClick }) {
  return (
    <article className={cn('card', `card--${variant}`)} onClick={onClick}>
      <h2 className="card__title">{title}</h2>
      <p>{description}</p>
    </article>
  )
}
```

**State:**
- Local `useState` first — don't reach for global state prematurely
- Lift to shared parent when two siblings need the same state
- Context for truly cross-cutting concerns (theme, auth, locale)
- Zustand for complex client state that genuinely needs global management

**Effects:**
```js
// Clear dependency arrays — always explicit
useEffect(() => {
  const handler = (e) => setSize({ w: window.innerWidth, h: window.innerHeight })
  window.addEventListener('resize', handler)
  return () => window.removeEventListener('resize', handler)
}, []) // empty = mount/unmount only

// Cleanup matters — see /threejs for canvas cleanup
```

**Performance:**
- `useMemo` / `useCallback` only after profiling shows a real problem — not by default
- `key` in lists: stable unique IDs, never array index
- Lazy-load heavy components: `const Heavy = lazy(() => import('./Heavy'))`
- `Suspense` boundaries around lazy/async components

**Forms:**
```jsx
// Controlled for complex validation, uncontrolled (ref) for simple cases
function LoginForm() {
  const [form, setForm] = useState({ email: '', password: '' })
  const set = field => e => setForm(prev => ({ ...prev, [field]: e.target.value }))

  return (
    <form onSubmit={handleSubmit}>
      <input value={form.email} onChange={set('email')} type="email" />
    </form>
  )
}
```

## JavaScript patterns

```js
// Optional chaining + nullish coalescing
const city = user?.address?.city ?? 'Unknown'

// Array methods over imperative loops
const totals = orders.filter(o => o.active).map(o => o.total).reduce((a, b) => a + b, 0)

// Destructuring with defaults
const { name = 'Guest', role = 'viewer' } = user

// Template literals
const url = `${API_BASE}/users/${userId}/posts?page=${page}`

// Object shorthand
const obj = { name, value, fn: () => {} }

// Spread for immutable updates
const next = { ...prev, updated: true }
const list = [...arr, newItem]

// async/await — no raw .then() chains
async function fetchUser(id) {
  try {
    const res = await fetch(`/api/users/${id}`)
    if (!res.ok) throw new Error(`HTTP ${res.status}`)
    return await res.json()
  } catch (err) {
    console.error('fetchUser failed:', err)
    throw err
  }
}
```

## Tailwind CSS

```jsx
// Compose conditional classes with cn() (clsx + tailwind-merge)
import { cn } from '@/lib/utils'

<button className={cn(
  'px-4 py-2 rounded-lg font-medium transition-colors',
  variant === 'primary' && 'bg-blue-600 text-white hover:bg-blue-700',
  variant === 'ghost'   && 'text-gray-600 hover:bg-gray-100',
  disabled              && 'opacity-50 cursor-not-allowed pointer-events-none'
)}>

// Design tokens over magic values — use theme scale
// good: p-4 gap-6 text-sm  |  bad: p-[17px] text-[13.5px]
// Arbitrary values only for one-offs that genuinely don't fit the scale

// Extract to component, not @apply
// 3+ repeated utility groups → new component, not CSS class
```

**Tailwind v4:**
```css
/* @import instead of @tailwind directives */
@import "tailwindcss";

/* CSS-first config */
@theme {
  --color-accent: oklch(70% 0.2 250);
  --font-display: 'Cabinet Grotesk', sans-serif;
}
```

## SCSS — when to reach for it
Use SCSS for things Tailwind can't express:
```scss
// Complex keyframe animations
@keyframes liquid {
  0%, 100% { border-radius: 60% 40% 30% 70% / 60% 30% 70% 40%; }
  50%       { border-radius: 30% 60% 70% 40% / 50% 60% 30% 60%; }
}

// Nested pseudo-elements with computed values
.card {
  &::before {
    content: '';
    inset: 0;
    background: linear-gradient(135deg, var(--accent), transparent);
    opacity: 0;
    transition: opacity 200ms ease;
  }
  &:hover::before { opacity: 1; }
}

// Third-party library overrides (contain specificity)
.swiper-wrapper { gap: var(--space-4); }
```

Max 3 levels of nesting. BEM for hand-written class names.

## Modern CSS patterns
```css
/* Container queries */
@container card (min-width: 400px) {
  .card__layout { display: grid; grid-template-columns: 1fr 2fr; }
}

/* :has() — style parent by child state */
.form:has(:invalid) .submit-btn { opacity: 0.5; }

/* CSS custom properties for theming */
:root { --surface: #1a1d21; --text: #f0efeb; }
.card { background: var(--surface); color: var(--text); }

/* scroll-driven animations */
@keyframes reveal { from { opacity: 0; translate: 0 2rem; } to { opacity: 1; translate: 0; } }
.section {
  animation: reveal linear both;
  animation-timeline: view();
  animation-range: entry 0% entry 30%;
}
```

## Performance
- Images: `loading="lazy"`, explicit `width`/`height`, WebP/AVIF format
- Dynamic import for heavy components: `const Map = lazy(() => import('./Map'))`
- Fonts: `font-display: swap`, subset via `unicode-range`, self-host don't rely on CDN timing
- Animations: `transform` + `opacity` only (compositor layer). Never `top`, `left`, `width` in animation
- Bundle: analyse with `vite-bundle-visualizer`, chunk at route level

## Accessibility
- Semantic HTML first: `<button>` not `<div onClick>`, `<nav>` landmark
- ARIA only when semantic HTML is insufficient
- Visible focus rings (don't `outline: none` without replacement)
- `alt` on all meaningful images, `alt=""` on decorative
- `prefers-reduced-motion`: honour it in all JS animations
