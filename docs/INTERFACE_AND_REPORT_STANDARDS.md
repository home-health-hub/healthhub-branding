# Interface and report standards

These standards apply to Health Hub pages that present Hub and daemon functions, and to daemon-generated PDF reports. They define presentation, not clinical interpretation or data ownership.

## Presentation and service boundary

Health Hub owns all interactive browser presentation, including pages for daemon-backed functions. Daemons do not provide separate branded browser interfaces. They remain independently usable, headless services: without Health Hub they still synchronize and retain their data and generate authoritative PDFs through their APIs. A daemon must not require the Hub UI to perform its core synchronization, data, or report responsibilities.

A Hub-rendered page for an individual daemon may display that daemon's approved application or navigation image as a visual page identifier. Keep the function-led page title visible, follow the alternative-text rules below, and retain the organization avatar as the single site-wide favicon. Daemon identification images do not appear in doctor-facing PDFs.

## Typography

Use **Atkinson Hyperlegible Next** for user-facing interfaces and reports when it can be bundled or embedded. Use this fallback stack when it is unavailable:

```css
font-family: "Atkinson Hyperlegible Next", "Atkinson Hyperlegible", system-ui, sans-serif;
```

- Use regular weight for body text and medium or bold weight for headings and labels.
- Use tabular numerals for measurements, dates, times, and chart axes.
- Keep body text at least 16 CSS pixels in browser interfaces and 10 points in PDFs.
- Do not use light font weights, condensed faces, or all-uppercase paragraphs.
- Keep technical identifiers in a monospace font only when they must be shown to the user.
- A daemon PDF generator may use the fallback stack without downloading a remote font. PDF generators must embed the selected font or use an installed, metrically stable fallback.

## Operational status semantics

Device accent colors identify a product or measurement family. They must not carry operational meaning. Status always combines a label with an icon or shape so that color is supplementary.

| Status | Meaning | Suggested color | Required label |
|---|---|---|---|
| Ready | Available and operating normally | Deep teal `#00616E` | Ready |
| Syncing | Transfer or import is active | Hub teal `#168E98` | Syncing |
| Attention | User action may be needed; data is not known to be lost | Warm gold `#A65D00` | Attention |
| Error | Operation failed or data could not be processed | Dark red `#B42318` | Error |
| Offline | Device or daemon is not currently reachable | Slate `#475467` | Offline |
| Unknown | Current state has not been established | Gray `#667085` | Unknown |

- Do not use red for normal high or low health measurements; operational errors and measurement interpretation are separate concepts.
- Do not use a product accent as the sole indication of success, warning, or failure.
- Display the last successful contact or synchronization time when stale state matters.
- Animate only an active transient state such as Syncing, respect reduced-motion settings, and retain a text label when animation is disabled.
- Error text states what failed and, when known, what the person can do next. It must not imply a diagnosis.

## User-facing names

Primary names describe the health function rather than a manufacturer or currently supported device. This keeps navigation stable when a daemon gains support for another brand or model.

| Technical project | Primary display name |
|---|---|
| Health Hub application | Health Hub |
| Scale daemon | Weight |
| Blood-pressure daemon | Blood Pressure |
| Glucose daemon | Blood Glucose |
| Pulse-oximetry daemon | Oxygen Saturation |
| Basal-temperature daemon | Basal Body Temperature |

- Use **Home Health Hub** for the overall project or organization and **Health Hub** for the application.
- Keep manufacturer, product, and model names as secondary device metadata for setup, device details, provenance, support, and troubleshooting.
- Do not put a manufacturer in a primary navigation label, page category, or generic report title.
- Use official capitalization when a manufacturer or model must be shown, such as `TRUE METRIX`, `O2Ring`, or `Easy@Home`.
- Use `daemon` only in technical administration, logs, developer documentation, and service management.
- Do not expose repository or service identifiers in ordinary user interfaces.
- Prefer measurement-led actions such as `Sync blood pressure` rather than implementation-led actions such as `Run daemon`.
- Use `reading` or `measurement` in person-facing text. Reserve `record` for storage and administration contexts.

