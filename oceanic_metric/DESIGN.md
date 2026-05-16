# Design System Specification: The Aquatic Lens

## 1. Overview & Creative North Star
The visual identity of this design system is anchored by a Creative North Star we define as **"The Aquatic Lens."** 

In marine biology, clarity is often obstructed by the medium of water. This system acts as a corrective lens—bringing scientific precision, data-driven insights, and absolute structural clarity to the complex ecosystem of coral reef health. Moving beyond generic "dashboard" layouts, the interface utilizes **intentional asymmetry** and **tonal depth** to mimic the layered experience of the ocean. By using overlapping surfaces and sophisticated editorial typography, we transform a scientific tool into a high-end digital experience that feels both authoritative and organic.

---

## 2. Colors & Surface Philosophy
The palette is a sophisticated range of teals and deep sea blues, punctuated by high-contrast functional colors for coral status reporting.

### Functional Status Tokens
*   **Healthy:** `secondary` (#006a66) — Deep teal-green representing vitality.
*   **Bleached:** Custom Orange (#F59E0B) — High visibility for critical warning states.
*   **Dead/At Risk:** `error` (#ba1a1a) — Clear, urgent signal of biological failure.

### The "No-Line" Rule
To maintain a premium, editorial feel, **1px solid borders are prohibited for sectioning.** Layout boundaries must be defined exclusively through background color shifts. For example, a global navigation sidebar should use `surface-container-low` sitting against a `surface` background. This creates a "soft" edge that feels integrated rather than boxed-in.

### Surface Hierarchy & Nesting
Treat the UI as a series of physical layers. Use the `surface-container` tiers to create depth:
*   **Base Layer:** `surface` (#f6fafe)
*   **Section Layer:** `surface-container-low` (#f0f4f8)
*   **Interactive Cards:** `surface-container-lowest` (#ffffff) 

### The "Glass & Gradient" Rule
For floating elements, such as AI insight panels or image overlays, use **Glassmorphism**. Apply a semi-transparent `surface-variant` with a `backdrop-filter: blur(20px)`. Main Action buttons or "Healthy State" hero headers should utilize a subtle linear gradient transitioning from `primary` (#006067) to `primary-container` (#007b83) at a 135-degree angle to provide visual "soul" and polish.

---

## 3. Typography
The typography strategy pairs the technical precision of **Inter** with the editorial character of **Manrope**.

*   **Display & Headlines (Manrope):** Used for large data points and page titles. Manrope’s modern geometric construction provides an "authoritative scientific journal" feel.
    *   *Display-LG:* 3.5rem (For critical percentage results).
    *   *Headline-MD:* 1.75rem (For section headers).
*   **Body & Labels (Inter):** Inter is the workhorse for data density. Its high x-height ensures maximum readability for complex marine metrics.
    *   *Body-MD:* 0.875rem (Standard report text).
    *   *Label-SM:* 0.6875rem (Micro-data and timestamps).

---

## 4. Elevation & Depth
Depth in this system is achieved through **Tonal Layering** rather than traditional structural lines.

*   **The Layering Principle:** Place a `surface-container-lowest` card (Pure White) on a `surface-container-low` background. The subtle 2-3% contrast shift provides enough "lift" to signify a clickable area without visual clutter.
*   **Ambient Shadows:** For high-level modals or floating tooltips, use extra-diffused shadows.
    *   *Shadow Specs:* `box-shadow: 0 20px 40px rgba(23, 28, 31, 0.06);` (Using a tinted version of `on-surface`).
*   **The Ghost Border:** If a boundary is required for accessibility, use `outline-variant` at **15% opacity**. Never use 100% opaque outlines.
*   **Glassmorphism Depth:** When using glass containers, ensure a 1px inner "shine" (highlight) on the top edge using a 20% white stroke to mimic the surface of water catching light.

---

## 5. Components

### Cards & Data Containers
*   **Style:** Use `xl` (1.5rem) rounded corners for main containers and `lg` (1rem) for nested items.
*   **Constraint:** **Forbid divider lines.** Separate content using vertical white space (`spacing-6` or `spacing-8`) or subtle background shifts.
*   **Layout:** Embrace "Scientific Asymmetry." Allow a chart to take up 65% of a card while the data labels take 35%, creating a dynamic, modern scan-path.

### Buttons & Interaction
*   **Primary:** `primary` background with `on-primary` text. Use `full` (pill) rounding for a modern, friendly touch.
*   **Secondary:** `surface-container-highest` background with `primary` text. No border.
*   **Tertiary/Ghost:** No background. Use `primary` text with a subtle `spacing-1` bottom margin on hover to indicate interactivity.

### Status Chips
*   **Healthy State:** `on-secondary-container` text on `secondary-container` background.
*   **Bleached State:** Dark orange text on a 10% opacity orange background.
*   **Dead State:** `on-error-container` text on `error-container`.

### Input Fields & Toggles
*   **Inputs:** `surface-container-low` background with a `ghost-border` on focus. No heavy outlines.
*   **Toggles:** High-contrast `primary` for "On" states. The "Off" state should blend into the `surface-container-high`.

### Marine Specific: The "Health Spectrum" Bar
A bespoke data viz component. A horizontal bar using the spacing scale (`height: 2`) with a multi-stop gradient (Red -> Yellow -> Green) to visualize the immediate transition of coral health in a specific quadrant.

---

## 6. Do's and Don'ts

### Do:
*   **Do** use extreme white space (`spacing-16` or `spacing-24`) to separate major scientific modules.
*   **Do** use `display-lg` for the primary "Coral Health Score" to create a clear focal point.
*   **Do** use semi-transparent overlays for "AI Image Analysis" to keep the user grounded in the source photography.

### Don't:
*   **Don't** use black (#000000) for text. Always use `on-surface` (#171c1f) for a softer, more professional contrast.
*   **Don't** use standard "Drop Shadows." If an element doesn't feel elevated enough, increase the background contrast between layers first.
*   **Don't** use "Alert" icons for bleached coral unless it requires immediate human intervention; let the color and typography hierarchy do the heavy lifting.
*   **Don't** use rigid, boxed-in grids. Allow some elements to break the vertical rhythm to create a sophisticated, editorial flow.