# Branding adoption guide

This guide translates the shared branding standards into implementation boundaries for Health Hub and daemon repositories.

## Architecture boundary

Health Hub owns every interactive browser page, including pages that display or control daemon-backed functions. Do not add a separate browser interface to a daemon.

A daemon remains useful without Health Hub. Its API must support its core responsibilities, including:

- starting, scheduling, or reporting synchronization as appropriate to the device;
- reading its own durable data and synchronization state;
- generating and returning its authoritative PDF reports;
- reporting operational health and errors for an API client or administrator.

### Synchronization job contract

- Health Hub requests synchronization with `POST /sync-jobs` and an `Idempotency-Key`; the daemon creates and owns the job.
- Repeating the same key and request returns the original job. Reusing a key with different parameters returns `409 Conflict`.
- If an equivalent job is active for the same device and operation, return that job with `already_running: true` rather than starting another.
- Closing the Hub browser does not cancel daemon work. Clients retrieve state with `GET /sync-jobs/{job_id}`.
- Use `queued`, `running`, `succeeded`, `failed`, and `interrupted` states. Persist the job and idempotency record transactionally before work begins.
- Responses include stable job and error identifiers, device identity, creation/start/completion timestamps, progress when known, and imported/skipped/error counts.
- After a daemon restart, resume safely or mark abandoned work `interrupted`; never leave it silently `running`.
- A retry after interruption creates a new job and relies on reading-level deduplication to prevent duplicate measurements.
- Retain idempotency keys for a documented period, initially 24 hours. Retain completed job history according to the daemon's longer history policy.

Health Hub calls those APIs and presents the results. It does not become the source of truth for daemon measurements, recreate daemon PDFs, or require a daemon to use Hub presentation code.

An individual Hub-rendered daemon page may use the daemon's approved application or navigation image to identify the function visually. Pair it with the visible function-led page title and apply the shared alternative-text rules. This page image does not replace the organization avatar as the site favicon and is not inserted into doctor-facing PDFs.

## Health Hub adoption

1. Copy `tokens/brand.css` into the Hub's deployable static assets.
2. Record its source, destination, release, commit, and checksum in `branding.lock.json`.
3. Load the token CSS before component styles.
4. Resolve `light`, `dark`, or `system` and set the resolved `data-theme` on the root HTML element before first paint where practical.
5. Store the authenticated preference in the Hub database and browser copy according to the precedence in the interface standard.
6. Render daemon-backed functions with the same Hub components, accessibility behavior, and function-led naming as native Hub functions; use the approved daemon image as an optional page identifier.
7. Treat daemon API failures as operational states and preserve the daemon's error reference without exposing sensitive diagnostics.

### Theme state contract

The database preference and browser cache may contain `light`, `dark`, `system`, or no value. The runtime-resolved theme is always `light` or `dark`.

- Before authentication is known, use valid browser storage; use Light when it is absent, inaccessible, or malformed.
- After login, a valid database preference overrides and refreshes browser storage. An authenticated user with no database preference receives Light, not the previous browser user's choice.
- Keep the last successfully stored non-sensitive browser value on logout. A different user receives their own database preference after login.
- Apply an explicit change immediately. While logged in, persist it to the database first and update browser storage only after success. On failure, keep it in memory for the session, announce that it was not saved, and leave persistent browser storage unchanged.
- While logged out, save an explicit selection directly to browser storage. Never copy a logged-out choice automatically into a newly authenticated database record.
- Store `system`, not its current resolved color. Follow operating-system changes while selected, stop following them after explicit Light or Dark selection, and resolve unavailable system detection to Light.
- Catch storage-access errors and ignore corrupted values without breaking the interface.
- Use a preference revision or request sequence so a delayed database response or stale save cannot overwrite a newer in-session selection.
- Synchronize successful changes across open Hub tabs without placing user identifiers or health information in browser theme storage.
- The authenticated database preference remains authoritative.

### First-paint theme bootstrap

- Apply the valid browser-cached preference before first paint with a small inline script in the document `head`.
- If browser storage is absent, inaccessible, or invalid, render Light mode. For a cached `system` choice, resolve the current operating-system preference before paint.
- The pre-paint choice is temporary rendering state, not authenticated preference authority.
- After login or session restoration, retrieve the user's database preference and apply it when different.
- Update browser storage only after an authenticated preference is successfully retrieved or after the person explicitly changes it. Never upload a logged-out cached choice as the database preference.
- Keep the document's script-free initial background compatible with Light mode so a blocked or failed bootstrap does not cause a dark or bright flash.
- The bootstrap contains no identity or health data, performs no network request, and does not depend on the main JavaScript bundle.

### Controlled artwork surface

- Never invert, recolor, tint, or apply automatic Dark-mode filters to approved artwork.
- Place raster artwork on a controlled neutral surface that maintains sufficient separation from surrounding content in Light and Dark themes.
- Use consistent padding and a subtle theme-appropriate border so transparent or same-colored image edges remain distinguishable.
- Preserve the source aspect ratio without cropping or stretching identification artwork.
- Select an approved source resolution suitable for the rendered dimensions and high-density displays; do not upscale a visibly inadequate source.
- If approved artwork remains illegible, omit it and use the text-led identification fallback.
- Do not create or select a separate Dark-mode artwork variant unless the branding repository explicitly publishes and versions it for that role.
- Verify the artwork surface in Light, Dark, forced-colors, and platform high-contrast settings.

