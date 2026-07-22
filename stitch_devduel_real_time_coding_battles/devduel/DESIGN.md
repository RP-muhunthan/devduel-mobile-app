---
name: DevDuel
colors:
  surface: '#121414'
  surface-dim: '#121414'
  surface-bright: '#38393a'
  surface-container-lowest: '#0d0e0f'
  surface-container-low: '#1a1c1c'
  surface-container: '#1e2020'
  surface-container-high: '#292a2a'
  surface-container-highest: '#343535'
  on-surface: '#e3e2e2'
  on-surface-variant: '#d0c6ab'
  inverse-surface: '#e3e2e2'
  inverse-on-surface: '#2f3131'
  outline: '#999077'
  outline-variant: '#4d4732'
  surface-tint: '#e9c400'
  primary: '#fff6df'
  on-primary: '#3a3000'
  primary-container: '#ffd700'
  on-primary-container: '#705e00'
  inverse-primary: '#705d00'
  secondary: '#f7bd48'
  on-secondary: '#412d00'
  secondary-container: '#ba880f'
  on-secondary-container: '#392700'
  tertiary: '#fff6d2'
  on-tertiary: '#373100'
  tertiary-container: '#f1db40'
  on-tertiary-container: '#6b5f00'
  error: '#ffb4ab'
  on-error: '#690005'
  error-container: '#93000a'
  on-error-container: '#ffdad6'
  primary-fixed: '#ffe16d'
  primary-fixed-dim: '#e9c400'
  on-primary-fixed: '#221b00'
  on-primary-fixed-variant: '#544600'
  secondary-fixed: '#ffdea6'
  secondary-fixed-dim: '#f7bd48'
  on-secondary-fixed: '#271900'
  on-secondary-fixed-variant: '#5d4200'
  tertiary-fixed: '#fae448'
  tertiary-fixed-dim: '#dcc82c'
  on-tertiary-fixed: '#201c00'
  on-tertiary-fixed-variant: '#504700'
  background: '#121414'
  on-background: '#e3e2e2'
  surface-variant: '#343535'
typography:
  headline-lg:
    fontFamily: Roboto
    fontSize: 32px
    fontWeight: '700'
    lineHeight: 40px
    letterSpacing: -0.02em
  headline-md:
    fontFamily: Roboto
    fontSize: 24px
    fontWeight: '600'
    lineHeight: 32px
    letterSpacing: -0.01em
  body-lg:
    fontFamily: Roboto
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  body-md:
    fontFamily: Roboto
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
  code-block:
    fontFamily: JetBrains Mono
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 22px
  label-caps:
    fontFamily: JetBrains Mono
    fontSize: 12px
    fontWeight: '700'
    lineHeight: 16px
    letterSpacing: 0.1em
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  unit: 8px
  container-margin: 24px
  gutter: 16px
  component-gap: 12px
  section-gap: 32px
---

## Brand & Style

The design system is engineered to evoke the high-stakes environment of competitive programming. It targets an audience of elite developers and aspiring engineers who value precision, speed, and technical mastery. The brand personality is aggressive yet refined—a "hacker elite" aesthetic that combines the intensity of an e-sports arena with the professional rigor of a high-end IDE.

The visual style follows a **High-Contrast Minimalism** approach. By using a pure black canvas, the design system eliminates distractions, allowing the gold accents to signal importance, achievement, and premium status. The interface feels energetic through the use of sharp typography and subtle, high-tech details that suggest a live, reactive environment.

## Colors

The palette is rooted in a deep, "absolute" dark mode to maximize OLED efficiency and visual focus. 

- **Primary & Accents:** Gold is the sole indicator of brand identity and high-priority actions. Use the primary gold for main calls to action and "winner" states. Dark gold is reserved for hover/pressed states or secondary visual interest, while light gold provides high-visibility highlights or "glow" effects.
- **Neutrals:** The background layers move from pure black (#0A0A0A) to slightly lighter surfaces to indicate hierarchy. Text uses pure white for readability and muted gray to diminish the importance of metadata.
- **Feedback:** Success and Error colors are saturated to ensure they pop against the dark background, maintaining the "High-Tech" energy.

## Typography

This design system utilizes a dual-font strategy to balance UI clarity with technical authenticity.

- **UI Text (Roboto):** Used for all navigation, headers, and standard interface copy. Bold weights are preferred for headings to instill a sense of urgency and power.
- **Technical Text (JetBrains Mono):** Used for code blocks, terminal outputs, and small "data labels." This reinforces the developer-centric nature of the product. 
- **Hierarchy:** Use uppercase labels with increased letter spacing for category headers and status indicators to create a "dashboard" look common in high-tech telemetry.

## Layout & Spacing

The layout philosophy follows a **Fluid Grid** model with a consistent 8px rhythmic unit. 

- **Margins:** Screens should maintain a 24px outer margin to ensure content doesn't feel cramped against the bezel, maintaining a premium "airy" feel despite the dark palette.
- **Gutters:** A 16px gutter is standard between card elements in a list or grid.
- **Alignment:** Content should be strictly left-aligned for readability, especially in coding challenges, while primary action buttons are often full-width to provide a large, energetic hit area on mobile devices.

## Elevation & Depth

In the absence of heavy shadows, this design system uses **Tonal Layers** and **Low-Contrast Outlines** to define depth.

- **Base Layer:** The primary background (#0A0A0A) represents the furthest depth.
- **Surface Layer:** Cards and containers use #111111. To further define these shapes, use a 1px solid border of #2A2A2A.
- **Interactive Layer:** When an element is focused or elevated, it shifts to #1A1A1A. 
- **Accent Glow:** For premium elements (like a "Winner" card), use a subtle, outer gold glow (0px 4px 20px) with 15% opacity to simulate light emission without cluttering the UI with heavy shadows.

## Shapes

The shape language is modern and structured. 

- **Cards:** Use a 12px corner radius. This provides a sophisticated, "hardware-like" feel that isn't overly aggressive but remains distinct from the more utilitarian components.
- **Inputs & Buttons:** Use a smaller 8px radius. This sharper cornering suggests precision and fits the "high-tech" narrative.
- **Status Indicators:** Use 100% (pill) rounding for chips and status tags (e.g., "Live", "Ranked") to distinguish them from structural layout components.

## Components

The components for the design system are optimized for quick interaction and high-intensity feedback.

- **Buttons:** 48px height. Primary buttons use a solid Gold background with black text. Secondary buttons are outlined with a 1px Gold border. All buttons should have a "pressed" state that shifts to Dark Gold.
- **Inputs:** Outlined with #2A2A2A. On focus, the border transitions to Gold. Labels should be small and positioned above the input field using JetBrains Mono.
- **Cards:** Background #111111 with a 12px radius. Use for "Battle" previews, problem statements, and leaderboard entries.
- **Bottom Navigation:** A solid #0A0A0A bar with a 1px top border (#2A2A2A). Active icons should use the Primary Gold, while inactive icons use the Muted Gray.
- **Battle Chips:** Small pill-shaped tags used for difficulty (Easy/Medium/Hard) or language tags (Python/C++). 
- **Code Editor:** The core component. Needs syntax highlighting that utilizes the Primary, Success, and Error colors against a slightly darker surface than the standard card to differentiate the "work area."