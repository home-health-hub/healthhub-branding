# Health Hub architecture source inventory

## Review snapshot

The source documents are checked out locally from `home-health-hub/healthhub` at commit `d38bef06a01aaaeb28b1b997b49bddf44403d07e`.

| Read-only source | Lines | SHA-256 |
|---|---:|---|
| `docs/Claude-foundation.md` | 1,488 | `4bbd19a2b8c6dd757f0fd13b6f4884152908c7a342d7dae692510e68f4b282c3` |
| `docs/Claude-Addendum-HA.md` | 412 | `6c3009630a131e5d7928cbacd6efd5438e172d86c86d3a88183ece001027a805` |
| `docs/Preliminary.md` | 913 | `42e91223f969210cb252ad365247c35a1f43acbc8d6f4d2e6fa056b3d71c6d00` |

These hashes identify the review inputs; they do not declare any source authoritative. The original files remain in the Health Hub repository and are not copied into this repository.

## Source character

### `Claude-foundation.md`

An early broad technical design covering daemon and Hub responsibilities, people and devices, timestamps, freshness, O2Ring data, dashboards, trends, MQTT, Home Assistant discovery, REST APIs, security, configuration, extensibility, and initial-release scope.

Initial review notes:

- It repeats Home Assistant material later isolated in the addendum.
- It contains device-specific examples and an initial four-daemon list that must not be mistaken for a permanent support boundary.
- It mixes architectural requirements, rationale, UI suggestions, illustrative topic names, and release planning.
- Statements about daemon behavior require verification against current code before consolidation.

### `Claude-Addendum-HA.md`

A focused Home Assistant MQTT Discovery proposal covering generic MQTT independence, discovery messages, entity organization, profile/device separation, device replacement, capability-driven entities, timestamps, availability, retained state, and configuration changes.

Initial review notes:

- Much of its content overlaps the MQTT and Home Assistant sections of `Claude-foundation.md`.
- Example topics and entity names contain a personal name and must remain examples rather than fixed identifiers.
- Discovery requirements depend on current Home Assistant behavior and will require primary-documentation verification.
- Its principle that Home Assistant is an optional consumer is compatible with the current independence direction, but the exact data and entity contracts remain unreviewed.

### `Preliminary.md`

A later preliminary architecture document emphasizing the household appliance model, independent daemons, storage and API boundaries, daemon reports, Hub API and MQTT, services, interaction, administration, permissions, notifications, backup, host ownership, audit, and code-review findings.

Initial review notes:

- It contains the widest operational and administrative scope of the three sources.
- It mixes desired architecture with claims described as confirmed from source review.
- Those code-level claims are a dated snapshot and must be reverified before becoming consolidated requirements.
- Its status section explicitly says it is not yet an implementation specification.

## Initial overlap map

This map identifies review areas, not approved resolutions.

| Topic | Foundation | HA addendum | Preliminary | Current interface/report contracts |
|---|---|---|---|---|
| Daemon independence and authority | Substantial | Constraint only | Substantial | Substantial |
| Hub aggregation and presentation | Substantial | MQTT presentation | Substantial | Browser presentation boundary |
| Person/profile versus device identity | Substantial | Substantial | Substantial | Explicit person/source separation |
| Measurement timestamps and freshness | Substantial | Substantial | Substantial | Taken/received/entered contract |
| MQTT architecture and Hub/daemon coordination | Explicit near-real-time daemon input plus Hub output | Substantial external-integration focus | Explicit near-real-time input split from REST | Outside current branding scope |
| Home Assistant discovery | Substantial | Primary focus | Briefer integration coverage | Outside current branding scope |
| Browser/dashboard presentation | Substantial | Entity organization only | Substantial | Detailed interface contracts |
| Charts and trends | Substantial | Session summary examples | Substantial | Detailed chart contracts |
| Doctor-facing PDFs | Daemon-owned | Not central | Daemon-owned | Detailed daemon PDF authority |
| Roles, permissions, and administration | Limited | Not central | Substantial | Person/actor separation only |
| Backup, recovery, host, and updates | Limited | Not central | Substantial | Outside current branding scope |
| Device capabilities and replacement | Substantial | Substantial | Substantial | Manufacturer-neutral source contract |

