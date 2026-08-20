# Health Hub architecture traceability matrix

## Purpose

This matrix traces every normative requirement group in [`HEALTH_HUB_SYSTEM_ARCHITECTURE.md`](HEALTH_HUB_SYSTEM_ARCHITECTURE.md) to the protected review sources, an approved architecture-review decision, or an approved focused standard. It is a review aid, not a second architecture specification.

The protected sources were reviewed at `home-health-hub/healthhub` commit `d38bef06a01aaaeb28b1b997b49bddf44403d07e`. Their hashes and full section routing are recorded in [`ARCHITECTURE_SOURCE_INVENTORY.md`](ARCHITECTURE_SOURCE_INVENTORY.md). `AR-nnn` references point to approved dispositions in [`ARCHITECTURE_REVIEW_FINDINGS.md`](ARCHITECTURE_REVIEW_FINDINGS.md).

## Traceability rules

- A protected-source citation shows where the subject originated; it does not override a later approved decision.
- An AR citation is required where sources conflicted, were incomplete, or were intentionally narrowed.
- A focused-standard citation owns presentation or implementation detail while the architecture retains the system boundary.
- “Owner decision” identifies an approved addition or clarification that was not fully specified by the protected sources.
- Implementation-verification citations establish observed current behavior, not permanent architecture.

## Requirement matrix

