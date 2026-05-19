# Frontend Guidelines

## React
- Components: small, single-responsibility, composable. One component per file.
- Typed with TypeScript: typed props interfaces, typed hooks, explicit return types on non-trivial functions.
- State: local `useState` first; lift to context only when truly shared; reach for Zustand/Redux only for complex global state.
- Side effects: `useEffect` with explicit dependency arrays; extract complex effects into custom hooks.
- Memoisation: `useMemo`/`useCallback` only when profiling shows a bottleneck — premature memoisation is noise.
- Keys in lists: stable unique IDs, never array index.

## Tailwind CSS
- Utilities over custom classes. Compose with `cn()` / `clsx` for conditional classes.
- Extract to a component (not a custom CSS class) when a utility group is repeated more than twice.
- Design tokens: use Tailwind's configured theme scale — no magic pixel values.
- Dark mode: `dark:` variants; configure via `class` strategy for toggling.
- Avoid `!important` — restructure specificity instead.

## SCSS
- Use SCSS only for things Tailwind can't express: complex animations, pseudo-element stacking, third-party overrides.
- BEM naming for any hand-written class: `.block__element--modifier`.
- Variables for design tokens that mirror the Tailwind config.
- No deep nesting (max 3 levels).

## Three.js / WebGL
- Dispose everything on unmount: `geometry.dispose()`, `material.dispose()`, `texture.dispose()`, `renderer.dispose()`.
- Use `InstancedMesh` for repeated geometry.
- Prefer `BufferGeometry` over legacy `Geometry`.
- Minimise draw calls: merge static geometry where possible.
- Shader uniforms: update only what changed per frame.
- `requestAnimationFrame` loop: cancel it in cleanup.
- For React integration: use `@react-three/fiber` (`r3f`) — don't manage the render loop manually.

## Performance
- Images: `loading="lazy"`, correct `width`/`height`, modern formats (WebP/AVIF).
- Bundle: dynamic `import()` for heavy dependencies; analyse with `vite-bundle-visualizer`.
- Fonts: `font-display: swap`; subset where possible.
- Animations: prefer CSS transforms/opacity (compositor layer) over layout-triggering properties.

## Accessibility
- Semantic HTML first: `<button>` not `<div onClick>`, `<nav>` not `<div class="nav">`.
- ARIA only when semantic HTML is insufficient.
- Keyboard navigable: focus rings visible, tab order logical.
- Colour contrast: WCAG AA minimum (4.5:1 text, 3:1 UI components).