### Graceful-degradation contract

- Server-delivered HTML contains meaningful headings, labels, status text, reading summaries, and navigation links.
- Use real links and native form controls as the baseline. JavaScript may enhance their behavior without replacing their semantics.
- Images remain optional and never provide the only occurrence of a name, status, instruction, or measurement.
- Keep content in a logical document order that remains readable and operable if stylesheets fail.
- If JavaScript fails, preserve essential navigation and access to existing data wherever authentication permits.
- For actions that inherently require JavaScript, including live synchronization progress or interactive charts, provide a clear fallback explanation and a usable alternative where practical.
- Manual-entry forms retain server-side validation and submission. Client-side validation is an enhancement.
- Every chart view includes an accessible table or reading list that does not depend on chart JavaScript.
- Fallback and error content never exposes sensitive diagnostics.
- Test blocked images, blocked stylesheets, and blocked scripts as separate failure conditions.

### Resilient layout and text contract

- Support browser zoom and text-only scaling through at least 200%, and test up to 400% where practical.
- Use responsive reflow and avoid fixed heights on text-containing controls, cards, tables, alerts, and navigation.
- Allow labels, values, translated text, and device nicknames to wrap without overlap or clipping.
- Do not truncate medically important values, units, timestamps, person names, statuses, or error explanations.
- Use horizontal scrolling only for genuinely tabular data and preserve visible or programmatic row and column context.
- At narrow widths, reflow non-tabular multi-column layouts into one logical reading order.
- In forced-colors mode, preserve system colors and visible borders; do not rely on background images, shadows, or color alone.
- Icons and custom controls remain identifiable when forced colors replace authored colors.
- Language expansion must not separate labels from their controls or change the intended reading order.
- Test at 200% and 400% with representative long names, expanded translations, narrow touch screens, and forced-colors mode.

### Assistive-technology naming and announcement contract

- Give each interactive control one concise accessible name. Do not duplicate visible text with redundant `aria-label` values or image alternative text.
- Prefer native labels, headings, fieldsets, legends, and descriptions before adding ARIA.
- Treat decorative images and images that merely repeat an adjacent visible title as decorative with empty alternative text.
- Use one dedicated synchronization status region with `role="status"` or `aria-live="polite"`.
- Announce only meaningful transitions: started, completed, failed, interrupted, or action required.
- Do not announce every progress tick, elapsed-time change, retry, received reading, polling response, rerender, or animation.
- Deduplicate unchanged state so polling cannot repeatedly announce the same message.
- Reserve assertive alerts for failures that require immediate action or block the current task. Routine progress and success messages remain polite.
- Keep visible status wording and announced status consistent.
- Test accessible names and synchronization announcements with at least one screen reader using keyboard and mouse workflows.

### Dialog focus contract

- When a dialog opens, remember its trigger only as the preferred focus-return target.
- On close, return focus to the trigger only if it still exists, is visible, is enabled, and belongs to the current view.
- If the trigger is unavailable, move focus to the nearest logical surviving target, such as the updated record, surrounding section heading, or primary action.
- If the underlying view was replaced, focus the new page's main heading or a programmatically focusable main-content container.
- Never return focus to the document body, a hidden element, or a newly destructive action.
- If dialog completion deletes the triggering record, announce the result and move focus to the surrounding list or heading.
- Keep focus contained within a modal dialog while it is open, including its loading and recoverable error states.
- Allow Escape to close only when dismissal is safe. Require confirmation before discarding an unsaved destructive change.
- Test close-button dismissal, Escape, successful submission, deletion, route replacement, and asynchronous refresh.

### Mixed-input contract

- All actions work with keyboard and mouse. Primary workflows also provide comfortably sized touch targets.
- Do not infer input method from viewport width or assume a person uses only one input method.
- Never make an action available only through hover, swipe, drag, long-press, or right-click.
- Hover may add supplementary styling, but the same information and actions remain persistently discoverable.
- Use a minimum 44 by 44 CSS-pixel target where practical. When a smaller target is necessary, provide adequate spacing and an equivalent larger activation target.
- A scrolling gesture must not activate a control merely because the gesture began on it.
- Prevent duplicate activation when a browser emits pointer, touch, and synthetic click events for one gesture.
- Drag operations provide button or keyboard alternatives and a cancellation path.
- Keep keyboard focus indicators visible and distinct from hover styling.
- Test mixed sequences on touchscreen computers: touch then keyboard, mouse then touch, and keyboard while pointer hover remains active.

### Function, device, and source contract

