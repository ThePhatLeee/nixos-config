---
name: design
description: Use when designing UI, choosing visual aesthetics, building landing pages, creative coding, or targeting Awwwards quality. Triggers on: design this, make it look good, visual direction, aesthetic, landing page, portfolio, hero section, Awwwards, creative.
---

# Design / UI-UX — S++ Tier

Every design decision must have intent. Generic output is failure.
Target: the thing someone screenshots and sends to a friend.

## Before touching code: commit to a direction

Pick ONE extreme aesthetic and execute it without compromise:

| Direction | Vibe | Typography | Motion |
|---|---|---|---|
| **Brutalist** | raw, structural, confrontational | Impact, wide tracking, all-caps | snap cuts, no easing |
| **Luxury / Editorial** | refined, generous whitespace, restrained | Didot-style serif display + clean sans | slow dissolves, subtle parallax |
| **Retro-futurism** | CRT scanlines, neon on dark, grid | Mono or condensed grotesque | flicker, glitch, scan |
| **Organic / Natural** | noise textures, soft gradients, rounded | Humanist sans or handwritten display | spring physics, breath |
| **Maximalist** | dense, layered, every surface active | Clashing type sizes, multiple weights | stagger everything |
| **Hyperminimalist** | one color, one weight, space as element | Single font, one size difference | almost none |
| **Dark Sci-fi** | deep surface, precise lines, technical UI | Monospace or geometric sans | precise, mechanical |

**The rule:** Make a choice in the first 30 seconds. Indecision produces beige.

## Typography — the biggest lever

```css
/* Fluid type scale — clamp(min, preferred, max) */
--text-sm:   clamp(0.8rem,  0.75rem + 0.25vw, 0.9rem);
--text-base: clamp(1rem,    0.95rem + 0.25vw, 1.125rem);
--text-lg:   clamp(1.25rem, 1.1rem  + 0.5vw,  1.5rem);
--text-xl:   clamp(1.5rem,  1.25rem + 1vw,    2.25rem);
--text-2xl:  clamp(2rem,    1.5rem  + 2vw,    3.5rem);
--text-display: clamp(3rem, 2rem + 5vw, 8rem);
```

**Pairing philosophy:**
- Display font: expressive, one strong personality
- Body font: neutral, readable — it disappears, display headlines
- Never more than 2 fonts. 1 font with variable axes (weight, width) is often better.

**Anti-generic fonts to reach for:**
- Display: Playfair Display, Cormorant, Cabinet Grotesk, Syne, Clash Display, Fraunces
- Mono: Geist Mono, JetBrains Mono, Fragment Mono
- Sans: DM Sans, Satoshi, Plus Jakarta Sans, Bricolage Grotesque
- Avoid unless specifically right: Inter, Roboto, Helvetica, Open Sans, Space Grotesk (overused)

## Color — dominant + accent

```css
/* Not: spread palette evenly. Do: pick a dominant + one sharp accent */
--surface:     #0f0f0f;
--surface-alt: #1a1a1a;
--text:        #f0efeb;
--text-muted:  #808080;
--accent:      #c8ff00;   /* one vivid accent is enough */
--accent-dim:  #8aad00;
```

Compline palette (this system's theme):
```
Surface: #1a1d21   Surface variant: #22262b
Text: #f0efeb      Secondary: #e0dcd4
Accent: #b4bcc4    Outline: #3d424a
Error: #cdacac     Muted: #515761
```

## Motion — earn every animation

```js
// Lenis smooth scroll (always)
import Lenis from 'lenis'
const lenis = new Lenis({ duration: 1.2, easing: t => Math.min(1, 1.001 - Math.pow(2, -10 * t)) })
function raf(time) { lenis.raf(time); requestAnimationFrame(raf) }
requestAnimationFrame(raf)

// GSAP ScrollTrigger pattern
gsap.from('.hero-text', {
  scrollTrigger: { trigger: '.hero', start: 'top 80%', toggleActions: 'play none none reverse' },
  y: 60, opacity: 0, duration: 1, ease: 'power3.out', stagger: 0.15
})
```

**Motion rules:**
- Entrance: ease-out (fast start, slow settle) — `power3.out`, `expo.out`
- Exit: ease-in (slow start, fast leave) — `power2.in`
- State change: ease-in-out — `power2.inOut`
- Duration: 80-150ms micro, 200-400ms standard, 600-1200ms hero/page transitions
- `prefers-reduced-motion`: always provide fallback — `@media (prefers-reduced-motion: reduce)`
- Stagger siblings: 0.05-0.15s offset, not all at once

## Spatial composition

- **Asymmetry > symmetry**: offset elements create tension and interest
- **Grid-breaking**: one element escapes the grid intentionally
- **Generous margins**: whitespace is not wasted space — it IS the design
- **Depth**: overlap, shadows, scale — create a z-axis on a flat screen
- **Density contrast**: tight information zone surrounded by breathing room

## Anti-generic checklist

Before shipping, verify:
- [ ] No gradient going from purple to blue on white background
- [ ] No rounded cards floating on grey background with subtle box-shadow
- [ ] No "hero with big text left, image right" without twist
- [ ] No Inter or Roboto unless it's the intentional restraint choice
- [ ] Every section has a reason to exist (cut what can be cut)
- [ ] At least one element that makes someone stop scrolling

## Component states (never forget)
Default → Hover → Focus → Active → Disabled → Loading → Error → Empty
Design ALL states. An unstyled focus ring is a design failure.

## Spacing system
```css
/* 4px base, 8px rhythm */
--space-1: 4px;   --space-2: 8px;   --space-3: 12px;
--space-4: 16px;  --space-6: 24px;  --space-8: 32px;
--space-12: 48px; --space-16: 64px; --space-24: 96px;
```

No magic pixel values. Everything on the scale.

## Awwwards reference signals
What makes SOTD vs just good:
1. **One unexpected detail** — a cursor that responds to scroll, text that reacts to cursor, a texture that breathes
2. **Typography that works hard** — not just readable, but expressive
3. **Transitions that feel inevitable** — motion that explains the relationship between states
4. **Restraint in the right places** — knowing when NOT to add
5. **Responsive that doesn't just shrink** — mobile is a different experience, not a shrunk desktop
