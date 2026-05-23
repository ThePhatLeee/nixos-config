---
name: web-vitals
description: Use to measure and improve LCP/INP/CLS, run Lighthouse-style audits, profile Three.js/WebGL frame time, analyze Playwright traces, or diagnose perf regressions. Auto-triggers on: web vitals, LCP, INP, CLS, lighthouse, performance audit, frame time, three.js perf, slow site, perf regression.
---

# Web Vitals + Perf

Core Web Vitals (2025):
- **LCP** Largest Contentful Paint — visual completeness. Target < 2.5s.
- **INP** Interaction to Next Paint — responsiveness. Target < 200ms.
- **CLS** Cumulative Layout Shift — stability. Target < 0.1.

Also matters: TTFB < 600ms, TBT < 200ms, total blocking < 50ms long-tasks.

Measure on real 4G+throttling, not localhost. Field data (RUM) beats lab data (Lighthouse) for actual users.

## Tooling

| tool                       | when                                                       |
|----------------------------|------------------------------------------------------------|
| Chrome DevTools Performance| Frame-by-frame, layout, paint, scripting attribution       |
| Lighthouse                 | Quick lab score, regression detection                      |
| WebPageTest                | Real-device + network, filmstrip, multi-step               |
| `web-vitals` library       | RUM in prod                                                |
| Playwright `tracing.start` | Repeatable measurement in CI                               |
| Chrome `performance.mark`  | Custom measurements (e.g., "hero ready")                   |

## LCP — diagnose and fix

1. Identify the LCP element: DevTools → Performance → "LCP" marker
2. Check the LCP delivery breakdown:
   - **TTFB** — server slow? Use SSG/edge, cache, CDN.
   - **Resource load delay** — preconnect, preload, HTTP/2 priorities
   - **Resource load time** — image size, format (AVIF/WebP), responsive `srcset`
   - **Render delay** — render-blocking CSS/JS, web fonts, hydration

```html
<!-- Preload LCP image -->
<link rel="preload" as="image" href="/hero.avif" fetchpriority="high">
<!-- Or for above-fold image -->
<img src="/hero.avif" alt="..." fetchpriority="high" decoding="async">
```

```html
<!-- Preconnect to font CDN before request fires -->
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
```

```css
/* Avoid font-related LCP swap */
@font-face {
  font-family: "Display";
  src: url("/fonts/display.woff2") format("woff2");
  font-display: swap;
  size-adjust: 100%; /* tune to match fallback metrics */
}
```

## INP — interaction latency

INP measures the worst (98th-percentile) interaction during the session. Single bad click ruins it.

Diagnose:
- DevTools → Performance → click during recording → look at long task on main thread after the interaction
- Long Animation Frames API (`PerformanceObserver { type: 'long-animation-frame' }`) gives attribution

Fix:
- Break long tasks: `scheduler.yield()` or `await new Promise(r => setTimeout(r, 0))`
- Defer non-critical work to `requestIdleCallback`
- Move heavy work off main thread: Web Workers, OffscreenCanvas
- Debounce/throttle high-frequency handlers (scroll, mousemove, input)
- React: avoid synchronous state updates in input handlers; `startTransition` for non-urgent updates
- Hydration: ship less JS, use islands/partial hydration

```js
// Yield to main thread between chunks
async function processLargeList(items) {
  for (let i = 0; i < items.length; i++) {
    process(items[i])
    if (i % 50 === 0 && 'scheduler' in window) await scheduler.yield()
  }
}
```

## CLS — layout stability

Hunt for shifts:
- DevTools → Performance → "Experience" track shows shifts with bounding boxes
- Or `PerformanceObserver({ type: 'layout-shift' })` to log all shifts

Common causes:
- Image without explicit dimensions → `width` + `height` attrs (or `aspect-ratio: 16 / 9` in CSS)
- Web font swap reflow → `font-display: swap` + `size-adjust` tuning, or `font-display: optional` for hero
- Ad/embed inserts → reserve space with min-height
- Dynamic content above viewport → don't insert above current scroll without preserving scroll position
- Transitions on dimensions (`height`/`width`) → use `transform: scale()` instead

## Three.js / WebGL frame time

Target: 16.67ms (60fps) on the target device. On a 120Hz display, target 8.33ms.

```js
// Inline frame-time HUD
const stats = new (await import('three/examples/jsm/libs/stats.module.js')).default()
document.body.appendChild(stats.dom)
function tick() {
  stats.begin()
  renderer.render(scene, camera)
  stats.end()
  requestAnimationFrame(tick)
}
```

Key numbers in Chrome DevTools → Performance after recording:
- **Frame time** > 16.67ms = jank
- **GPU process** time vs main-thread time — locates the bottleneck
- **`renderer.info.render`** — draw calls, triangles, points, lines

Top fixes (in order):
1. **Draw calls** > 100 for a "simple" scene → merge meshes (`BufferGeometryUtils.mergeGeometries`) or `InstancedMesh`
2. **Texture size** — compress with KTX2/Basis; cap at 2048×2048 atlases
3. **Transparent draws** sort cost → cull aggressively, use `depthWrite: false` only where needed
4. **Post-processing** — Bloom + DoF + SMAA together easily costs 8ms; profile each pass
5. **Pixel ratio** > 2 → cap with `setPixelRatio(Math.min(devicePixelRatio, 2))`
6. **Shader complexity** — measure with `WEBGL_debug_shaders` extension; simplify branches
7. **Animation loop** — don't update unchanged uniforms; cache `Math.sin/cos` results across frames

## Lighthouse — what the scores actually mean

Performance score is a weighted composite. Weighting (as of v12):
- LCP 25%, TBT 30%, CLS 25%, FCP 10%, SI 10%

A 90+ score requires all green. A 100 is hard with any third-party scripts. Don't optimize for the score; optimize for the values, and the score follows.

```bash
npx lighthouse https://example.com --view --preset=desktop --throttling.cpuSlowdownMultiplier=1
npx lighthouse https://example.com --view  # default = mobile + 4G throttle
```

## Playwright trace for CI regression

```js
// playwright.config.js
use: { trace: 'on-first-retry' }

// In test
await page.goto('https://example.com')
const metrics = await page.evaluate(() => new Promise(resolve => {
  new PerformanceObserver(list => {
    const entries = list.getEntries()
    const lcp = entries.find(e => e.entryType === 'largest-contentful-paint')
    if (lcp) resolve({ lcp: lcp.startTime })
  }).observe({ type: 'largest-contentful-paint', buffered: true })
}))
expect(metrics.lcp).toBeLessThan(2500)
```

## Common regressions

- New third-party script (analytics, A/B test) → main-thread blocking
- Hero image swapped to non-optimized format → LCP up
- Font weight added to `font-family` declaration but `<link>` not updated → fallback reflow + CLS
- Adding a wrapper `<div>` around hero shifts layout → CLS jump
- Hydration boundary moved → INP regression on first click
- New WebGL effect → frame time over 16ms on low-end target

## Anti-patterns

- "It works on my M3 MacBook" — that's not the audience
- Optimizing FCP while ignoring LCP — FCP is meaningless without content
- Caching the homepage but not the assets it loads
- Image lazy-loading the hero (above the fold = `eager` or no attr)
- `will-change: transform` on everything — defeats the purpose, eats GPU memory
- Preloading 12 fonts because "we might use them"
- Measuring on cable WiFi and calling it done
