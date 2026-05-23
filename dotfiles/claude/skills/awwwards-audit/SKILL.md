---
name: awwwards-audit
description: Awwwards-tier pre-submission and pre-review checklist. Use before submitting an SOTD/Honors candidate, before client handoff, or to triage what's stopping a site from feeling premium. Covers: hero motion, scroll choreography, perf budget, accessibility floor, browser matrix, image pipeline, motion semantics. Auto-triggers on: awwwards, sotd, jury, premium UI, audit my site, design review, before launch.
---

# Awwwards Audit

Awwwards juries reward: **strong concept**, **execution polish**, **navigation/UX clarity**, **mobile parity**, **typography rigor**, **performance under that ambition**. The bar is "did this teach me something or move me?", not "did it animate?".

Run this as a full pass before submission. Bring screenshots/recordings for each finding.

## Concept (worth 30% of the score in practice)

- [ ] One-line "what is this site, and why does this aesthetic" — if you can't, rework the concept
- [ ] Visual concept and brand are consistent across pages, not just the hero
- [ ] No filler effects (parallax + scroll-snap + gradient blob + cursor follower stack is *not* a concept)
- [ ] Typography establishes voice: a display face that means something, body face that's readable

## Hero / above the fold (8 seconds to convince)

- [ ] LCP element identified — image, heading, or canvas frame; not a third-party widget
- [ ] First frame paints under 1.5s on 4G; hero motion starts within 100ms of that
- [ ] Hero motion has a clear arc: entrance → settle → loop or end. No motion that "just goes"
- [ ] If hero is canvas/WebGL: fallback static image renders for `prefers-reduced-motion`, slow GPU, or first paint before WebGL ready
- [ ] Hero text contrast meets WCAG AA against worst frame of any video/animation behind it
- [ ] No CLS from hero — explicit width/height on every image, `font-display: swap` with size-adjust to prevent reflow

## Scroll choreography

- [ ] Every scroll-triggered animation has a reason — "this reveal teaches me what's next"
- [ ] Smooth scroll (Lenis) at 60fps even with pinned sections; no jank on trackpad inertia
- [ ] No competing scroll handlers — one source of truth for scroll position
- [ ] Pin/unpin transitions don't snap; pinned sections release cleanly
- [ ] Scroll-driven animations honor `prefers-reduced-motion` — instant state changes, no motion
- [ ] Section transitions are intentional: shared elements morph, color carries through, type leads
- [ ] Mobile scroll is honored: pin/sticky becomes simple stack on touch + small viewport

## Navigation / IA

- [ ] Hamburger or menu reveals what the site contains in under 1 second
- [ ] Menu state is announced to assistive tech (`aria-expanded`, focus trap, escape closes)
- [ ] Active page indicator works on every route, not just home
- [ ] CTA hierarchy clear — one primary, optional secondary, no "everything is highlighted"
- [ ] Footer has the navigation a sceptic needs (contact, services, work, about, legal)
- [ ] 404 page is on-brand, not a default

## Typography rigor

