# Design / UI-UX Guidelines

## Core principles
- Clarity over cleverness: the user should never have to think about the interface.
- Visual hierarchy: guide the eye with size, weight, colour, and spacing — not decoration.
- Consistency: reuse patterns, spacing, and components. Inconsistency signals unreliability.
- Restraint: every visual element needs a reason. Remove before adding.

## Spacing & layout
- Use an 8px base grid. All spacing values should be multiples of 4 or 8.
- Generous whitespace around text; tight whitespace signals relationship.
- Content max-width: ~680px for reading, ~1200px for app layouts.
- Align elements to an underlying grid — eyeballing is not alignment.

## Typography
- 2–3 type sizes max per view. Establish a clear scale (e.g. 12/14/16/20/28/36).
- Line-height: 1.5 for body, 1.2 for headings.
- Line-length: 55–75 characters for readable prose.
- Avoid all-caps except for very short labels; prefer font-weight for emphasis.

## Colour
- Establish a palette: primary, neutral (5+ shades), semantic (success, warning, error, info).
- WCAG AA minimum contrast (4.5:1 text, 3:1 large text and UI components).
- Don't use colour as the only differentiator — pair with shape, label, or pattern.
- Dark mode: invert lightness, not hue; keep saturation slightly lower on dark backgrounds.

## Motion & animation
- Motion should serve a purpose: confirm an action, show a transition, direct attention.
- Duration: 100–200ms for micro-interactions, 250–400ms for larger transitions.
- Easing: ease-out for elements entering, ease-in for leaving, ease-in-out for state changes.
- Respect `prefers-reduced-motion` — provide a no-motion fallback.

## Components
- Design for states: default, hover, focus, active, disabled, loading, error, empty.
- Every interactive element needs a visible focus style.
- Touch targets: 44×44px minimum on mobile.
- Forms: label above input, inline validation on blur, clear error messages that say how to fix the problem.

## Interaction design
- Feedback: every action should have an immediate visual response (< 100ms).
- Loading states: skeleton screens over spinners for content; progress indicators for long ops.
- Error states: tell the user what happened and what to do — never "an error occurred".
- Empty states: explain why it's empty and offer the first action to fill it.

## Handoff notes
- Specify exact values: px, %, hex, opacity — no "about this size" or "roughly this colour".
- Document all component states in designs.
- Flag any interaction that requires animation or transition detail.