## Hub tiles and input methods

Use one responsive tile system that supports mouse, touch, keyboard, and assistive technology concurrently. Layout may adapt to available space, but must not assume that a large screen uses only a mouse or that a tablet uses only touch.

- Use a responsive grid with tiles at least 220 CSS pixels wide and approximately 152 CSS pixels tall when space permits.
- Use 20 CSS pixels of internal padding, 12 CSS pixels between tile contents, and a 12 CSS pixel corner radius.
- Display navigation artwork in a 64 by 64 CSS pixel area with `object-fit: contain`; use a 48 CSS pixel area in compact single-column layouts.
- Do not crop, stretch, recolor, mask, or force approved artwork into another shape.
- Make the whole primary tile a single-click and single-tap target. Keep separate actions such as menus and downloads visually and spatially distinct.
- Keep interactive targets at least 48 by 48 CSS pixels with at least 8 CSS pixels between separate targets, except for ordinary inline text links.
- Do not require hover, double-click, right-click, precise dragging, or long-press.
- Use restrained hover feedback for a fine pointer and immediate pressed feedback for touch. Essential information and actions remain visible without hover.
- Use real links for navigation so browser back, forward, modifier-click, middle-click, and open-in-new-tab behavior work normally.
- Preserve selectable text unless selection would prevent a control from functioning.
- Show a visible three-CSS-pixel focus ring and keep focus unobscured.
- Use a two-column layout where practical on portrait tablets and a responsive grid on landscape tablets and touchscreen monitors. A phone uses a single-column list.

Default tiles use a white surface and neutral one-CSS-pixel border. A selected tile uses a two-CSS-pixel Hub-teal border and pale-aqua background. A disabled tile remains legible and states why it is unavailable. Error and offline states keep the normal product identity and add the approved text status rather than recoloring the entire tile.

Badges are reserved for actionable counts. Place them at the upper-right without covering artwork or text, display `99+` above 99, and provide an accessible label. Do not use a dot alone or use badges for Ready, Offline, or Syncing. Ordinary counts use deep teal; dark red is reserved for actual error counts.

## Accessibility and screen readers