## Section-to-topic map

This compact map routes every substantive numbered source section into the detailed review categories. Section ranges do not imply that all statements in a range share one disposition.

### `Claude-foundation.md`

| Sections | Primary review category |
|---|---|
| 1–5, 50 | System scope; Hub/daemon authority boundaries |
| 6–8 | Person/profile, physical-device identity, and replacement |
| 9–12 | Measurement metadata, timestamps, display, and freshness |
| 13 | Device-specific capability preservation |
| 14–16 | O2Ring spot/session model and presentation |
| 17–20 | Current state, recent data, trends, and change summaries |
| 21–24 | Physical display, dashboard layout, rotation, and night mode |
| 25–29 | MQTT purpose, publisher boundary, topics, data model, and O2Ring sessions |
| 30–39 | Home Assistant discovery, entity/device organization, independence, availability, and retained state |
| 40 | Hub and daemon REST APIs |
| 41–42 | Data quality and units |
| 43–44 | Configuration and security |
| 45–47 | Extensibility and normalization boundaries |
| 48 | Decision rationale register |
| 49 | Initial-release scope |

### `Claude-Addendum-HA.md`

| Sections | Primary review category |
|---|---|
| 1–4 | Optional Home Assistant integration, generic MQTT, and discovery |
| 5–7 | Home Assistant organization, person/profile identity, and device replacement |
| 8–11 | Device-specific entities and capability preservation |
| 12–15 | Measurement timestamps, staleness, availability, and retained state |
| 16–20 | Capability-driven discovery, configuration change, independence, and constraints |

### `Preliminary.md`

| Sections | Primary review category |
|---|---|
| 1–4 | Household scope, single-appliance assumptions, authority boundaries, and daemon independence |
| 5 | Daemon storage ownership |
| 6–7 | Daemon reports, Hub summaries, and health-document scope |
| 8–10 | Daemon API, Hub API, MQTT, and publisher boundaries |
| 11 | systemd service model |
| 12–14 | User interaction, primary Web UI, and optional displays |
| 15 | Accounts, administration, roles, delegation, and health-data access |
| 16 | Samba access |
| 17 | Notifications and alert ownership |
| 18–19 | Backup, restore, and unrecoverable data |
| 20–23 | Host OS, Python environments, updates, and software ownership |
| 24 | Logging and auditing |
| 25 | Health-data ownership |
| 26 | Report access |
| 27 | Cross-category architectural constraint register |
| 28 | Pending and claimed source-code findings |
| 29 | Document status and future specification work |

## Example and assumption register

These items require classification during their topic reviews and must not silently become permanent identifiers or supported-device limits:

- Personal names embedded in MQTT topic and entity examples.
- The initial four-daemon list and diagrams that omit BBT and future integrations.
- Device-specific entity, measurement, and dashboard examples.
- Exact route examples such as `/api/v1/` and `/api/v1/capabilities`.
- Exact MQTT namespaces, topic layouts, retained-message behavior, and publisher examples.
- A five-inch HDMI display, automatic rotation, USB keys, Samba, rclone, and Apprise examples.
- The assertion that every Hub component runs on one machine and the separate assertion that daemons remain independently installable.
- Exact administrator-role names, counts, and key-management examples.
- Claims labeled as confirmed from the source code at the time the preliminary document was written.

## Boundaries for the review

- Existing interface and report contracts are approved inputs, but they do not automatically decide unrelated system architecture.
- Branding documentation must not become the canonical home for MQTT, backup, operating-system, authentication, or administration architecture.
- The eventual consolidated specification should use purpose-based names and should not preserve tooling names as architecture categories.
- No source document is altered during inventory, reconciliation, verification, or drafting.