- Keep primary Hub navigation function-led. Manufacturer and model remain secondary device metadata.
- Each daemon owns a stable physical-device ID. Health Hub uses a globally unambiguous `{daemon_id}:{device_id}` source reference.
- Daemon APIs expose device name, manufacturer, model, capabilities, connection method, and operational state; Health Hub does not infer capabilities from model names.
- With one configured source, select it without unnecessary selector UI. With several, provide an accessible selector near the page heading and allow a user-defined nickname without treating it as identity.
- Save the last selected source per Hub user and health function. If it disappears, select a valid remaining source and explain the change.
- One offline source does not make a function unavailable while another valid source remains.
- Offer an All devices view only for measurements with compatible meaning and units. Preserve daemon and device provenance for every reading, preserve original values and units, and never silently merge duplicate-looking readings from different sources.
- Use labels, marker shapes, and line styles when source distinction matters; do not assign permanent manufacturer colors.
- Keep person selection separate from device selection. Health Hub supplies or resolves the person and changing source must not silently change that person.
- A physical device does not imply one person unless explicitly configured.
- Several daemons may supply the same function category while retaining authority over their own measurements.
- Routes and bookmarks use function and stable source identifiers rather than manufacturer names.

### Daemon identification-image fallback

- The visible function-led page title remains the primary identifier. Daemon artwork is supplementary.
- If approved artwork is missing, unavailable, or fails to load, omit the image and preserve a complete, usable text-led layout. Do not expose a broken-image indicator.
- Do not substitute another daemon's artwork, generic daemon artwork, or a manufacturer logo.
- When an adjacent visible heading already provides the same identification, use empty alternative text for the image to prevent duplicate screen-reader output. Supply descriptive alternative text only when the image communicates additional information.
- Image availability never controls navigation, operational status, forms, actions, charts, or access to measurement data.
- Record a missing or failed asset as an administrative or deployment diagnostic without presenting it to the person as an alarming health or device error.
- Consumer CI verifies that required approved assets exist and match the branding lock. The runtime fallback remains required for incomplete or damaged deployments.

### Person-selection contract

- Health Hub owns interactive person selection and sends a stable `person_id` to the daemon for person-specific operations.
- Never infer the person solely from a selected device, signed-in account, browser state, or most recent reading. Device selection and person selection remain independent.
- Show the selected person near manual-entry, synchronization, chart, and report actions whenever the result belongs to or is filtered for that person.
- Before a person change discards or reassigns unsaved form data, require explicit confirmation. Changing the selected device never changes the selected person.
- With no selected person, disable person-specific submission and report actions and explain how to select one. Do not silently choose a default.
- Reject an unknown, deleted, inactive, or unauthorized `person_id` without substituting another person.
- The daemon validates the supplied person identity and stores it with resulting records, synchronization assignments, or report parameters as applicable.
- Audit data keeps the actor who performed an action separate from the person whose health data the action concerns.

### Device-label contract

- Keep the health function as the page title and primary navigation label regardless of manufacturer or model.
- In device selectors and details, show a user-defined nickname first when available. Otherwise use a normalized model label or a neutral function-based label such as `Blood pressure device`.
- Present manufacturer and model as secondary device details rather than as the identity of the health function.
- Manufacturer metadata is optional and may be missing or unreliable. Its absence must not prevent configuration or use of an otherwise supported device.
- Never infer capabilities, compatibility, or person identity from manufacturer or model text. Use explicit daemon-reported capabilities and stable identifiers.
- Distinguish devices with identical labels using a nickname, a non-sensitive shortened stable device ID, or a connection location.
- Preserve raw daemon-reported manufacturer and model values for diagnostics while allowing reviewed normalized display labels.
- Supporting another manufacturer requires no change to primary navigation, route structure, branding, or page layout.

### Measurement-time contract

- Keep `taken_at`, `received_at`, and `entered_at` independent. Never substitute one silently for another.
- Store known absolute instants in UTC and preserve the original device or local value, applicable IANA time-zone name, numeric offset, source precision, and clock source.
- For a naive device clock, preserve the raw local value and apply a configured device time zone only when known. Mark the result `exact`, `assumed`, `ambiguous`, or `unknown`; never silently use the daemon's current offset.
- Preserve repeated daylight-saving times as ambiguous without a reliable offset or ordering clue. Preserve nonexistent spring-forward values as invalid or uncertain rather than shifting them silently.
- Preserve the original device timestamp when correcting clock drift. Store corrected effective time, method, and reason separately, and do not rewrite history after a time-zone configuration change.
- Emit absolute API timestamps in RFC 3339 form with `Z` or an explicit offset and include original local value, IANA zone, precision, source, and certainty metadata where applicable.
- Assign `received_at` with the daemon's trusted ingestion clock and `entered_at` when a manual entry is committed. A missing `taken_at` remains missing.
- Display time in the Hub user's locale while identifying the applicable zone. Distinguish repeated local times with an offset or abbreviation.
- Sort first by reliable effective `taken_at`; keep uncertain records visible and use receipt time plus stable record ID only as a deterministic fallback.
- Do not imply exact chart spacing when source precision or certainty is insufficient.
- A PDF records the display zone, conversion rule, relevant uncertainty or correction, and timestamp semantics used at generation so later configuration changes do not alter it.

### PDF report-job contract