The Health Hub interface targets [WCAG 2.2 Level AA](https://www.w3.org/TR/WCAG22/) and uses native semantic HTML before ARIA.

- Provide landmarks, a skip link, descriptive page titles, a clear heading hierarchy, and a logical DOM, reading, and focus order.
- Use native links, buttons, fields, tables, and dialogs so each control exposes its name, role, state, and value.
- Never use a positive `tabindex` to force focus order.
- Associate field labels, units, instructions, validation messages, and errors programmatically.
- Announce status changes without unexpectedly moving focus. Closing a dialog returns focus to its triggering control.
- Tables use captions and correctly scoped headers and are not used solely for page layout.
- Do not impose time limits unless essential. Authentication permits password managers and pasting and does not rely solely on a memory puzzle.
- Tooltips may supplement a visible label but never contain the only copy of essential information.
- Every icon-only control has an accessible name, such as `Download report` or `Open in new window`.

If visible text already names an adjacent tile image, use empty alternative text so a screen reader does not announce the name twice. Give an image concise alternative text only when it independently communicates content or is the sole content of a control. Decorative images use empty alternative text. Do not describe colors or visual styling unless they convey necessary information.

Charts include a concise text summary and accessible underlying values; alternative text alone is insufficient. Status belongs in programmatic status text rather than image alternative text.

Release review includes keyboard-only use at 200% browser zoom and the primary workflows with actual screen readers. Test Ubuntu Firefox or Chromium with Orca, Windows with NVDA, Android with TalkBack, and iPhone or iPad with VoiceOver where those platforms are supported. Automated checks supplement rather than replace manual assistive-technology testing.

## Charts

Each daemon selects chart types appropriate to its measurements. The shared standard controls presentation and accessibility, not clinical interpretation.

- Draw a primary data line at two CSS pixels on screen and approximately 1.25 points in a PDF. Keep reference and comparison lines visually secondary.
- Use light neutral major grid lines and avoid dense minor grids.
- Label every axis and unit. State the displayed time zone or the rule used to derive local time.
- Do not draw a continuous line across missing, invalid, or excluded readings.
- Use visible point markers where individual readings matter. A selected point changes marker size and outline rather than color alone.
- Distinguish multiple series with color plus marker shape, line style, pattern, or direct label.
- Label a series directly where practical instead of requiring repeated movement between the chart and a legend.
- Use product accents for measurement identity. Preserve operational warning and error colors for their defined meanings.
- Identify the source of any clinical threshold or reference range and do not present it as a diagnosis.
- Distinguish manual entries from imported device readings when provenance affects interpretation.
- Attach corrections, exclusions, and annotations to the affected reading.
- Make dashboard detail available by keyboard and touch without requiring hover.
- Provide a concise text summary and accessible underlying values or data table for every chart.
- Use aligned small charts rather than forcing measurements with substantially different units or scales onto one axis.
- Make all charts grayscale-safe and suitable for printing. Doctor-facing PDFs use restrained charts without gradients, decorative effects, or iconography.

## Theme preferences

Health Hub browser pages, including pages that present daemon-backed functions, support Light, Dark, and Use device setting. Theme choice affects interface presentation only; it does not alter approved assets, downloaded artwork, or doctor-facing PDFs.

- Store an authenticated person's explicit theme choice in the Health Hub database as the authoritative preference.
- Also store the choice in browser storage so login and logged-out pages preserve it.
- While logged in, the database value overrides browser storage and refreshes the browser copy.
- While logged out, use the browser-stored value. If no browser value exists, use Light.
- If the stored value is `system`, follow the operating-system preference. Do not treat an absent value as `system`.
- Retain the non-sensitive browser theme on logout. Hub-rendered daemon pages consume the theme resolved by Health Hub. Daemon services do not maintain interface-theme preferences.
- If a database save fails, the temporary session appearance may remain, but announce that the preference was not saved.
- Browser storage is a presentation cache and must not overwrite a newer authenticated database value.
- Apply the resolved theme before first paint where practical to avoid a light-theme flash.
- Do not recolor, invert, mask, or replace approved artwork. Put artwork on a controlled light or neutral surface when needed.
- Use deep blue-teal rather than pure black for the main dark surface, with slightly lighter panels, tiles, and dialogs.
- Revalidate text, borders, focus indicators, controls, statuses, charts, and disabled states for WCAG contrast in both themes.
- Preserve the defined status meanings instead of creating a separate semantic palette for Dark.
- Keep a PDF page white while allowing the surrounding browser viewer controls to follow the interface theme.
- Let supported browser controls and scrollbars follow the resolved theme.

## Interface language and states

Use plain, calm, factual, and nonjudgmental language. Prefer direct actions such as `Connect device`, `Try again`, or `Review excluded readings`. Avoid blame, medical conclusions, and unsupported reassurance. In ordinary Hub interfaces use `person`; a doctor-facing report may use `patient` when appropriate. State what happened, what was preserved, and what can be done next. Put technical diagnostics behind an expandable section.

Empty states distinguish among no recorded readings, no filter matches, a device that has not synchronized, an offline daemon, unconfigured access, and temporarily unavailable data. Provide a relevant next action where one exists. Do not use decorative sad or celebratory illustrations.

- Put a field error beside its field and provide an accessible page-level summary when several fields fail.
- Preserve entered information after validation and server errors.
- Do not expose stack traces, database errors, credentials, tokens, or device secrets.
- Provide a stable support or error reference when logs contain additional detail.
- Retry automatically only when the operation is safe to repeat and report the eventual result.
- Keep operational failures separate from medical warnings or interpretation.

Use motion only to explain a state change or active process. Keep routine transitions short and restrained, respect `prefers-reduced-motion`, and provide a nonanimated equivalent. Do not use decorative heartbeat animations, flashing, parallax, automatic carousels, attention-seeking movement, or celebratory effects for health measurements. Progress indicators include text and do not imply a completion time unless it is known.

## Deployed branding versions

Each Health Hub and daemon repository records its deployed branding inputs in `branding.lock.json`, using [`templates/branding.lock.example.json`](../templates/branding.lock.example.json) as the structural example.

- Reference a released branding version without a `-dev` suffix and record the exact source commit.
- List every copied branding asset, its source path, deployed destination, and SHA-256 checksum from this repository.
- Update the lock file in the same pull request as an asset change.
- Product CI verifies deployed files against the lock and fails on a missing or mismatched asset.
- Do not use a Git submodule or require this repository at runtime. Product repositories keep local deployable copies.
- A technical About or System Information view may expose the branding version. Ordinary health workflows do not.
- Never regenerate, replace, or accept mismatched approved artwork silently.

## Design-token delivery

This repository distributes shared visual values as machine-readable design tokens. `tokens/brand.tokens.json` is the source of truth and generates `tokens/brand.css` for browser interfaces.

- Include semantic Light and Dark colors, status colors, device-family accents, typography, spacing, radii, borders, focus treatment, motion, and chart presentation values.
- Name tokens by purpose rather than by a specific component or raw color name.
- Keep browser component behavior and markup in the Health Hub repository. Daemon repositories implement synchronization, data, and report APIs; this repository supplies stable presentation values, not a UI framework.
- Generate CSS from the JSON source and fail CI when committed generated output is stale.
- Verify required foreground and background pairs against the accessibility contrast requirements.
- Treat the token files as deployed branding assets and list copied versions in each product's `branding.lock.json`.

Approved semantic color inputs:

| Purpose | Light | Dark |
|---|---|---|
| Page background | `#F7FAFA` | `#0B1F22` |
| Primary surface | `#FFFFFF` | `#123036` |
| Muted surface | `#EAF7F6` | `#194047` |
| Primary text | `#102A2E` | `#F2FAFA` |
| Secondary text | `#475467` | `#C0D1D3` |
| Border | `#B8C8C9` | `#587176` |
| Interactive | `#00616E` | `#55D6D2` |
| Selected background | `#DDF4F2` | `#19484D` |
| Focus ring | `#007F88` | `#6CE5E1` |

Device accents remain unchanged but are not automatically text colors. Status meanings remain stable while theme-specific status values may vary to meet contrast. Approved artwork is not recolored. High-contrast and forced-color modes may override brand colors. The generated tokens are not releasable until every declared foreground/background pair passes the contrast verifier.

Approved typography defaults:

| Purpose | Size | Line height |
|---|---|---|
| Small and supporting | `14px` | `20px` |
| Body | `16px` | `24px` |
| Emphasized body | `18px` | `27px` |
| Section heading | `20px` | `28px` |
| Page heading | `24px` | `32px` |
| Large display | `32px` | `40px` |

Body text uses regular weight, labels and subordinate headings use medium, and major headings use bold. Measurements and dates use tabular numerals. Browser text remains scalable; token sizes are defaults rather than fixed limits.

The spacing scale is `4`, `8`, `12`, `16`, `20`, `24`, `32`, `40`, and `48` CSS pixels. Form controls use a 6-CSS-pixel radius, panels and dialogs 8, Hub tiles 12, and pills and badges a fully rounded value. Normal borders are one CSS pixel, selected borders two, and focus rings three with two CSS pixels of separation. Interactive targets remain at least 48 by 48 CSS pixels.

| Motion purpose | Duration |
|---|---|
| Immediate feedback | `100ms` |
| Standard transition | `180ms` |
| Larger state change | `250ms` |
| Reduced motion | `0ms` |

Use ease-out for entry and immediate response and ease-in-out for reversible state changes. Ordinary transitions do not exceed 250 milliseconds. Loading and syncing indicators may continue while work remains active, include text, and stop promptly when the state resolves.

Approved status foreground anchors:

| Status | Light | Dark |
|---|---|---|
| Ready | `#00616E` | `#6ED9D2` |
| Syncing | `#006F75` | `#55D6D2` |
| Attention | `#8A4B00` | `#FFC56B` |
| Error | `#B42318` | `#FF8A80` |
| Offline | `#475467` | `#C0D1D3` |
| Unknown | `#667085` | `#B8C0CC` |

Status color supplements the required label. Badges use subtle theme-specific surfaces and borders; a status does not recolor the entire page, panel, or health-function tile.

| Health function | Accent anchor |
|---|---|
| Weight | Coral `#FF7A61` |
| Blood Pressure | Coral `#FF7A61` |
| Blood Glucose | Warm gold `#F5A623` |
| Oxygen Saturation | Oxygen blue `#28B9E8` |
| Basal Body Temperature | Cycle plum `#8E5AA7` |

Measurement accents identify data families and do not mean good, bad, high, low, success, or failure. Use them for chart series, markers, and restrained emphasis rather than unverified body text. Use line style, marker shape, pattern, and direct labels when series share an accent. Future daemons receive function-based accents rather than manufacturer colors. The contrast verifier may select a darker or lighter semantic derivative while preserving these anchors.

## PDF report identity and layout

> Review note: This PDF specification is provisionally agreed. Review it with the project owner and Claude Code before implementing it in any daemon. That review should confirm the clinical content order, required provenance, timestamp presentation, and the boundary between daemon generation and Hub viewing.

Each daemon is the source of truth for its measurements, report content, and PDF generation. Health Hub may request, list, preview, open, or download the daemon-produced PDF, but it must not reconstruct or silently modify it.

### First-page header

- Human-readable daemon or device name in text.
- Report title and covered date range.
- Person identity supplied or resolved by Health Hub.
- Clear `Generated at` timestamp with time zone.

PDF reports are clinical documents intended for doctors. Do not include the organization avatar, daemon artwork, decorative icons, illustrations, banners, background motifs, or interface-style status symbols. Use typography, spacing, rules, tables, and clinically relevant charts to organize the report.

### Report body

- Put the principal measurements and charts before technical provenance.
- Label units on every measurement and chart axis.
- Distinguish `Taken at`, `Received at`, and `Entered at`; never collapse them into one ambiguous date.
- Show the source for manually entered or imported information when it affects interpretation.
- Mark missing, excluded, corrected, or invalid readings explicitly rather than drawing a continuous line through them.
- Keep annotations factual. Automated observations must identify the method and must not be presented as a diagnosis.

### Footer and provenance

Every page includes the report title, page number, and generation date. The report also records:

- daemon name and version;
- report schema or format version;
- stable report identifier;
- device identifier when appropriate and safe to disclose;
- measurement time zone or the rule used to display local time;
- applied filters or exclusions;
- data range and total included reading count.

### Browser presentation

Health Hub presents the daemon PDF in a browser-native or embedded viewer with visible download and open-in-new-window actions. A Hub page may provide an interactive, non-editing view of daemon data beside the PDF, but it must identify the daemon as the data source and must not replace the authoritative report.

### Accessibility and printing

- Use tagged PDFs when the generator supports them and preserve a logical reading order.
- Provide document title, language, selectable text, and alternative text for meaningful images.
- Charts require a text summary and distinguish series with labels, markers, or line patterns in addition to color.
- Ensure the report remains legible in grayscale and at 100% print scale.
- Do not place essential content inside decorative backgrounds or crop marks.