| Architecture requirement group | Classification | Protected source or focused standard | Approved decision |
|---|---|---|---|
| 1. Normative terms and requirement classifications | Architecture governance | `Preliminary.md` §29; review method | AR-015 |
| 2. Personal or household appliance; not a clinical or enterprise record system | Invariant | `Claude-foundation.md` §§1–5, 50; `Preliminary.md` §§1–4 | AR-001, AR-009 |
| 2. Normal integrated deployment is one host with independent services | Invariant | `Claude-foundation.md` §§1–5, 50; `Preliminary.md` §§1–4, 11, 27 | AR-001 |
| 2. Daemons remain independently installable and useful without the Hub | Invariant | `Claude-foundation.md` §§1–5, 50; `Preliminary.md` §§1–4, 27 | AR-001, AR-002 |
| 2. Distributed and WAN-facing coordination is outside current scope | Scope boundary | `Claude-foundation.md` §§1–5, 50; `Preliminary.md` §§1–4 | AR-001 |
| 2. Displays and external integrations are clients, not authorities | Invariant | `Claude-foundation.md` §§21–25, 30–39; `Claude-Addendum-HA.md` §§1–4, 18–20 | AR-001, AR-007 |
| 2. Named devices and manufacturers are examples, not an allowlist | Invariant | Source examples registered in `ARCHITECTURE_SOURCE_INVENTORY.md` | AR-001, AR-014 |
| 3. Physical device-to-driver-to-daemon-to-contract-to-Hub authority chain | Invariant | All three sources; Foundation §§1–5; Preliminary §§1–10, 27 | AR-002 |
| 3. Daemon owns synchronization, interpretation, durable measurements, state, configuration, capabilities, and device reports | Invariant | `Claude-foundation.md` §§1–5, 13, 40–47; `Preliminary.md` §§3–10, 25–28 | AR-002, AR-010 |
| 3. Hub owns household accounts, authorization, mappings, browser presentation, audit, integration configuration, and projections | Invariant | `Claude-foundation.md` §§1–5, 17–24, 40, 43–47; `Preliminary.md` §§3, 7–10, 12–17, 24–27 | AR-002 |
| 3. Hub cache does not transfer authority and must retain source identity | Invariant | Cross-source authority boundary | AR-002, AR-004 |
| 3. Hub never opens a daemon database | Invariant | `Preliminary.md` §§3–5, 8–9, 27 | AR-002, AR-013; `ADOPTION.md` persistence contract |
| 4. Account, person, actor, subject, profile, device, daemon, source, transport, and record IDs are distinct opaque domains | Invariant | `Claude-foundation.md` §§6–8; `Claude-Addendum-HA.md` §§5–7; `Preliminary.md` §§15, 25, 27–28 | AR-003 |
| 4. Subject is independent from actor and device memory slot | Invariant | Conflicting identity models in all three sources; interface contracts | AR-003 |
| 4. Assignment is capability-driven and reassignment is audited | Required capability | `Claude-foundation.md` §§6–8; `Claude-Addendum-HA.md` §§5–7; `Preliminary.md` §§15, 25, 28 | AR-003, AR-014 |
| 4. Valid readings may remain unassigned and are excluded from person-specific outputs until assignment | Required capability | Incomplete source identity models | AR-003 owner clarification |
| 5. Taken, received, and entered times retain their distinct semantics, zone, precision, uncertainty, and source | Invariant | `Claude-foundation.md` §§9–12; `Claude-Addendum-HA.md` §§12–15; `Preliminary.md` §§5, 25, 27–28 | AR-004 |
| 5. Missing device time is not fabricated | Invariant | `Preliminary.md` §§27–28 and verified device limitation | AR-004; implementation verification CR-006 |
| 5. Records retain source identity, raw/normalized values, units, provenance, quality, and correction history | Invariant | `Claude-foundation.md` §§9–13, 41–42; `Preliminary.md` §§5, 25, 27 | AR-004 |
| 5. Daemon owns idempotency, deduplication, retention, and auditable correction behavior | Invariant with implementation detail | Daemon storage authority in Foundation and Preliminary | AR-004 |
| 5. Sessions remain distinct from point readings; missing-state meanings remain distinct | Invariant | `Claude-foundation.md` §§14–20; `Preliminary.md` §§17–19, 28 | AR-009, AR-012; implementation verification CR-007 |
| 6. REST handles on-demand queries, configuration, reports, assignment, manual entry, and capabilities | Invariant | `Claude-foundation.md` §§25, 40; `Preliminary.md` §§8–10, 27–28 | AR-005, AR-006 |
| 6. APIs are versioned, bounded, authenticated, paginated, and capability-described | Required capability | `Claude-foundation.md` §§40, 43–44; `Preliminary.md` §§8–9, 27–28 | AR-005 |
| 6. Public means supported, not publicly exposed; integrated APIs default to loopback | Invariant | Ambiguous API language in Foundation and Preliminary | AR-005 owner decision |
| 6. Daemon authentication and Hub user authorization remain separate; automation credentials are scoped and revocable | Invariant | `Claude-foundation.md` §§40, 43–44; `Preliminary.md` §§8–9, 15 | AR-005 |
| 6. Every API provides checked-in, served, CI-validated OpenAPI 3.1 | Required capability | Owner requirement added during review | AR-005 owner decision |
| 6. Optional history endpoint is capability-advertised and does not create a Hub authority copy | Optional daemon capability | Claude Code handoff for Foundation §40.1 | AR-005 owner decision |
| 6. Optional manual-entry endpoint is daemon-validated, typed, attributable, auditable, and capability-advertised | Optional daemon capability | Claude Code handoff for Foundation §40.2; BBT design work | AR-005, AR-014 owner decision |
| 7. MQTT is near-real-time event delivery and never replaces REST or daemon history | Invariant | `Claude-foundation.md` §§25–29; `Preliminary.md` §§10, 27–28 | AR-001, AR-006 |
| 7. Publish rights are limited to daemon-owned and Hub-owned namespaces; other consumers subscribe only | Invariant | `Claude-foundation.md` §§25–29; `Preliminary.md` §§10, 27–28; Claude Code handoff | AR-006 |
| 7. MQTT commands are reserved unless separately approved | Invariant | Commands omitted from reviewed sources | AR-006 |
| 7. Events carry stable IDs, schema, times, provenance, and idempotency data; REST reconciles gaps | Required capability | MQTT source sections above | AR-006 |
| 8. Capability discovery is versioned, additive, and tolerant of unknown capabilities | Invariant | `Claude-foundation.md` §§13, 45–47; `Claude-Addendum-HA.md` §§8–11, 16–20; `Preliminary.md` §§8, 27–28 | AR-014 |
| 8. Logical source, physical device, daemon instance, and capability remain distinct through replacement | Invariant | `Claude-foundation.md` §§6–8; `Claude-Addendum-HA.md` §§5–7; `Preliminary.md` §§25, 27–28 | AR-014 |
| 8. Device behavior is advertised and guaranteed only after applicable verification | Invariant | Device-specific examples and dated claims across sources | AR-014, AR-015; implementation verification |
| 8. Web UI daemon configuration is schema-driven, daemon-validated and daemon-stored, read-only for unsupported fields, truthful about partial results, and audited without secrets | Required administration boundary | `Claude-foundation.md` §§13, 40, 43–47; `Preliminary.md` §§4, 8, 23, 27 plus owner-approved Web UI design | AR-002, AR-005, AR-014 owner decision 2026-08-20 |
| 9. Hub owns responsive browser presentation; daemons remain headless-capable | Invariant | `Claude-foundation.md` §§17–24; `Preliminary.md` §§12–14; interface standard | AR-002, AR-008; `INTERFACE_AND_REPORT_STANDARDS.md` |
| 9. Keyboard, mouse, touch, tablet, touch monitor, and assistive technology are supported | Required capability | Current approved interface standard | AR-008; `INTERFACE_AND_REPORT_STANDARDS.md`; `ADOPTION.md` |
| 9. The administration landing page is attention-first, capability-scoped, free of health content, explicit about unavailable/stale/unknown/degraded/failed state, and refreshes accessibly | Required administration interface | Approved interface standard plus owner-approved Web UI design | AR-008, AR-009, AR-011 owner decision 2026-08-20 |
| 9. Exact display hardware, rotation, night mode, and USB input are deployment options | Implementation choice | `Claude-foundation.md` §§21–24; `Preliminary.md` §§12–14 | AR-008 |
| 9. Station-assisted and personal-device confirmation are separate explicit flows | Required capability | `Preliminary.md` §§12–15 plus owner clarification | AR-008 owner decision |
| 9. Identity is not inferred through biometrics, presence, or proximity claims | Invariant | `Preliminary.md` §§12–15 | AR-008 |
| 10. Charts and summaries remain descriptive, non-diagnostic, and explicit about units, time, gaps, freshness, uncertainty, and provenance | Invariant | `Claude-foundation.md` §§9–20, 41–42; `Preliminary.md` §§6–7, 17, 25–27 | AR-009; `INTERFACE_AND_REPORT_STANDARDS.md` |
| 10. Goals and thresholds are not diagnoses or medical advice | Invariant | `Preliminary.md` §§7, 17, 25 | AR-009 |
| 10. Operational and health-data notifications remain distinct, deduplicated, attributable, and durably tracked | Required capability | `Preliminary.md` §17 and current daemon notification claims | AR-009; implementation verification CR-008 |
| 10. The notification center is capability-scoped and data-minimized, deduplicates without losing occurrence history, separates acknowledgment from verified resolution, and retains required non-dismissible security and policy notices | Required administration interface | `Preliminary.md` §§17, 24 plus owner-approved Web UI design | AR-009, AR-011 owner decision 2026-08-20 |
| 11. Daemon exclusively generates doctor-facing PDFs; Hub preserves exact bytes | Invariant | `Claude-foundation.md` §16; `Preliminary.md` §§6–7, 26–27 | AR-010; `INTERFACE_AND_REPORT_STANDARDS.md`; `ADOPTION.md` |
| 11. Report API defines authorization, jobs, metadata, integrity, and bounded delivery | Required capability | Report sections above and approved report contracts | AR-010; `ADOPTION.md` |
| 11. Doctor PDFs contain no decorative iconography; Hub summaries are separate artifacts | Invariant | Approved interface/report design | AR-010; `INTERFACE_AND_REPORT_STANDARDS.md` |
| 11. Integrated product provides Web and per-user Samba report access without exposing internal state | Required capability | `Preliminary.md` §§16, 26 | AR-012 owner decision |
| 12. Health-data delegation and technical administration remain separate | Invariant | `Preliminary.md` §§15, 24–25, 27 | AR-011 |
| 12. One primary SHA plus composable technical roles with independently audited assignment | Required capability | `Preliminary.md` §15 | AR-011 owner decision |
| 12. Administrative roles are changed individually with plain-language capability and effective-permission previews, separation-of-duty warnings, recent reauthentication, execution-time revalidation, immediate revocation, and sole-SHA protection | Required role-management interface | `Preliminary.md` §15 plus owner-approved Web UI design | AR-011 owner decision 2026-08-20 |
| 12. Health-data delegation is owner-controlled, granular by action and scope, optionally expiring, separately controls redelegation, previews access and download irreversibility, and is audited across its lifecycle | Required delegation interface | `Preliminary.md` §§15, 25–26 plus owner-approved Web UI design | AR-011 owner decision 2026-08-20 |
| 12. SHA has read-only access to others' Samba reports, owner access to their own, and disclosed host-level power | Required capability and disclosed trust boundary | `Preliminary.md` §§15–16, 20–25 | AR-011, AR-012 owner decision |
| 12. Versioned one-time user notice discloses SHA access | Required capability | Owner requirement added during review | AR-011 owner decision |
| 12. A separately assigned technical-support capability may expose audited minimum diagnostic metadata, but not measurements, manual observations, notes, reports, charts, or unrestricted person history | Required authorization boundary | Owner-approved Web UI administration design | AR-011 owner decision 2026-08-20 |
| 12. High-risk Web UI actions require recent reauthentication, execution-time revalidation, a complete consequence summary, and an audit reason; typed phrases are limited to destructive or difficult-to-reverse operations | Required security interaction | Owner-approved Web UI administration design | AR-011, AR-012 owner decision 2026-08-20 |
| 12. Secrets are shown once, represented afterward only by non-secret metadata, excluded from URLs/logs/notices/exports/diagnostics, rotated replacement-first, and handled through reauthenticated audited recovery flows | Required credential-management boundary | `Claude-foundation.md` §44; `Preliminary.md` §§15, 18, 20–24 plus owner-approved Web UI design | AR-005, AR-011, AR-012 owner decision 2026-08-20 |
| 12. Disabling an account suspends access while preserving the person and health history, explicitly suspends affected delegations, revokes sessions and account credentials, and cannot disable the sole active SHA | Required identity lifecycle | Owner-approved Web UI administration design | AR-011 owner decision 2026-08-20 |
| 12. Audit is append-only or tamper-evident and protected from ordinary administrators | Invariant | `Preliminary.md` §24 | AR-011 |
| 12. Audit viewing is read-only and capability-scoped; safe JSON/CSV export requires reauthentication and auditing; integrity failure is persistent and distinguished from empty or unavailable data | Required audit interface | `Preliminary.md` §24 plus owner-approved Web UI design | AR-011 owner decision 2026-08-20 |
| 12. Operational logging is component-owned, data-minimized, access-controlled, and separate from protected audit history | Invariant | `Preliminary.md` §24 | AR-011 |
| 12. Emergency, dependent, incapacity, default/maximum delegation-expiration, deletion, succession, and retention policies remain deferred | Deferred investigation | Gaps identified in `Preliminary.md` §§15, 24–25 | AR-011 |
| 13. Every component owns SQLite through SQLAlchemy 2.0 style and its own Alembic migrations | Implementation choice | Current direct-SQLite behavior in implementation verification CR-004; owner-selected future standard | AR-013 owner decision |
| 13. Backup is manifest-based, WAL-safe, integrity-checked, versioned, ordered, and restore-tested | Required capability | `Preliminary.md` §§18–19 | AR-012 |
| 13. Recovery distinguishes never captured, unsynchronized, excluded, and lost data; local backup limitations are disclosed | Required capability | `Preliminary.md` §§18–19 | AR-012 |
| 13. Backup transports are optional and Samba is not backup | Optional adapters and invariant boundary | `Preliminary.md` §§16, 18–19 | AR-012 owner decision |
| 13. Authorized administrators receive guided ordinary and advanced backup configuration, guarded consequential changes, destination testing, integrity and restore-test status, and a separate restore workflow | Required capability | `Preliminary.md` §§18–19 plus owner-approved Web UI design | AR-012 owner decision 2026-08-20 |
| 13. The optional rclone adapter exposes schema-defined task controls and dry runs without raw flags, raw configuration, shell construction, or a browser expert escape hatch | Optional adapter safety boundary | Owner-approved Web UI design | AR-012 owner decision 2026-08-20 |
| 14. Hub and daemons run as independent least-privilege native systemd services | Implementation choice | `Preliminary.md` §§11, 20–23; current units in implementation verification CR-011 | AR-013 |
| 14. Upgrades use compatibility checks, backup, controlled migrations, health checks, and recovery | Required capability | `Preliminary.md` §§20–23 | AR-013 |
| 14. Hub reports update availability but host administrator performs updates | Required capability and authority boundary | `Preliminary.md` §§20–23 | AR-013 |
| 14. Web service controls are fixed and capability-scoped: safe application actions for Hub Administrators, allowlisted restarts for System Recovery Administrators, and no browser-controlled service names or system commands | Required administration boundary | `Preliminary.md` §§11, 15, 20–23 plus owner-approved Web UI design | AR-011, AR-013 owner decision 2026-08-20 |
| 14. Docker removal applies to Hub/daemon packaging, while approved infrastructure such as MQTT and Mailpit may remain containerized | Implementation choice | Owner packaging clarification | AR-013 owner decision |
| 15. Home Assistant is an optional adapter over generic MQTT, with stable IDs, capability-driven discovery, cleanup, and distinct freshness/availability | Optional adapter | `Claude-foundation.md` §§30–39; `Claude-Addendum-HA.md` §§1–20 | AR-007; implementation verification CR-012 |
| 15. Other external MQTT consumers remain subscribe-only adapters | Optional adapters | `Claude-foundation.md` §§25–39; `Claude-Addendum-HA.md` §§1–4, 18–20 | AR-006, AR-007 |
| 16. Release plans classify work and do not inherit the historical initial-release list wholesale | Architecture governance | `Claude-foundation.md` §§48–49; `Preliminary.md` §29 | AR-015 |
| 16. Compatibility and deprecation are defined at each interface boundary; observations do not become architecture automatically | Architecture governance | `Preliminary.md` §§27–29 | AR-005, AR-014, AR-015 |
| 17. Specialized material stays with the document or contract having the clearest owner | Documentation governance | `ARCHITECTURE_SOURCE_INVENTORY.md` boundaries; existing focused standards | AR-002, AR-010, AR-015 |
| 18. Canonical adoption requires trace review, source comparison, owner and Claude Code review, explicit approval, and a separate source-document disposition | Architecture governance | `Preliminary.md` §29; `ARCHITECTURE_CONSOLIDATION_CHECK.md`; Phase 5 review plan | AR-015 |

## Coverage statement

The matrix covers every normative paragraph, list, and table row in the consolidation draft by architecture section and requirement group. Presentation details intentionally delegated from sections 9–11 are traced to their focused standards rather than duplicated. Future MQTT, backup, Home Assistant, OpenAPI, and capability contracts must add field- or operation-level traceability when created.
