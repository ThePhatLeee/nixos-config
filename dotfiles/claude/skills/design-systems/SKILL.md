---
name: design-systems
description: Use when building or extending a design system, defining tokens, mapping Figma components to React code, setting up Code Connect. Awwwards-tier work needs design + code in sync. Auto-triggers on: design system, design tokens, code connect, figma component, token, component library, storybook, brand kit.
---

# Design Systems

A design system is the shared vocabulary between design and code: tokens, components, patterns, motion, voice. Not a Figma library, not a Storybook — both together with explicit mapping.

## Token hierarchy (3 layers)

```
PRIMITIVE          color.blue.500 = #2563eb       (raw values, never used in components)
    ↓
SEMANTIC           color.action.primary = blue.500 (intent, used everywhere)
    ↓
COMPONENT          button.primary.bg = action.primary (component-scoped, optional)
```

Components consume **semantic** tokens. Theme swaps remap semantic → primitive. Never reference primitives from a component.

## Token categories (minimum viable)

```js
// tokens/index.js
export const tokens = {
  color: {
    // primitives
    neutral: { 50: '#f8fafc', 100: '#f1f5f9', ..., 950: '#020617' },
    accent:  { 50: '...', ..., 950: '...' },
    success: { ... }, warning: { ... }, danger: { ... },

    // semantic
    surface: { default: 'neutral.50', raised: 'white', inverse: 'neutral.950' },
    text:    { default: 'neutral.900', muted: 'neutral.600', inverse: 'neutral.50' },
    action:  { primary: 'accent.600', hover: 'accent.700', subtle: 'accent.100' },
    feedback:{ success: 'success.600', warning: 'warning.500', danger: 'danger.600' },
    border:  { default: 'neutral.200', strong: 'neutral.400' },
  },

  space: { 0: '0', 1: '4px', 2: '8px', 3: '12px', 4: '16px', 5: '24px',
           6: '32px', 7: '48px', 8: '64px', 9: '96px', 10: '128px' },

  radius: { none: '0', sm: '4px', md: '8px', lg: '12px', xl: '20px', full: '9999px' },

  type: {
    family: { display: '"Cabinet Grotesk", sans-serif', body: '"Inter", sans-serif',
              mono: '"JetBrains Mono", monospace' },
    size:   { xs: '12px', sm: '14px', base: '16px', lg: '18px', xl: '20px',
              '2xl': '24px', '3xl': '32px', '4xl': '48px', '5xl': '64px', '6xl': '96px' },
    weight: { regular: 400, medium: 500, semibold: 600, bold: 700 },
    leading:{ tight: 1.1, snug: 1.3, normal: 1.5, relaxed: 1.7 },
    tracking:{ tight: '-0.02em', normal: '0', wide: '0.05em' },
  },

  shadow: {
    sm: '0 1px 2px rgb(0 0 0 / 0.06)',
    md: '0 4px 8px rgb(0 0 0 / 0.08)',
    lg: '0 12px 24px rgb(0 0 0 / 0.12)',
    inner: 'inset 0 1px 2px rgb(0 0 0 / 0.05)',
  },

  motion: {
    duration: { fast: '150ms', base: '250ms', slow: '400ms', deliberate: '600ms' },
    easing:   { out: 'cubic-bezier(0.16, 1, 0.3, 1)',
                inOut: 'cubic-bezier(0.65, 0, 0.35, 1)',
                spring: 'cubic-bezier(0.5, 1.6, 0.4, 0.7)' },
  },

  breakpoint: { sm: '640px', md: '768px', lg: '1024px', xl: '1280px', '2xl': '1536px' },
}
```

## Token transport: design ↔ code

### From Figma to code (preferred direction)