- A daemon accepts `POST /report-jobs` with the resolved person, a clearly defined inclusive/exclusive time range, display time zone, filters and exclusions, report format, and an idempotency key.
- Return `202 Accepted` with a stable `job_id`, status URL, queued state, and the future `report_id` when it can be assigned safely at submission.
- Repeating an idempotency key with the same normalized request returns the original job. Reusing it with a different request returns `409 Conflict`.
- Job states are `queued`, `running`, `succeeded`, `failed`, `interrupted`, and `expired`. `GET /report-jobs/{job_id}` returns timestamps, progress when meaningful, error references, the resolved request fields, generator and report-format versions, and output metadata.
- Closing or disconnecting the browser does not cancel a job. The daemon persists the normalized request and job state, then resumes safely after restart or marks the job `interrupted` with an explicit retry path.
- Generate into bounded temporary storage on the destination filesystem and publish by atomic rename. Never expose a partial PDF.
- Stream inputs and outputs where practical. Enforce documented limits for date range, reading count, output size, generation time, concurrency, and temporary-disk use. Reject an oversized request explicitly instead of silently truncating it.
- A completed report has stable metadata and a content endpoint that returns `application/pdf`, a safe `Content-Disposition` filename, a correct content length when known, and immutable content for that `report_id`.
- Report metadata includes SHA-256, byte length, generation time, daemon and report-format versions, resolved person, range, display time zone, filters and exclusions, reading count, and any report it supersedes.
- Health Hub verifies successful job state, report identity, and response media type before offering browser viewing or download. It never reconstructs or modifies the daemon-produced PDF.
- Retain report metadata after downloadable content expires. An expired-content response explains that regeneration creates a new report ID and may include later corrections or exclusions under the daemon's documented retention policy.
- Historical PDFs remain immutable. Corrections or exclusions produce a new report that may explicitly supersede an earlier report.
- Report creation, status retrieval, metadata retrieval, and content download remain usable through the daemon API without Health Hub.

### Independent daemon availability contract

- Track availability independently for each daemon and function. One unavailable daemon never disables unrelated Hub pages, navigation, data, or actions.
- Keep the affected function page available and show its operational state locally.
- Continue presenting durable cached readings when available and label them with the exact last successful refresh time and applicable time zone.
- Distinguish daemon unavailability from no readings, device disconnection, and failure between the browser and Health Hub.
- Disable only actions that require the unavailable daemon, such as starting synchronization or generating a new report.
- Keep previously obtained daemon-produced PDFs viewable while their established retention and authorization rules allow it.
- Never describe cached readings as live, current, or newly synchronized.
- Retry daemon availability checks with bounded exponential backoff and jitter, and provide a clear manual retry action without creating duplicate daemon jobs.
- Preserve unsaved manual-entry data if daemon availability changes while a form is open. Explain any submission limitation without clearing the form.

### Synchronization timeout contract

- The daemon owns authoritative job state. Health Hub never declares daemon work failed solely because a browser or Hub request timed out.
- Each synchronization job exposes `created_at`, `started_at`, a current `updated_at` or heartbeat, and an operation-specific execution deadline or timeout policy.
- When Health Hub cannot reach the daemon beyond its short availability threshold, stop presenting an unqualified active `Syncing` state and show `Unknown` while the outcome cannot be verified.
- When the reachable daemon reports `failed`, `interrupted`, or expiration under its own deadline, present that authoritative terminal state as `Error` or `Interrupted` with the safe error reference.
- After restart, the daemon reconciles persisted `running` jobs by resuming safely or marking them `interrupted`.
- Use operation-specific limits rather than one global timeout; a device-history transfer may legitimately take longer than an availability check.
- When state becomes `Unknown`, show the last confirmed progress and the exact time it was confirmed, including the applicable time zone.
- Poll with bounded backoff and reduce or suspend high-frequency polling while the page is hidden or after the job becomes terminal.
- A manual retry first retrieves the existing job state and never blindly submits a second job.
- Never leave an indefinite `Syncing` presentation without a current daemon heartbeat or a visible explanation that confirmation is pending.

### Synchronization recovery contract

- The daemon continues and owns a synchronization job independently of Health Hub and the browser that requested it.
- Health Hub stores the daemon ID, stable `job_id`, operation, device, applicable person assignment, submission time, and idempotency key in its database rather than relying on browser storage.
- On page load, authenticated-session restoration, or return to the function page, Health Hub finds its active job record and retrieves current state from the daemon.
- Browser storage may hold a non-sensitive navigation hint but never acts as the authoritative job record.
- Before submitting synchronization, Health Hub checks for an active equivalent job. For a request whose submission outcome is uncertain, reuse the original idempotency key rather than generating a new one.
- If the daemon returns `already_running`, attach Hub presentation to that existing job.
- Authorize access to job state for the current account and person context. Never inherit another user's job presentation from shared browser state.
- If a referenced job has aged out of daemon retention, show `Unknown` with the last confirmed information and allow an explicitly new synchronization request.
- Multiple browser tabs attach to the same persisted job and do not start competing jobs.

### Standalone daemon contract

