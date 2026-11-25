# iOS-Inspired Design System

Reusable interface guidance for building clear, calm, and accessible product experiences with an iOS-inspired visual language. Use Apple’s Human Interface Guidelines (HIG) as a design reference; this document is an independent implementation guide and is not an official Apple specification or endorsement.

## Use this file

Before creating or modifying any page, screen, or feature, read this file and follow its tokens and component rules. Prefer existing project components and conventions where they already implement these principles. Keep new UI consistent across light and dark appearances, and update this document when a deliberate system-wide decision changes.

## Design principles

- Prioritize content, legibility, and the user’s current task.
- Use a restrained visual hierarchy: clear titles, quiet supporting text, and one obvious primary action per context.
- Favor familiar platform patterns, direct manipulation, and predictable navigation.
- Use rounded geometry and subtle depth sparingly. Avoid decorative gradients, heavy borders, and excessive blur.
- Respect system settings, safe areas, Dynamic Type, reduced motion, and input method.

## Layout and spacing

- Use a 4 pt base unit. Standard spacing steps: `4, 8, 12, 16, 20, 24, 32, 40, 48` pt. Use these consistently; use 16 pt as the default content inset on compact screens and 20–24 pt on wider layouts.
- Align related content to a shared leading edge. Group related controls and separate unrelated sections with whitespace before adding dividers.
- Keep text measure comfortable: aim for about 45–75 characters per line. Constrain content width on large screens rather than stretching paragraphs edge to edge.
- Use responsive layouts: compact screens stack content; larger screens may use columns or sidebars when they improve scanning. Do not rely on fixed screen dimensions.
- Keep interactive targets at least 44 × 44 pt (or an equivalent accessible hit area), even when the visible icon is smaller.
- Account for safe areas, keyboard insets, and scrollable content. Do not place essential controls beneath system chrome.

## Typography

- Prefer the platform’s San Francisco system font. Use semantic text styles and allow text to scale with accessibility settings.
- CSS stack: `-apple-system, BlinkMacSystemFont, "SF Pro Text", "SF Pro Display", "Helvetica Neue", sans-serif`.
- Suggested roles (web CSS values are starting points; use native semantic styles when available):

| Role | Typical size / weight | Use |
| --- | --- | --- |
| Large title | 34 pt / 700 | Screen-level title, sparingly |
| Title 1 | 28 pt / 700 | Primary page heading |
| Title 2 | 22 pt / 700 | Major section heading |
| Title 3 | 20 pt / 600 | Subsection heading |
| Headline | 17 pt / 600 | Emphasized row or card title |
| Body | 17 pt / 400 | Primary reading and form content |
| Callout | 16 pt / 400 | Supporting prominent content |
| Subheadline | 15 pt / 400 | Secondary content |
| Footnote | 13 pt / 400 | Helpful metadata, not essential instructions |
| Caption | 12 pt / 400 | Tertiary labels, used sparingly |

- Use sentence case, concise labels, and natural line height (roughly 1.2–1.45× font size). Avoid long all-caps labels and overly tight tracking.
- Do not communicate meaning through weight, size, or color alone. Support Dynamic Type or browser text zoom without clipping or hiding actions.

## Color tokens

Use semantic tokens rather than hard-coded colors in components. The values below are a neutral starting palette; tune them for the product and verify contrast in both appearances.

| Token | Light | Dark | Purpose |
| --- | --- | --- | --- |
| `--color-background` | `#F2F2F7` | `#000000` | App/canvas background |
| `--color-surface` | `#FFFFFF` | `#1C1C1E` | Cards, sheets, grouped content |
| `--color-surface-secondary` | `#F2F2F7` | `#2C2C2E` | Nested or secondary surfaces |
| `--color-text-primary` | `#1C1C1E` | `#F5F5F7` | Main text and icons |
| `--color-text-secondary` | `#636366` | `#AEAEB2` | Supporting text |
| `--color-text-tertiary` | `#8E8E93` | `#8E8E93` | Nonessential metadata |
| `--color-separator` | `#3C3C43` at 12% | `#545458` at 60% | Dividers and subtle borders |
| `--color-accent` | `#007AFF` | `#0A84FF` | Links, selected states, primary actions |
| `--color-success` | `#248A3D` | `#30D158` | Success and positive status |
| `--color-warning` | `#9A6700` | `#FFD60A` | Caution; pair with an icon or text |
| `--color-danger` | `#D70015` | `#FF453A` | Destructive actions and errors |

Define tokens centrally (for example, CSS custom properties or native color assets). Use system-aware colors where available. Check text and control contrast against WCAG 2.2 AA as a practical minimum; never rely on color alone to indicate state.

## Buttons and actions

- Provide a clear hierarchy: one prominent filled primary action, secondary actions as bordered or tinted controls, and tertiary actions as text buttons.
- Use a minimum 44 pt control height, 16–20 pt horizontal padding, and a corner radius around 12 pt. Keep labels concise and verb-led.
- Primary buttons use the accent fill with a verified contrasting label. Disabled states must remain readable and visibly inactive; do not indicate disabled state through opacity alone.
- Destructive actions use the danger token and clear wording. Ask for confirmation only when the action is consequential or difficult to reverse.
- Include pressed, focused, disabled, loading, and (where relevant) selected states. Show progress for actions that take noticeable time and prevent accidental duplicate submission.
- Use icon-only buttons only for universally recognizable actions; provide an accessible name and a sufficiently large hit area.

