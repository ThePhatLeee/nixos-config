---
name: css
description: Use for CSS architecture, SCSS/Sass, animations, custom properties, layout systems, and styling. Triggers on: CSS, SCSS, Sass, animation, keyframe, custom property, grid, flexbox, BEM, PostCSS.
---

# CSS / SCSS

## Architecture: when to use what

| Need | Use |
|---|---|
| Responsive layout, spacing, color | Tailwind utilities |
| Complex animations / keyframes | SCSS `@keyframes` |
| Deeply nested pseudo-elements | SCSS `&::before`, `&::after` |
| Third-party library overrides | SCSS (contain specificity) |
| Design tokens / theming | CSS custom properties |
| Anything Tailwind expresses cleanly | Tailwind — not SCSS |

Max 3 levels of SCSS nesting. BEM for all hand-written class names.

## SCSS patterns

```scss
// Keyframe animation
@keyframes liquid {
  0%, 100% { border-radius: 60% 40% 30% 70% / 60% 30% 70% 40%; }
  50%       { border-radius: 30% 60% 70% 40% / 50% 60% 30% 60%; }
}

// Pseudo-element with transition
.card {
  position: relative;
  &::before {
    content: '';
    inset: 0;
    background: linear-gradient(135deg, var(--accent), transparent);
    opacity: 0;
    transition: opacity 200ms ease;
  }
  &:hover::before { opacity: 1; }
}

// Third-party override — scoped, not global
.swiper-wrapper { gap: var(--space-4); }
```

## Custom properties — the right pattern

```css
/* Design tokens at :root */
:root {
  --surface:     #1a1d21;
  --surface-alt: #22262b;
  --text:        #f0efeb;
  --text-muted:  #515761;
  --accent:      #b4bcc4;
  --outline:     #3d424a;
}

/* Component tokens — inherit from global */
.button {
  --btn-bg:   var(--surface-alt);
  --btn-text: var(--text);
  background: var(--btn-bg);
  color:      var(--btn-text);
}
.button--primary {
  --btn-bg:   var(--accent);
  --btn-text: var(--surface);
}
```

## Modern layout

```css
/* Fluid grid — auto-fill columns, min 280px */
.grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(280px, 1fr)); gap: var(--space-6); }

/* Stack — vertical flow with gap */
.stack { display: flex; flex-direction: column; gap: var(--space-4); }

/* Cluster — wrapping horizontal group */
.cluster { display: flex; flex-wrap: wrap; gap: var(--space-3); align-items: center; }

/* Sidebar layout */
.with-sidebar {
  display: flex; flex-wrap: wrap; gap: var(--space-6);
  > :first-child { flex-basis: 300px; flex-grow: 1; }
  > :last-child  { flex-basis: 0; flex-grow: 999; min-width: min(60%, 400px); }
}
```

## Modern CSS features

```css
/* Container queries — component responds to its container, not viewport */
.card-container { container-type: inline-size; }
@container (min-width: 400px) {
  .card__layout { display: grid; grid-template-columns: 1fr 2fr; }
}

/* :has() — style parent by child state */
.form:has(:invalid) .submit-btn { opacity: 0.5; }
.card:has(img)      .card__text { padding-top: var(--space-2); }

/* Scroll-driven animation */
@keyframes reveal { from { opacity: 0; translate: 0 2rem; } to { opacity: 1; translate: 0; } }
.section {
  animation: reveal linear both;
  animation-timeline: view();
  animation-range: entry 0% entry 30%;
}

/* View transitions */
@view-transition { navigation: auto; }
::view-transition-old(root) { animation: fade-out 200ms ease-in; }
::view-transition-new(root) { animation: fade-in  200ms ease-out; }
```

## Fluid type scale

```css
--text-sm:      clamp(0.8rem,  0.75rem + 0.25vw, 0.9rem);
--text-base:    clamp(1rem,    0.95rem + 0.25vw, 1.125rem);
--text-lg:      clamp(1.25rem, 1.1rem  + 0.5vw,  1.5rem);
--text-xl:      clamp(1.5rem,  1.25rem + 1vw,    2.25rem);
--text-2xl:     clamp(2rem,    1.5rem  + 2vw,    3.5rem);
--text-display: clamp(3rem,    2rem    + 5vw,    8rem);
```

## Spacing system

```css
/* 4px base, 8px rhythm — no magic values */
--space-1: 4px;   --space-2: 8px;   --space-3: 12px;
--space-4: 16px;  --space-6: 24px;  --space-8: 32px;
--space-12: 48px; --space-16: 64px; --space-24: 96px;
```

## Animation performance

Only animate `transform` and `opacity` — these run on the compositor thread.
Never animate `top`, `left`, `width`, `height`, `margin`, `padding` in transitions.

```css
/* Good */
.modal { transform: translateY(20px); opacity: 0; transition: transform 300ms ease-out, opacity 200ms ease; }
.modal.open { transform: none; opacity: 1; }

/* Bad — triggers layout reflow */
.modal { top: -20px; transition: top 300ms; }
```

```css
/* Reduced motion */
@media (prefers-reduced-motion: reduce) {
  *, *::before, *::after { animation-duration: 0.01ms !important; transition-duration: 0.01ms !important; }
}
```

## BEM naming

```scss
// Block__Element--Modifier
.card { }
.card__title { }
.card__body { }
.card--featured { }
.card--loading .card__title { opacity: 0.5; }
```

Never use tag selectors for styling — class only. No `div.card`, no `ul > li`.

## Print / media

```css
@media print {
  nav, .sidebar, .ads { display: none; }
  body { font-size: 12pt; color: black; background: white; }
  a::after { content: " (" attr(href) ")"; }
  @page { margin: 2cm; }
}
```