- Health Hub is an optional API client and never a runtime dependency of a daemon.
- Without Health Hub, a daemon can start, discover or configure supported devices, synchronize, store and retrieve durable data, report operational status, and generate and retrieve authoritative PDFs.
- Expose standalone capabilities through documented, versioned APIs suitable for another client or administrative tool.
- Daemon authentication and authorization do not require an active Hub session. A deployment may configure independent service credentials and network policy.
- Keep measurements, job state, report metadata, and retention state in daemon-owned durable storage.
- Do not require Hub assets, JavaScript, routes, templates, theme state, or browser presentation code.
- Headless API responses include stable identifiers, timestamps, state, safe error references, and machine-readable errors.
- Treat Health Hub person and device mappings as explicit API inputs or durable mappings. Loss of Hub connectivity must not corrupt daemon-owned identity or provenance.
- Standalone operation never implies anonymous access; the daemon enforces its configured authentication and network boundaries.
- Integration tests exercise synchronization, durable-data retrieval, operational status, and PDF generation while Health Hub is absent.

### Scoped operational-status contract

- Do not collapse independent operational facts into one status or apply a universal priority order.
- Choose the primary status according to the current task and the condition that most directly blocks or changes it. Present other relevant facts as explicitly labeled secondary status text or badges.
- `Error` describes a failed operation and does not imply general daemon unavailability.
- `Offline` describes lost daemon availability and does not replace the known outcome of the last job.
- `Syncing` describes a daemon-confirmed active synchronization job.
- `Attention` describes a non-failure condition requiring review and states what needs attention.
- For an active synchronization with an older reading requiring review, use primary `Syncing` and secondary `Attention`.
- For a failed synchronization while the daemon remains reachable, use primary `Error` and secondary `Online`.
- For an unreachable daemon after a failed job, use primary `Offline` and secondary `Last sync failed`.
- Never present `Syncing` as current when daemon state is unconfirmed. Use `Unknown` and retain the last confirmed job fact.
- Color and icons remain supplementary; visible text communicates every status.
- Status details identify their scope, timestamp, safe explanation, and available next action.
- Screen-reader announcements report meaningful primary transitions only, while secondary facts remain programmatically available on demand.

### Measurement-conversion contract

- The daemon preserves the original numeric value, original unit, source precision, and raw device representation when available.
- A conversion creates a display or canonical value and never replaces or rewrites the stored original.
- Record the canonical conversion method or version when conversion affects an API response, export, comparison, or report.
- Convert from the original value rather than from an already rounded display value.
- Round only for presentation, using documented rules appropriate to the measurement type and target unit.
- Show the selected display unit prominently and make the original value and unit available in reading details.
- For manual entry, preserve the value, unit, and precision as entered and additionally store a canonical value when comparison requires it.
- Changing preferred display units re-renders historical data without modifying stored readings.
- Charts, tables, summaries, and PDFs apply consistent conversions and identify their displayed units.
- Comparisons and thresholds use an explicitly documented canonical representation and avoid floating-point equality at meaningful boundaries.
- API fields distinguish original, canonical, and display values rather than overloading one value field.

### Reading identity and ordering contract

- A timestamp is not a unique reading identifier. Preserve distinct readings that share the same effective `taken_at`, including readings from one device.
- Deduplicate only by a daemon-defined stable source record ID or an exact, documented source fingerprint; matching time and value alone is insufficient.
- Preserve device, daemon, synchronization or import job, transport record, raw-payload reference or hash, and receipt time as provenance when available.
- Accept readings received out of chronological order without rewriting their taken time or treating them silently as the newest measurement.
- Sort presentation first by reliable effective `taken_at`, then by deterministic provenance such as `received_at` and stable record ID.
- Mark uncertain or corrected times and keep them accessible rather than forcing them into a falsely precise order.
- When several readings occupy identical chart coordinates, retain every point and provide keyboard- and touch-accessible inspection of each reading.
- Summaries document whether all same-time readings are included and never silently select one.
- A later duplicate determination creates an auditable linkage or exclusion and does not destructively delete the original record.
- Pagination and synchronization cursors combine stable identity and ordering fields so late-arriving readings are not skipped.

### Unknown measurement-time contract

- Keep `taken_at` absent when the measurement time is unknown. Never copy `entered_at`, `received_at`, synchronization time, or a file timestamp into it.
- Record `entered_at` as the time a manual record was committed and `received_at` as the trusted ingestion time.
- In lists and details, show `Taken at: Unknown` and present `Entered at` or `Received at` separately with its correct label.
- A measurement-time chart does not place an unknown-time reading on a fabricated date.
- Keep unknown-time readings visible in an accessible separate section or list.
- Summaries and date-range reports explicitly define whether unknown-time readings are excluded, included separately, or selected by receipt or entry range.
- If a person later supplies measurement time, retain the original record state and add an auditable correction with actor, reason, and correction time.
- API filters distinguish measurement-time range from receipt-time and entry-time ranges.
- PDFs state how unknown-time readings were handled and never label entry or receipt time as measurement time.

### Report supersession contract