- [ ] Type scale is a system, not picked per page (modular scale: 1.125 / 1.25 / 1.333 / Golden)
- [ ] No more than two font families (display + body); a third for monospace if needed
- [ ] Hyphenation + orphan/widow control on long body text (`text-wrap: pretty`)
- [ ] Line length 45–75ch; line-height 1.4–1.7 for body, 1.0–1.2 for display
- [ ] No fake bold (`font-weight: bold` on a font that doesn't ship bold) — load the weight you use
- [ ] Italics where editorial intent demands, not for "emphasis spam"
- [ ] Trademark glyphs (`—` for em-dash, `'` for apostrophe, `"` "" for quotes) used correctly

## Color + light

- [ ] Color palette has hierarchy: surface → text → accent (1 dominant accent, max 1 secondary)
- [ ] Contrast tested at AA minimum for body, AAA where possible
- [ ] No pure black (#000) or pure white (#fff) on screen — use near-blacks/whites for warmth
- [ ] Gradients have endpoints that hit visible chroma, no mud in the middle (use OKLCH not HSL for gradient stops)
- [ ] Dark mode (if shipped) is a *design*, not an inverted light theme

## Image pipeline

- [ ] Every `<img>` has explicit `width` + `height` (or `aspect-ratio` CSS)
- [ ] WebP or AVIF served, JPG/PNG fallback only via `<picture>`
- [ ] Hero image preloaded; below-fold images `loading="lazy"`
- [ ] Responsive `srcset` with sane breakpoints (1x, 2x, no more); `sizes` matches actual rendered width
- [ ] CDN serves images with `Cache-Control: max-age=31536000, immutable` and content-hashed filenames
- [ ] LQIP / blur placeholder for hero and major photos — no flash-of-empty-box

## Motion semantics

- [ ] Easing: custom cubic-bezier, never linear except for loaders. `cubic-bezier(0.65, 0, 0.35, 1)` is a sane default
- [ ] Duration matches distance: 200ms for small UI moves, 400–600ms for section transitions, 800ms+ only with intent
- [ ] Hover states have a **leave** animation as polished as the enter; no abrupt revert
- [ ] No motion above 600ms on a button click — feels sluggish
- [ ] Anything looping has a satisfying loop point — frame matches start

## Performance under the ambition

- [ ] **LCP < 2.5s** on real-world 4G+throttling, not localhost
- [ ] **INP < 200ms** — every interactive element responds within
- [ ] **CLS < 0.1** for the whole page lifecycle, not just initial
- [ ] **TTFB < 600ms** (or be explicit why not — edge-rendered, SSG'd, etc.)
- [ ] Three.js / WebGL: < 16ms frame time on M1 / mid-range GPU under typical scroll, profiled with `renderer.info` and Chrome perf panel
- [ ] Bundle: < 200KB JS gzipped for landing, route-split rest
- [ ] No third-party that blocks render (analytics, chat, font loader) — all `async`/`defer` or `<link rel=preconnect>`

## Accessibility floor (the table-stakes pass — not the ceiling)

- [ ] Keyboard navigation: tab order makes sense, all interactive elements reachable
- [ ] Visible focus states — custom is fine, none is failure
- [ ] Screen reader walkthrough: landmarks (header/nav/main/footer), heading hierarchy correct
- [ ] `prefers-reduced-motion`: media query honored everywhere, including JS animations
- [ ] Color is not the sole indicator of state (links underlined or otherwise distinguished)
- [ ] Forms: labels associated, errors announced via `aria-live="polite"`, no "click here" link text
- [ ] Cursor effects that hide the native cursor still respect `pointer:fine` vs `coarse`

## Mobile parity

- [ ] Layout adapts, doesn't just shrink — major sections re-arrange for portrait
- [ ] Touch targets ≥ 44×44px, spaced enough to not mis-tap
- [ ] Hero motion that depends on cursor/mouse has a touch equivalent (gyro, swipe, auto)
- [ ] Heavy WebGL gracefully degrades on iOS Safari (no WebGL2 — use WebGL1 fallback)
- [ ] Mobile testing: actual device, not just Chrome DevTools

## Browser matrix (jury tests Chrome + Safari + Firefox)

- [ ] Tested in Safari Tech Preview — `:has`, `view-transition`, container queries quirks
- [ ] Tested in Firefox — backdrop-filter performance, custom property animation interpolation
- [ ] No flexbox/grid layouts that silently break in older Safari (16.x)
- [ ] `prefers-color-scheme` works in both directions

## Pre-submit final pass

- [ ] All console.log / debug code stripped
- [ ] No 404s in network tab on critical paths
- [ ] No CORS errors, no mixed content warnings
- [ ] Robots.txt + sitemap.xml + OG tags + favicon set
- [ ] OG card renders nicely on iMessage + Twitter + LinkedIn (test, don't assume)
- [ ] Lighthouse score: Performance ≥ 90, Accessibility ≥ 95, Best Practices ≥ 95, SEO ≥ 90
- [ ] Recorded 2 walkthroughs (desktop + mobile) at 60fps for the submission

## Common reasons SOTD candidates miss

- Concept good, mobile is afterthought (heavy WebGL with no mobile path)
- Hero amazing, rest of site is template
- Motion impressive but no semantic load — "what did that animation tell me?"
- Performance ignored — gorgeous but 8s LCP on 4G
- Accessibility ignored — perfect demo, fails keyboard nav entirely
- Typography from Google Fonts default pairings — feels generic
