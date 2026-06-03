---
name: Vibrant Fintech Dark
colors:
  surface: '#131318'
  surface-dim: '#131318'
  surface-bright: '#39393e'
  surface-container-lowest: '#0e0e13'
  surface-container-low: '#1b1b20'
  surface-container: '#1f1f24'
  surface-container-high: '#2a292f'
  surface-container-highest: '#35343a'
  on-surface: '#e4e1e9'
  on-surface-variant: '#cac3d8'
  inverse-surface: '#e4e1e9'
  inverse-on-surface: '#303035'
  outline: '#948ea1'
  outline-variant: '#494455'
  surface-tint: '#ccbdff'
  primary: '#ccbdff'
  on-primary: '#350097'
  primary-container: '#7f56ff'
  on-primary-container: '#060022'
  inverse-primary: '#6638e5'
  secondary: '#4fdf9b'
  on-secondary: '#003821'
  secondary-container: '#00b475'
  on-secondary-container: '#003e25'
  tertiary: '#a2c9ff'
  on-tertiary: '#00315b'
  tertiary-container: '#0079d2'
  on-tertiary-container: '#ffffff'
  error: '#ffb4ab'
  on-error: '#690005'
  error-container: '#93000a'
  on-error-container: '#ffdad6'
  primary-fixed: '#e7deff'
  primary-fixed-dim: '#ccbdff'
  on-primary-fixed: '#1f0060'
  on-primary-fixed-variant: '#4d0acd'
  secondary-fixed: '#6ffcb5'
  secondary-fixed-dim: '#4fdf9b'
  on-secondary-fixed: '#002112'
  on-secondary-fixed-variant: '#005232'
  tertiary-fixed: '#d3e4ff'
  tertiary-fixed-dim: '#a2c9ff'
  on-tertiary-fixed: '#001c38'
  on-tertiary-fixed-variant: '#004881'
  background: '#131318'
  on-background: '#e4e1e9'
  surface-variant: '#35343a'
typography:
  display-lg:
    fontFamily: Inter
    fontSize: 32px
    fontWeight: '700'
    lineHeight: 40px
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Inter
    fontSize: 24px
    fontWeight: '600'
    lineHeight: 32px
    letterSpacing: -0.01em
  headline-md:
    fontFamily: Inter
    fontSize: 20px
    fontWeight: '600'
    lineHeight: 28px
  body-lg:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  body-md:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
  label-lg:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '600'
    lineHeight: 20px
  label-md:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '500'
    lineHeight: 16px
  headline-lg-mobile:
    fontFamily: Inter
    fontSize: 22px
    fontWeight: '600'
    lineHeight: 28px
rounded:
  sm: 0.5rem
  DEFAULT: 1rem
  md: 1.5rem
  lg: 2rem
  xl: 3rem
  full: 9999px
spacing:
  margin-page: 24px
  gutter-grid: 16px
  stack-sm: 8px
  stack-md: 16px
  stack-lg: 24px
  stack-xl: 40px
---

## Brand & Style

This design system is engineered for a modern personal finance experience that balances high-energy "vibrancy" with "trustworthy clarity," optimized for a premium **Dark Mode** environment. The aesthetic is a sophisticated blend of **Minimalism** and **Glassmorphism**, designed to make financial management feel effortless and optimistic rather than clinical or stressful.

The visual narrative focuses on:
- **Atmospheric Depth:** Using deep indigo and charcoal bases paired with translucent layers to create a sense of infinite digital space.
- **Action-Oriented Accents:** A singular, high-chroma violet is used to guide the eye toward primary actions and critical financial milestones.
- **Approachability:** Utilizing generous whitespace and high-radius rounding to soften the complexity of financial data.

The system is designed to evoke a sense of "financial clarity"—where users feel in control of their data through an interface that feels as light and responsive as physical glass.

## Colors