- A generated PDF is immutable for its `report_id`; never rewrite or replace its bytes.
- Reading corrections and exclusions are append-only audited changes that preserve the earlier state and the reason for change.
- A report uses the data state effective at generation and receives a new `report_id`.
- New report metadata may identify an older report as `supersedes`; retain the older report until its normal content-retention expiry.
- Report metadata outlives downloadable content and retains its hash, generation time, resolved inputs, included reading IDs and versions or a reproducible snapshot reference, and supersession links.
- Never add a banner, watermark, page, annotation, or other modification to a historical PDF after generation.
- Health Hub may state separately that a newer report exists while leaving the older daemon-produced PDF unchanged.
- When a correction or exclusion affects a requested period, offer a new report instead of silently changing the old one.
- Regeneration is not byte-for-byte reproduction: it receives a new ID and may reflect later corrections, exclusions, report-format versions, or other approved data changes.
- Audit records identify the actor, time, and reason for a correction or exclusion and the later reports that incorporated it.

### Dense-chart aggregation contract

- Aggregation is a presentation optimization and never creates replacement measurement records.
- The daemon remains the source of every underlying reading and its provenance.
- Select aggregation according to chart pixel width and requested time range rather than applying hidden permanent data reduction.
- Prefer a method that preserves visible shape and extremes, such as minimum and maximum envelopes with a representative value, instead of a simple average alone.
- Label an aggregated view and identify its bucket interval or method.
- Selecting or focusing a bucket reveals its reading count, time span, minimum, maximum, and displayed representative value.
- Provide an accessible table, list, or drill-down exposing every underlying reading in a bucket.
- Zooming or narrowing the time range retrieves or renders progressively finer data until individual readings appear.
- Do not connect across missing-data gaps in a way that implies measurements occurred.
- Alerts, thresholds, calculations, and PDF source data operate on underlying readings rather than chart pixels or aggregated points.
- Aggregation is deterministic for the same input data, range, pixel width, and method version.
- APIs distinguish raw-reading endpoints from optional display-aggregation endpoints.

### Accessible-chart encoding contract

- Never distinguish a series, source, threshold, or state by color alone.
- Combine reviewed contrast-safe colors with marker shapes, line styles, direct labels, or patterns.
- Assign distinctions for the current chart's series set rather than using permanent manufacturer colors.
- Keep each series mapping consistent across chart, legend, tooltip, accessible table, and PDF.
- Use direct labels where space permits; otherwise provide a visible legend adjacent to the chart.
- Ensure meaningful lines, markers, focus indicators, and boundaries meet applicable WCAG non-text contrast requirements against their backgrounds and adjacent series.
- Provide larger invisible pointer targets around thin visible lines or markers without changing their visual meaning.
- In grayscale, every series and threshold remains identifiable through shape, dash pattern, label, or position.
- Dark mode uses reviewed accent derivatives rather than automatic inversion.
- Forced-colors mode uses system colors together with shape, line style, and text labels.
- Every chart has a text summary and accessible reading table independent of its visual encoding.
- Test Light, Dark, grayscale, forced colors, common color-vision deficiencies, keyboard focus, touch selection, and printed or PDF output.

### Resolved report-metadata contract

- Report-job and completed-report metadata return daemon-resolved values rather than only echoing the client's original request.
- Include stable person ID and a safe display label without unnecessary personal information.
- Include exact range boundaries, each boundary's inclusive or exclusive meaning, and the time zone used to resolve calendar dates.
- Identify whether selection uses measurement time, receipt time, or entry time.
- Include selected devices or sources, reading types, filters, exclusions, display-unit choices, and unknown-time handling.
- Distinguish explicitly requested values from daemon-applied defaults.
- Record the normalized request hash or canonical request representation used for idempotency.
- Return included-reading count, excluded counts by reason, and the applicable correction or snapshot cutoff.
- Store the same resolved metadata with the immutable `report_id` so later retrieval does not depend on current settings.
- Health Hub presents its review summary from daemon-returned metadata and does not reconstruct authoritative report parameters independently.
- Never include credentials, internal filesystem paths, sensitive query implementation details, or unsafe diagnostics in report metadata.

### PDF response-verification contract

- Health Hub retrieves content only after the daemon reports the expected `report_id` as `succeeded`.
- Require an HTTP success status. Never pass a redirect, authentication page, or error response to the PDF viewer.
- Require `Content-Type: application/pdf`; reject HTML, JSON, plain text, missing, or conflicting media types.
- Validate the PDF file signature and never use content sniffing to override an incorrect declared media type.
- Match returned report identity and immutable metadata to the requested report.
- When supplied, verify `Content-Length` against configured limits and verify SHA-256 before making the report available.
- Enforce a configured maximum download size and stream through bounded storage rather than buffering unlimited content.
- Use the daemon-provided filename only after sanitization; reject path components and executable extensions.
- Present verified content with `X-Content-Type-Options: nosniff` and provide an explicit download option.
- On validation failure, show a safe report error and correlation reference rather than the response body or a broken PDF viewer.
- Never cache an authentication or error response under a report ID.
- Log status, declared media type, byte length, report ID, and integrity result without logging report content or sensitive headers.