1. Define tokens in Figma using **Variables** (Figma's native primitive)
2. Export with **Figma Tokens** plugin or **Tokens Studio** → JSON
3. Run through **Style Dictionary** or **Theo** → CSS variables + JS object

```bash
# Style Dictionary build
npx style-dictionary build  # tokens.json → build/css/_variables.css + build/js/tokens.js
```

`config.json`:
```json
{
  "source": ["tokens/**/*.json"],
  "platforms": {
    "css":  { "transformGroup": "css",  "buildPath": "build/css/",
              "files": [{ "destination": "_variables.css", "format": "css/variables" }] },
    "js":   { "transformGroup": "js",   "buildPath": "build/js/",
              "files": [{ "destination": "tokens.js", "format": "javascript/es6" }] },
    "tailwind": { "transformGroup": "js", "buildPath": "build/",
                  "files": [{ "destination": "tailwind.tokens.js",
                              "format": "javascript/module-flat" }] }
  }
}
```

### Tailwind v4 — CSS-first token consumption

```css
@import "tailwindcss";
@import "./tokens/_variables.css";

@theme {
  --color-action-primary: var(--color-action-primary);
  --font-display: var(--font-display);
  --spacing-section: var(--space-9);
}
```

Tailwind v4 reads CSS variables directly — no JS config needed for most cases.

## Code Connect (Figma ↔ React)

Connect a Figma component to a React component so designers see the actual prop API in Dev Mode.

```bash
npm install -D @figma/code-connect
npx @figma/code-connect figma connect publish
```

`Button.figma.tsx` (lives next to `Button.jsx`):
```jsx
import figma from "@figma/code-connect"
import { Button } from "./Button"

figma.connect(Button, "<FIGMA_NODE_URL>", {
  props: {
    variant: figma.enum("Variant", {
      Primary: "primary",
      Ghost: "ghost",
    }),
    label: figma.string("Label"),
    icon: figma.boolean("Has Icon", { true: figma.instance("Icon") }),
  },
  example: ({ variant, label, icon }) => (
    <Button variant={variant} icon={icon}>{label}</Button>
  ),
})
```

In Figma Dev Mode, devs now see the JSX snippet matching the selected variant — no guessing.

## Component API rules

- **One way to do a thing** — `variant` prop, not 12 separate boolean props
- **Restrict prop types** — `variant: 'primary' | 'ghost' | 'danger'`, no `className` override (that's an escape hatch, not the API)
- **Composition over configuration** — `<Card><CardTitle/><CardBody/></Card>` not `<Card title="..." body="..."/>`
- **Sensible defaults** — most uses should not specify any prop
- **`asChild` pattern** (Radix-style) — let consumers swap the root element while keeping behavior

```jsx
function Button({ asChild, variant = 'primary', ...props }) {
  const Comp = asChild ? Slot : 'button'
  return <Comp className={cn(buttonStyles({ variant }))} {...props} />
}
```

## Motion as a system, not per-component

```js
// motion/presets.js
export const motion = {
  fadeIn:    { initial: { opacity: 0 }, animate: { opacity: 1 },
               transition: { duration: 0.4, ease: [0.16, 1, 0.3, 1] } },
  slideUp:   { initial: { opacity: 0, y: 16 }, animate: { opacity: 1, y: 0 },
               transition: { duration: 0.4, ease: [0.16, 1, 0.3, 1] } },
  pop:       { initial: { scale: 0.95, opacity: 0 }, animate: { scale: 1, opacity: 1 },
               transition: { type: 'spring', damping: 18, stiffness: 220 } },
}

// Component usage
<motion.div {...motion.slideUp}>...</motion.div>
```

This way "the design system has motion" rather than "each component invents its own".

## Documentation = Storybook + MDX, not Notion

```jsx
// Button.stories.jsx
export default { title: 'Components/Button', component: Button }

export const Primary = { args: { variant: 'primary', children: 'Get started' } }
export const Ghost   = { args: { variant: 'ghost',   children: 'Cancel' } }
export const AllVariants = () => (
  <div className="flex gap-3">
    {['primary','ghost','danger'].map(v => <Button key={v} variant={v}>{v}</Button>)}
  </div>
)
```

## Adoption (the hard part)

1. Build for the highest-pain component first (Button → Input → Card, in that order)
2. Migrate one team's product first; expand from working example
3. Track adoption: lint rule that flags raw color hex / arbitrary spacing values
4. Deprecate, don't delete — keep old API working with a console warning for one release cycle

## Anti-patterns

- Tokens shipped as JSON only, no CSS variables → consumers re-export anyway
- Designers and devs maintain different palette docs → drift within a sprint
- Component library that mirrors Tailwind utility names → adds no value
- `className` prop on every component → escape hatch becomes the default
- Versioning tokens with the components → breaks consumers on every refactor; version separately
- Custom-rolled token system when Style Dictionary or Tokens Studio exists
- "Storybook is the spec" without code-side enforcement