The color system centers around a **Vibrant Purple (#7F56FF)**. This is used exclusively for primary buttons, active navigation states, and key branding moments. 

### Palette Strategy
- **Dark Mode Foundation:** The primary background uses a deep neutral (#121217) to provide a rich, premium atmosphere.
- **Functional Accents:** Green (#27C281) and Blue (#47A1FF) are reserved for data visualization and status indicators (Success/Growth vs. Stability).
- **Surface Gradients:** In Dark mode, the system utilizes a deep, atmospheric indigo glow to ground the interface.
- **Glassmorphism:** `surface-container-high` should be applied with a `backdrop-filter: blur(20px)` to create the "frosted" effect seen in the reference headers and cards.
- **Semantic Contrast:** Ensure text on primary purple is always high-contrast white.

## Typography

This design system uses **Inter** for its neutral, highly legible character. The typographic scale is designed for high-density financial data in dark environments.

- **Weight Usage:** Use `700` (Bold) only for large currency displays. Use `600` (Semi-Bold) for headlines and labels to maintain a clean, modern hierarchy.
- **Numeric Data:** For currency values, always use `letter-spacing: -0.02em` to keep large numbers compact and readable.
- **Dark Mode Legibility:** Utilize the `on-surface-variant` color token for body text to ensure headlines in `on-surface` stand out without causing eye fatigue.

## Layout & Spacing

The layout follows a **Fluid Grid** model with high internal margins.

- **Mobile:** 4-column grid with 24px side margins. 
- **Card Padding:** All primary containers (Cards/Lists) should utilize a minimum of 20px internal padding to maintain an airy, premium feel.
- **Content Stacking:** Use a 24px (`stack-lg`) vertical rhythm between major sections (e.g., Transactions vs. Analytics charts).
- **Navigation:** The bottom navigation bar is anchored and uses a high-blur glassmorphism background to allow content to scroll underneath it visually.

## Elevation & Depth

Hierarchy is established through **Tonal Layers** and **Backdrop Blurs** rather than heavy shadows.

- **Level 1 (Base):** The `surface` dark background.
- **Level 2 (Cards):** Elevated via `surface-container` with a very subtle, tinted outer glow or 1px stroke.
- **Level 3 (Overlays):** Modals and high-priority cards use `surface-container-high` with a 20px backdrop blur.
- **Shadow Character:** Shadows in dark mode are extremely subtle, tinted with deep navy at low (4-8%) opacity to simulate depth without looking muddy.

## Shapes

The design system employs a **Pill-shaped** shape language to create an exceptionally soft, modern, and friendly user experience.

- **Containers:** Large cards and background surfaces use `rounded-xl` (3rem / 48px) to create the signature high-radius look of the interface.
- **Buttons:** Primary and secondary buttons use `rounded-lg` (2rem / 32px) or fully pill-shaped (100px) profiles for a modern touch.
- **Inputs:** Form fields should match the `rounded-lg` (32px) standard for consistency with buttons.
- **Icons:** Icons should be contained within circular or rounded-square containers with high-radius profiles.

## Components

### Buttons
- **Primary:** Background `primary`, text `on-primary`. High 32px+ rounding.
- **Secondary:** Background `surface-container`, border `outline`, text `on-surface`.
- **Floating Action Button (FAB):** Centralized in the bottom nav, using the primary violet background with a white '+' icon.

### Cards & Containers
- Cards are the primary unit of information. They must have a 48px (rounded-xl) border radius. In dark mode, a thin 1px border using the `outline-variant` token is used to ensure container definition against the dark background.

### Input Fields
- Background `surface-container`, height 56px, with 20px internal padding. Labels are positioned above the field using `label-md`.

### Chips & Badges
- Used for categories (e.g., "Food", "Bills"). Background uses a 15% opacity version of the accent colors (Success Green, Primary Purple) with a text color of 100% opacity of that same color.

### Progress & Charts
- **Donut Charts:** 12px stroke width. Background stroke uses `outline-variant` token. 
- **Bar Charts:** 12px radius on top corners of bars only to match the high-radius theme.