### Expired report-content contract

- Retain immutable report metadata after PDF content expires according to a documented metadata-retention policy.
- Metadata retains report ID, hash, byte length, generation time, resolved inputs, included data snapshot or version, report-format version, and supersession links.
- The content endpoint returns an explicit expired response distinct from not found and not authorized.
- Health Hub shows when content expired and preserves available non-sensitive report details.
- Regeneration is an explicit new report request with a new idempotency key and new `report_id`.
- Before regeneration, explain that the result may include later corrections, exclusions, late-arriving readings, changed defaults, or a newer report format.
- A client may request the original resolved parameters, but the daemon revalidates current authorization and currently supported options.
- New report metadata may link to the expired report as `regenerated_from`; the link never implies identical content.
- Exact historical reproduction requires a retained versioned data snapshot and compatible report generator. Otherwise state that exact reproduction is unavailable.
- Expiration never permits Health Hub to fabricate, rebuild, or modify a daemon report.
- Content and metadata retention periods are daemon-owned, configurable, and exposed through the API.

### PDF font contract

- Use the approved Atkinson Hyperlegible Next family for doctor-facing PDFs when the generator can legally and technically embed it.
- Package a pinned font version with the daemon and never download fonts during report generation.
- Embed or subset every used style and weight so viewing does not depend on fonts installed on another computer.
- Preserve the font license and required notices in the daemon distribution.
- If required embedding fails, fail report generation visibly instead of silently producing an inconsistent document.
- A deliberately supported fallback is pinned and metrically tested against the complete layout; record its exact family and version in report metadata.
- Never use an uncontrolled system-font fallback chain for PDF generation.
- Technical report metadata records font identity, embedding or subsetting status, and PDF generator version.
- Test required characters, units, symbols, names, and supported languages before enabling a font.
- Validate generated PDFs for missing glyphs, substituted fonts, clipped text, and searchable or extractable text.
- A font change increments the report-format version because pagination and chart-label layout may change.

### Report resource and temporary-storage contract

- The daemon enforces configurable limits for report range, reading count, generated size, execution time, concurrent jobs, and temporary-disk use.
- Reject requests exceeding known limits before generation where possible and never silently truncate a report.
- Read measurements incrementally or in bounded pages instead of loading an unlimited result set into memory.
- Write output to a uniquely named private temporary file on the same filesystem as final report storage.
- Use restrictive permissions and never expose temporary paths through APIs or logs.
- Track bytes written and abort safely before exceeding the configured output limit.
- Check available disk space before and during generation while reserving headroom for other daemon operations.
- Publish only a closed and validated PDF through atomic rename.
- After cancellation, timeout, crash, or validation failure, recovery removes incomplete temporary output without deleting completed reports.
- Stream completed downloads with backpressure and bounded buffers.
- Limit generation concurrency separately from download concurrency to prevent resource starvation.
- Test oversized ranges, disk exhaustion, process interruption, slow clients, concurrent jobs, and cleanup after restart.

### Authoritative PDF transport contract

- The daemon is the sole generator and authority for PDF bytes and report content.
- Health Hub may request, verify, cache within policy, display, and download the exact daemon-produced bytes.
- Health Hub never adds, removes, reorders, rasterizes, annotates, signs, compresses, watermarks, or otherwise rewrites PDF content.
- Hub page headers, navigation, branding, print controls, and status messages remain outside the embedded PDF document.
- A Hub print action opens or prints the verified daemon PDF and never generates an HTML-to-PDF substitute.
- Preserve the daemon-provided SHA-256 through Hub retrieval, caching, viewing, and download.
- If transport or storage changes the bytes, integrity verification fails and the report is not presented as authoritative.
- A sanitized download filename may differ without changing file content or `report_id`.
- Any future annotation workflow stores annotations separately and never represents an annotated derivative as the daemon's authoritative report.
- Doctor-facing PDFs remain free of Hub and daemon iconography and decorative branding.
- Integration tests compare the daemon hash with Hub-served and downloaded content byte for byte.

The Hub may copy approved organization, Hub, application, and navigation artwork required by its pages. It does not copy README banners into the application.

## Daemon adoption

1. Keep approved repository and device artwork required for documentation or distribution and record copied branding inputs in `branding.lock.json`.
2. Do not implement a branded browser UI or a separate theme preference.
3. Keep synchronization, durable data, operational state, and PDF generation available through the daemon API without Health Hub.
4. Keep report generation deterministic for the same data and report parameters where practical.
5. Return a stable report identifier, media type, filename, generation time, and report-format version with a generated PDF.
6. Preserve `Taken at`, `Received at`, and `Entered at` as distinct fields when applicable.
7. Use design-token source values needed for report typography or charts without importing browser-only component behavior.

The doctor-facing PDF specification remains provisional and must be reviewed with the project owner and Claude Code before implementation.

## Branding lock

Start from [`templates/branding.lock.example.json`](../templates/branding.lock.example.json). Use a released branding version without a `-dev` suffix, an exact source commit, and SHA-256 values from this repository's `SHA256SUMS`.