## Cards and grouped content

- Use cards to communicate a meaningful group, not as a wrapper around every element. Prefer grouped lists and open layouts when they scan better.
- Use a surface fill, 16 pt internal padding, and a 16–20 pt radius. Keep card elevation low; use a subtle separator or tonal contrast before adding a shadow.
- Make interaction affordances clear. If a whole card is actionable, expose it as one coherent control and avoid nested competing actions.
- Keep related content aligned and spacing consistent. Do not put essential text over busy imagery without a stable contrast treatment.

## Forms and feedback

- Put persistent labels above or beside fields; placeholders are examples, not labels. Associate help text and errors programmatically with their field.
- Use at least 44 pt control height, a 12 pt radius, and clear focus styling. Match the field surface to its surrounding context.
- Choose the correct keyboard and input type. Preserve entered values when validation fails and explain how to fix each error in plain language.
- Validate at an appropriate time (often on submit or after a field is completed), not on every keystroke in a way that interrupts entry.
- Use switches for immediate on/off settings, checkboxes for independent selections, and radio controls for one choice among a small set. Include visible labels and selected states.
- Provide concise success, error, and empty-state feedback. Pair color with text and, where useful, an icon.

## Navigation

- Use a clear hierarchy with a page title and predictable back behavior. Keep navigation labels short and stable.
- Use tab navigation for a small set of top-level destinations of comparable importance; keep it persistent and avoid changing its order or meaning by screen.
- Use navigation stacks for drill-down tasks, sheets for focused temporary tasks, and alerts only for brief decisions or critical information.
- Preserve the user’s place and input when moving between screens. Provide a visible title and current/selected destination, with accessibility state exposed to assistive technology.
- On wide layouts, use a sidebar or split view when it improves orientation. Avoid hiding core destinations behind gestures alone.

## Corner radii, borders, shadows, and materials

Use a small, consistent radius scale: `8 pt` for compact controls, `12 pt` for buttons and fields, `16 pt` for cards, and `20–24 pt` for sheets or large containers. Pills are reserved for compact tags or unmistakable capsule buttons. Avoid rounding every nested element.

Prefer tonal surface differences and fine separators over outlines around every component. Use soft, low-opacity shadows only to clarify elevation (such as a floating control or sheet); keep them subtle and avoid multiple stacked shadow layers. Use blur or translucent material only when content must remain visible beneath a system-like overlay. Maintain readable contrast behind all material effects and provide an opaque fallback when transparency is reduced or unsupported.

## Icons and imagery

- Use minimalist, crisp vector icons with the restrained visual character of SF Symbols. Lucide- or Phosphor-compatible icons are suitable when their stroke style is consistent.
- Prefer a consistent 1.5–2 pt stroke, rounded joins/caps, and a small set of standard sizes (16, 20, 24 pt). Use one icon family per interface and avoid mixing filled and outline styles without a clear state distinction.
- Use familiar symbols for common actions. Pair unfamiliar or ambiguous icons with a text label. Decorative icons should not be exposed as meaningful to assistive technology.
- In native Apple-platform apps, use SF Symbols where appropriate and verify availability for the supported OS versions. In web or cross-platform apps, use a consistent vector icon set; do not imitate proprietary assets or assume identical rendering.
- Keep icons optically aligned with adjacent text and use semantic colors. Do not use emoji as interface icons.

## Dark mode and appearance

- Support both light and dark appearance using semantic tokens. Re-check contrast, separators, imagery, shadows, selected states, and disabled controls in each mode.
- In dark appearance, use layered dark surfaces rather than applying a simple invert. Pure black can be appropriate for OLED-oriented full-screen canvases; use raised charcoal surfaces for grouped content.
- Follow system appearance by default and preserve the user’s explicit appearance choice if the product offers one. Avoid encoding meaning only in a particular light-mode hue.

## Accessibility and motion

- Target WCAG 2.2 AA contrast: 4.5:1 for normal text and 3:1 for large text and meaningful UI graphics. Verify actual rendered colors, including opacity and material effects.
- Support VoiceOver and other screen readers with meaningful names, roles, values, logical reading order, and clear focus movement. Hide purely decorative elements from accessibility APIs.
- Maintain visible keyboard focus and full keyboard operation for interactive controls. Do not trap focus. Support switch control and other assistive input where the platform provides it.
- Respect text scaling, bold text, reduced motion, increased contrast, and reduced transparency settings. Avoid fixed-height text containers that clip translated or enlarged text.
- Use motion to explain state changes, not as decoration. Keep transitions brief and nonessential; provide reduced-motion alternatives and avoid flashing or disorienting movement.
- Make errors actionable and announce dynamic updates accessibly. Do not rely on sound, position, or color alone.

## Implementation checklist

Before considering a page or feature complete, confirm that:

- It follows these tokens and uses shared project components where available.
- Layout responds to compact and wide screens, safe areas, keyboard, and longer content.
- Text scales; controls have accessible names, focus states, and at least 44 pt hit areas.
- Light and dark appearances remain legible and semantically consistent.
- Buttons, forms, navigation, empty states, loading, and error feedback have clear behavior.
- Icons come from one consistent vector family and remain understandable with labels where needed.
- Motion and transparency respect user preferences.