Product CI must verify that every listed destination exists and matches its checksum. An asset or token update and its lock-file update belong in the same pull request. Do not fetch branding assets at runtime or use this repository as a submodule.

### Release and lock-validation contract

- Consumer CI validates `branding.lock.json` against a published immutable branding release before accepting copied assets.
- Reject development versions such as `-dev`, nonexistent tags or releases, and versions incompatible with the lock schema.
- Require a full source commit SHA and verify that it belongs to the declared release.
- Reject missing source assets, unapproved asset roles, invalid consumer destinations, and duplicate destination mappings.
- Verify the source release checksum and the copied destination checksum.
- Validate that each asset role matches its allowed use and destination, such as favicon, launcher icon, daemon navigation image, or token file.
- Reject source or destination paths that escape the repository or approved asset directory.
- Verification never fetches, modifies, or repairs branding automatically; it reports the exact mismatch and fails.
- A lock update and its copied-file update belong in the same commit or pull request.
- Record the lock schema and verifier version so validation behavior is reproducible.
- If signed branding releases are introduced, extend verification to their published provenance or signature.

### Token compatibility and versioning contract

- Treat published token names and meanings as a versioned public contract for consumer repositories.
- Removing, renaming, retyping, changing units, or changing the semantic role of a token requires a major branding version.
- Never reuse a retired token name for a different purpose, including in a major release; introduce a new name.
- Adding a backward-compatible token requires a minor release.
- Documentation-only corrections with no generated-output change may use a patch release.
- A value adjustment that preserves the documented semantic role may be minor or patch according to visual impact, but still passes contrast and specimen verification.
- Deprecate before removal where practical, document the replacement, and retain the old token through the current major version.
- Generated CSS and source JSON expose the same token set and compatible value types.
- Release CI compares against the previous release and fails when the declared version is too small for detected contract changes.
- Release notes list added, deprecated, removed, renamed, and semantically changed tokens with consumer migration guidance.
- Consumers pin exact branding releases and never receive token contract changes automatically.

### Branding release-completeness contract

- Each branding release is an atomic, self-consistent set of approved source assets, generated exports, tokens, documentation, checksums, and manifest metadata.
- Define required files and roles in a release manifest; CI rejects a release missing a required member.
- When a source image changes, regenerate and verify every declared derivative before release.
- When a token affects artwork surfaces, contrast, charts, or specimens, update and verify those dependent artifacts in the same release.
- Never publish from a commit containing stale generated files or checksums.
- The version, source commit, manifest, `SHA256SUMS`, generated CSS, and documentation agree.
- Create a release only after reproducible-build, checksum, asset-role, token, contrast, and specimen checks pass.
- Consumers update to one exact release and do not combine tokens from one release with images from another.
- Emergency correction releases still contain a complete coherent set when only one source asset changed.
- Document intentional asset removals and their migration path; do not represent omission as an accidental missing file.
- CI builds the candidate release in a clean temporary checkout so untracked local files cannot complete an otherwise incomplete release.

### Consumer branding-verification contract

- Every consumer repository commits `branding.lock.json` together with the exact copied assets and tokens it declares.
- CI validates lock schema, pinned release, full source commit, allowed roles, source paths, destination paths, and SHA-256 values.
- Recompute each destination checksum from the consumer worktree rather than trusting the checksum written in the lock.
- Reject missing files, unexpected replacements, duplicate destinations, path escapes, and content that does not match the pinned release.
- Verify generated token files against their declared source token file and generator version where applicable.
- Require every managed branding destination to appear in the lock so a manual replacement cannot remain untracked.
- Permit unrelated consumer-owned images only outside branding-managed paths or through an explicit allowlist.
- Run routine verification without network access using checked-in lock data and a pinned release manifest and checksum set; refresh release provenance separately.
- Report the exact asset, expected checksum, actual checksum, source release, and remediation command.
- Verification never modifies the consumer worktree.
- A branding update changes copied files and lock data together and passes the consumer's normal visual and accessibility checks.
- Local verification and CI use the same pinned verifier version and command.

## Required verification

Health Hub implementation review includes:

- Light, Dark, logged-in, and logged-out theme behavior;
- database/browser preference precedence;
- mouse, touch, keyboard, screen-reader, zoom, and reduced-motion workflows;
- function-led names and accessible status announcements;
- chart summaries, accessible values, and grayscale behavior;
- lock-file and copied-token verification.

Daemon implementation review includes:

- standalone synchronization and data access without Health Hub;
- standalone PDF generation through the API;
- report provenance and timestamp fields;
- lock-file verification for copied assets or tokens;
- confirmation that no separate browser interface was introduced.

## Ownership summary

| Concern | Authority |
|---|---|
| Browser pages and interaction | Health Hub |
| User identity and theme preference | Health Hub |
| Device synchronization | Daemon |
| Measurement data and provenance | Daemon |
| PDF content and generation | Daemon |
| PDF browser viewing and download coordination | Health Hub |
| Shared visual rules and token values | Branding repository |
| Deployed copies of assets and tokens | Consuming repository, locked to a branding release |
