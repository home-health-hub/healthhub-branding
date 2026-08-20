# Health Hub system architecture

**Status:** Consolidation draft; not yet canonical

**Review snapshot:** `home-health-hub/healthhub` commit `d38bef06a01aaaeb28b1b997b49bddf44403d07e`

**Decision record:** [`ARCHITECTURE_REVIEW_FINDINGS.md`](ARCHITECTURE_REVIEW_FINDINGS.md)

## 1. Purpose and authority

This specification defines the system boundaries, data authority, interfaces, security model, persistence, deployment, and integration rules for Health Hub and its supported health-device daemons. It is intended to replace overlapping architectural material only after project-owner approval. Until then, it is a review draft and does not supersede its source documents.

The words **must**, **must not**, **required**, **should**, and **may** describe normative strength. Requirement labels distinguish long-lived architecture from product and implementation choices:

- **Invariant:** a boundary that implementations must preserve.
- **Required capability:** behavior the integrated product must provide, although its implementation may vary.
- **Optional adapter:** an integration that is not required for core operation.
- **Implementation choice:** a current technical selection that may change without redefining the architecture.
- **Deferred investigation:** a question that must be resolved before implementing the affected behavior.

Each major section cites the approved architecture-review finding from which it was consolidated. Requirement-level source tracing is maintained in [`ARCHITECTURE_TRACEABILITY.md`](ARCHITECTURE_TRACEABILITY.md).

## 2. Product and deployment boundary

**Invariant.** Health Hub is a personal or household health-data appliance. It is not a hospital, clinic, enterprise, multi-station medical-record system, diagnostic system, or substitute for professional medical judgment. [AR-001, AR-009]

A normal integrated deployment runs one Hub and its configured daemons on one physical host or equivalent single-host environment. Components remain independent services connected through supported interfaces even when colocated. Distributed Hub nodes, multi-Hub coordination, remote daemon registration, and WAN-exposed daemon APIs are outside the current scope. [AR-001]

Every supported daemon must remain independently installable and usable without Health Hub for its core device synchronization, durable history, operational status, and report responsibilities. A standalone daemon does not depend on the Hub, Home Assistant, or another MQTT consumer. [AR-001, AR-002]

Displays, Home Assistant, scripts, and other external consumers are clients. They do not define the Hub-to-daemon architecture. Device and manufacturer names are examples of integrations, never a permanent allowlist. [AR-001, AR-007, AR-014]

## 3. Authority and component responsibilities

**Invariant.** The authority chain is:

`physical device -> device driver -> daemon -> supported API/event contract -> Hub presentation`

The daemon owns:

- device communication and synchronization;
- device-specific protocol interpretation and normalization;
- authoritative durable measurement history;
- source identifiers, provenance, corrections, and retention;
- daemon and device operational state;
- device-specific configuration and capabilities; and
- device-specific doctor-facing PDF generation.

The Hub owns:

- accounts, authentication, roles, permissions, and delegation;
- household people and mappings to daemon-supported identity models;
- browser presentation and cross-device navigation;
- user preferences, audit records, and integration configuration;
- authorized requests to daemon APIs;
- near-real-time event consumption and rebuildable projections; and
- clearly separate Hub-created summaries, if later approved.

Normalization, caching, aggregation, or presentation never transfers measurement authority to the Hub. A Hub projection must retain daemon and source-record identity and be rebuildable, or it must be explicitly classified and governed as non-rebuildable Hub data. The Hub must never directly open a daemon database. [AR-002, AR-004]

## 4. Identity and assignment

**Invariant.** Accounts, people, actors, health-data subjects, daemon profiles, physical devices, daemon instances, logical sources, transport identifiers, and source records are separate identity domains. Each domain uses stable opaque identifiers. Personal names are display labels and must not be used as durable database, API, MQTT-topic, or Home Assistant uniqueness keys. [AR-003]

The subject described by a reading is independent from the actor who took, entered, assigned, or corrected it. A device memory slot is not a Hub person. Device-level profile assignment is a capability reported by the daemon, not a universal rule. [AR-003, AR-014]

A valid reading may remain `Unassigned` when its subject is unknown, a prompt expires or is dismissed, or assignment would require guessing. Unassigned is a supported preservation state, not necessarily a deliberate choice of “nobody.” Until authorized assignment, the reading remains in daemon history but is excluded from person-specific charts, reports, and Home Assistant entities. Assignment and reassignment preserve actor, time, reason where required, and prior provenance. [AR-003]

## 5. Measurement record and provenance

**Invariant.** Daemons expose only timestamp semantics they can honestly support. A record distinguishes, where applicable:

- `taken_at`: device-originating or best-supported event time;
- `received_at`: time the daemon received or imported the record; and
- `entered_at`: time a person or system entered a manual observation.

Timestamp data includes its time zone or offset, precision, uncertainty, and source. Absence of a trustworthy device clock is recorded as a limitation; implementations must not fabricate precision. [AR-004]

Authoritative records preserve stable source-record identity, raw or source values where useful, normalized values, units, source device, daemon instance, acquisition method, quality state, and correction history. The daemon defines idempotent ingestion, duplicate detection, retention, and correction behavior for its protocol and advertises relevant capabilities. Corrections are append-only or otherwise auditable. [AR-004, AR-014]

Continuous or downloaded sessions remain distinct from point readings. Missing, stale, excluded, unassigned, and never-captured data are distinct states. [AR-009, AR-012]

## 6. REST API contract

**Invariant.** REST is the request/response channel for on-demand history, configuration, reports, assignment, manual entry where supported, and capability discovery. MQTT does not replace these operations. [AR-005, AR-006]

Hub and daemon APIs must provide:

- explicit versioning and compatibility policy;
- stable error semantics and bounded timeouts;
- pagination for potentially unbounded collections;
- authentication appropriate to the local trust boundary;
- least-privilege, individually revocable service or automation credentials; and
- a schema-versioned capability response containing no unapproved sensitive data.

“Public API” means supported and documented, not Internet-exposed or unauthenticated. Integrated deployments default to loopback-only access. Unix sockets may be selected but are not required over localhost HTTP. Daemon authentication remains separate from Hub user authorization. The Hub API enforces the same authorization as its browser UI. [AR-005]

### 6.1 OpenAPI

**Required capability.** Every Hub and daemon REST API provides an OpenAPI 3.1 contract. The source contract is checked into its repository, served at a stable endpoint such as `/api/v1/openapi.json`, and validated in CI against implemented routes. It describes request, response, error, authentication, pagination, report, and capability schemas without real health-data or credential examples. Runtime `/api/v1/capabilities` remains separate from this static interface description. [AR-005]

### 6.2 Optional history capability

A daemon advertising full-history browsing provides a read-only paginated endpoint such as `GET /api/v1/readings`. The contract defines deterministic ordering, filters, pagination, stable reading identity, subject-assignment state, timestamps, provenance, quality, and correction state as applicable. Page/per-page pagination is acceptable initially, but ordering must permit a later cursor-based contract. The Hub presents this history without duplicating the daemon's authoritative database. [AR-005]

### 6.3 Optional manual-entry capability

A daemon that owns manual observations may advertise an endpoint such as `POST /api/v1/manual-entry`. The Hub supplies the authorized form; the daemon validates and stores the authoritative record. An entry includes subject, authenticated actor, `taken_at`, `entered_at`, observation type, typed value and unit where applicable, provenance, and an extensible source classification. Values such as `device` and `manual` must not prevent later import sources. Corrections use an auditable daemon API. Daemons that do not own manual observations do not advertise this capability. [AR-005, AR-014]

## 7. MQTT event channel

**Invariant.** MQTT is a second channel used for near-real-time new-reading events and optional normalized consumers. Daemons publish after a durable insert. REST remains the recovery and query path. MQTT retained state is a projection, never authoritative history or proof of ingestion. [AR-001, AR-006]

Each daemon may publish only to its own approved namespace; the Hub may publish only to its namespace. Home Assistant, Node-RED, openHAB, scripts, and dashboards are subscribe-only unless a later architecture decision grants a specific publish contract. Broker per-client ACLs enforce these rules. MQTT command topics are reserved and must not be introduced by convention. [AR-006]

Events use stable opaque identifiers and include schema version, event or source-record ID, daemon/source identity, measurement time, publication time, and required provenance. Hub consumption is idempotent and defines duplicate, ordering, QoS, and retained-message behavior. Human-readable labels belong in payloads, not uniqueness-bearing topic segments. REST history is used to reconcile missed or uncertain delivery. [AR-006]

Authorized MQTT administration in the Web UI reports broker reachability, authenticated connection state, TLS state, ACL verification, last event received per daemon, duplicate or recovery counts, and retained-state health. Broker availability, daemon health, and measurement freshness remain distinct. Guided settings are limited to approved broker host, port, TLS, credential, and certificate-trust fields and follow the secret-management rules. Connection, authentication, publish ACL, subscribe ACL, and expected topic permissions are tested separately, including proof that each daemon and the Hub can publish only to its namespace and external clients remain subscribe-only. Topic or payload previews use synthetic data and opaque example IDs rather than actual people or readings. The UI exposes no general publish tool, arbitrary subscription, raw ACL editor, or broker console. Changes preview affected daemons and consumers, require recent reauthentication, and are audited. Failed changes preserve the last known-good configuration where possible. [AR-006; owner decision 2026-08-20]

## 8. Capability-driven integration

**Invariant.** Capability discovery is schema-versioned and additive. Consumers tolerate unknown capabilities. Logical source, physical device, daemon instance, and measurement capability remain distinct. [AR-014]

Profile models, device clocks, point versus session data, measurements, units, assignment, manual entry, history browsing, PDF generation, and notification support must be advertised rather than assumed. Replacing a physical device preserves the existing logical history and original device provenance. Hardware or protocol behavior is guaranteed only after verification for the relevant daemon and device combination. User-facing language remains manufacturer-neutral except where identifying the actual source device is useful. [AR-014]

Authorized daemon and device configuration in the Web UI is driven by versioned daemon capabilities and configuration schemas. The Hub presents current values, proposed changes, validation errors, and known restart or synchronization effects. The daemon remains responsible for validating and storing its configuration through its API; the Hub never edits daemon files or databases. Unsupported or newly discovered settings may be shown as read-only technical details until the Hub supports their schema. Redacted raw JSON may be displayed for diagnosis but cannot be edited or submitted. A change spanning independent daemons reports each daemon's result and must not claim cross-daemon atomicity. Configuration audit events identify changed fields and results without recording secret values. [AR-002, AR-005, AR-014; owner decision 2026-08-20]

## 9. Browser presentation and interaction

**Required capability.** The Hub owns browser presentation, including daemon-specific pages. A daemon identification image may visually identify the source page, but the Hub remains only the presentation layer and does not acquire daemon authority. [AR-002, AR-008]

The interface is responsive and usable with keyboard, mouse, tablet, touch monitor, and assistive technology. Exact display size, rotation hardware, night mode, and USB input devices are deployment options. Detailed accessibility, interaction, theme, language, status, chart-presentation, and daemon-identification requirements belong to [`INTERFACE_AND_REPORT_STANDARDS.md`](INTERFACE_AND_REPORT_STANDARDS.md), with implementation contracts in [`ADOPTION.md`](ADOPTION.md). [AR-008; approved interface standard]

The administration landing page defaults to a concise needs-attention view rather than dense telemetry. Within the viewer's capabilities, it summarizes service health, daemon reachability, last successful synchronization, backup status, audit integrity, Samba availability, MQTT status, Mailpit status, storage pressure, update availability, and unresolved administrative notices. It never displays measurement values, manual observations, free-text health notes, report previews, or health-condition summaries. It distinguishes unavailable, stale, unknown, degraded, and failed states and links each summary to an authorized detail page. Controls that the account cannot use are omitted; read-only state may remain when awareness is required, with an explanation of the missing capability. An optional all-systems view is available but is not the default. Background refresh must not move focus or repeatedly announce unchanged content to assistive technology. [AR-008, AR-009, AR-011; owner decision 2026-08-20]

### 9.1 Person confirmation

Two explicit workflows are supported:

1. **Station-assisted:** a separate Hub station display shows a short-lived code that the signed-in person enters on a phone, tablet, or computer. The code is not displayed and entered on the same device.
2. **Personal-device:** without a station display, the signed-in person explicitly selects and confirms the session or reading on a phone, tablet, or computer.

A permanent station display is optional overall but required when the station-assisted flow is enabled. Personal-device confirmation proves authenticated intent, not physical proximity. The system must not use biometrics or automatic presence detection to infer identity. [AR-008]

## 10. Charts, summaries, and notifications

**Invariant.** Charts and summaries are descriptive and non-diagnostic. They show units, time basis, missing periods, stale data, uncertainty, and provenance where relevant. Missing data must never be presented as a healthy or normal result. Continuous sessions remain distinguishable from point readings. [AR-009]

Goals are explicit personal annotations, not diagnoses or clinical targets. Default thresholds must not be presented as medical advice. Operational alerts remain separate from user-configured health-data notifications. Daemon and Hub ownership and deduplication must prevent conflicting duplicate alerts. Alert history, acknowledgment, authorization, and delivery failure remain durable independently of Apprise or another delivery provider. [AR-009]

The Hub notification center separates security, backup/recovery, service, device/synchronization, and external-delivery notices and scopes each notice to accounts with the required capability. A notice identifies severity, affected component, first and latest occurrence, current state, occurrence count, and available next action. Repeated occurrences are deduplicated without discarding their history. Acknowledgment means seen and is distinct from resolution; resolution follows verified system state rather than dismissal. Audit-integrity failures, required policy notices, and other explicitly non-dismissible security conditions remain visible until their defined resolution. Notification previews omit measurement values, manual observations, report contents, free-text health notes, credentials, and secrets. External delivery failure does not remove the durable in-Hub notice. The SHA-access disclosure remains versioned and is reissued after a material policy change. [AR-009, AR-011; owner decision 2026-08-20]

## 11. Reports and file access

**Invariant.** Each daemon exclusively generates its device-specific doctor-facing PDFs through its API and without requiring the Hub. The Hub authorizes, requests, displays, and downloads the daemon's exact bytes. It must not reconstruct, restyle, merge, annotate, or silently replace a daemon PDF. [AR-010]

The report API defines media type, filename, content disposition, authorization, durable job state, errors, integrity metadata, and bounded streaming or download behavior. Hub presentation identifies the generating daemon and selected parameters. Doctor-facing PDFs contain no decorative branding iconography. Any future Hub-created cross-device summary is a separate, clearly labeled, non-diagnostic artifact with its own provenance. Detailed report layout, typography, accessibility, browser presentation, job behavior, and byte-preservation requirements belong to [`INTERFACE_AND_REPORT_STANDARDS.md`](INTERFACE_AND_REPORT_STANDARDS.md) and [`ADOPTION.md`](ADOPTION.md). [AR-010]

**Required capability.** Integrated installations provide authorized report access through both the Hub Web UI and per-user Samba shares. Samba is a report-access channel, not a backup mechanism. Shares expose only authorized reports or exports containing exact daemon PDF bytes and required provenance metadata. They never expose databases, WAL files, daemon directories, configuration, credentials, keys, audit logs, or internal job storage. [AR-012]

## 12. Authorization, roles, and audit

**Invariant.** Health-data ownership and technical administration are separate. A person controls access to their health data by default and grants explicit, persisted, revocable delegation. Except for the approved SHA Samba rule below, a technical role does not automatically grant access to another person's health data. [AR-011]

The integrated product maintains one active primary Security/Health Administrator (SHA) and supports Hub Administrator, User Administrator, and System Recovery Administrator roles. Roles are capability-based, composable, non-exclusive, independently revocable, and audited. Effective technical permissions are the union of assigned roles. The SHA may assign multiple roles to one account and may hold additional roles. The UI warns when a combination reduces separation of duties without prohibiting it in a household system. SHA transfer is a distinct audited recovery operation. [AR-011]

Administrative role changes are performed individually rather than through bulk assignment. Before a grant or removal, the Web UI explains each role's capabilities in plain language, previews the target account's resulting effective permissions, warns about reduced separation of duties, and keeps the action distinct from health-data delegation. Granting or removing an administrative role requires recent reauthentication and an audit reason. The target account and current role state are revalidated when saving. Revocation takes effect immediately and terminates privileged sessions where necessary without removing unrelated roles or ordinary-user access. The sole active SHA cannot be removed through ordinary role editing; the separate SHA-transfer workflow must complete first. [AR-011; owner decision 2026-08-20]

Health-data delegation is controlled by the data owner and remains separate from administrative roles. The owner selects the recipient, applicable people or data categories, report access, optional expiration, and distinct permitted actions such as viewing, downloading reports, entering observations, assigning readings, or correcting records where supported. Redelegation is prohibited unless the owner explicitly grants it as a separate capability. Before granting or changing access, the UI previews exactly what becomes available and states that an already downloaded PDF cannot be recalled. Grant, change, expiration, suspension, and revocation are audited. Revocation blocks new requests immediately and terminates active privileged access where practical. Account disabling follows the defined delegation-suspension rules. An administrator cannot delegate on a person's behalf without a separately approved recovery or dependent-person policy. [AR-011; owner decision 2026-08-20]

The SHA has owner permissions on their own Samba share and read-only access to other users' shares. The SHA is also the host operating-system administrator and can ultimately access host-stored data outside application controls. The product must state this truth. Each user receives a one-time notification-center notice at initial login; the system persists the acknowledged notice version and notifies again after a material policy change. Other technical roles need explicit health-data delegation for another person's share. [AR-011, AR-012]

An assigned technical-support capability may grant the minimum diagnostic metadata needed to investigate system behavior without granting routine access to health content. Permitted fields are limited to such items as record counts, earliest and latest record times, assignment state, synchronization state, daemon/source identifiers, source-record identifiers, schema or format versions, and integrity or job status. Counts and dates may themselves reveal sensitive activity, so access is role-scoped, purpose-limited, and audited. This capability does not expose measurement values, manually entered observations, free-text notes, report contents, chart contents, or unrestricted person-level history. It is not automatically included in every administrator role and does not replace explicit health-data delegation. [AR-011; owner decision 2026-08-20]

High-risk Web UI actions require recent reauthentication even when the current session has the necessary capability. These include SHA transfer, credential revocation, restore, encryption-key or recovery-material changes, Samba-access policy changes, and disabling a person's account. Before execution, the confirmation view identifies the exact action, affected people and components, expected service interruption, possible data or access unavailability, available recovery path, and the audit reason. Require a typed confirmation phrase only for destructive or difficult-to-reverse operations; routine administration uses an accessible ordinary confirmation. Authorization and consequences are revalidated at execution time so an expired role, changed target, or stale preview cannot authorize the operation. [AR-011, AR-012; owner decision 2026-08-20]

Existing passwords, tokens, encryption keys, OAuth refresh tokens, and recovery secrets are never displayed after creation. The Web UI may show only non-secret metadata such as credential type, owner, scope, creation time, last use, expiration, and a short non-secret fingerprint. A newly generated secret is shown once, with explicit confirmation that the administrator stored it. Copy or download of newly issued secret or recovery material requires recent reauthentication and is audited. Secret inputs are kept out of URLs, logs, notices, exports, and diagnostic JSON, and disable inappropriate browser autofill. Connection tests return redacted results and never echo credentials. Rotation creates and verifies a replacement before revoking the previous credential, with bounded overlap only where supported; revocation previews affected services and integrations. Recovery material uses a guided offline-storage and verification flow. [AR-005, AR-011, AR-012; owner decision 2026-08-20]

Disabling an account is an access-suspension operation, not deletion of the person or their health history. It revokes active sessions and account-owned automation credentials and prevents new login while preserving the person, daemon mappings, measurements, reports, assignments, and audit history. Delegations granted to the disabled account become inactive. Delegations previously granted by that person are preserved but suspended pending explicit authorized review, so disabling cannot silently continue or permanently erase delegated access. The only active SHA account cannot be disabled until an audited SHA transfer succeeds. The confirmation view previews these effects, and re-enabling an account does not silently reactivate suspended delegations without review. [AR-011; owner decision 2026-08-20]

Audit history records actor, action, target, time, result, and relevant reason. It is append-only or tamper-evident and cannot be edited or deleted by ordinary administrators. Recovery authority must not silently grant routine health-data access. [AR-011]

The Web UI presents audit events as read-only records searchable by time, actor, action, target type, and result. The SHA may view the full audit trail; another administrator sees only events within that account's assigned capabilities. Audit payloads must not contain measurement values, manual observations, report contents, free-text health notes, credentials, tokens, encryption keys, or other secrets. Authorized export provides schema-versioned structured JSON and human-readable CSV with stable event identifiers. Export requires recent reauthentication and creates its own audit event. The UI distinguishes no matching events from unavailable, delayed, incomplete, or integrity-failed audit data. An audit-integrity failure is a persistent security condition and cannot be dismissed as an ordinary notification. [AR-011; owner decision 2026-08-20]

Operational logs are distinct from the security audit trail. Each component owns logs needed for service health, synchronization, API, report-job, and integration diagnosis. Ordinary operational logs must avoid measurement values, report contents, credentials, tokens, encryption keys, and other unnecessary health or security data. Access to sensitive diagnostic detail is authorized and audited; log rotation or deletion must not erase the separately protected audit history. [Preliminary §24; AR-011]

**Deferred investigation.** Emergency access, minors and dependents, incapacity, default or maximum delegation-expiration policy, account deletion, recovery succession, and audit retention require approved policies before implementation. [AR-011]

## 13. Persistence, backup, and restore

**Implementation choice.** Every Hub and daemon database uses SQLite, SQLAlchemy 2.0 style, and its component's own Alembic migration history. There is no shared cross-daemon database. A component never opens, writes, or migrates another component's database. [AR-013]

**Required capability.** Backup uses a manifest-based component contract with SQLite online-backup or another WAL-aware snapshot procedure. It includes required configuration, report metadata, audit data, schema and version metadata, integrity checks, documented restore order, partial-failure handling, protected key-recovery material, and tested restoration. Credentials and encryption keys are not exposed through ordinary shares. Restoring data does not change daemon authority. [AR-012]

User-facing recovery status distinguishes data never captured, not yet synchronized, intentionally excluded, and lost after capture. A local backup alone does not protect against disk failure, theft, or fire. Rclone, removable media, and other backup transports are optional adapters. [AR-012]

**Required capability.** The Hub provides ordinary backup status and guided configuration plus an Advanced Backup Configuration area for authorized backup/recovery administrators. It covers destinations, schedules, retention, encryption state and recovery readiness, included components, integrity verification, restore testing, failure notification, retry policy, destination health, and transport-specific settings. Consequential changes require reauthentication, a clear impact summary, validation or destination testing, and an audit event. Retention changes describe future deletion effects without immediately deleting existing backups. Restore is a separate guided workflow. The Hub coordinates these operations through supported backup-service interfaces and never exposes arbitrary host paths, shell commands, or raw tool configuration. [AR-012; owner decision 2026-08-20]

The optional rclone adapter exposes advanced capability through task-oriented, schema-defined controls rather than CLI knowledge. Supported providers supply guided connection and OAuth fields where applicable, destination selection, bandwidth and schedule controls, guarded concurrency, retry and timeout settings, checksum or post-transfer verification, guided encryption, retention policy, approved-category exclusions, a dry-run preview, and a connection test. Additional supported options declare a human name, explanation, control type, allowed values, default, warnings, reauthentication needs, and effects on existing backups. The service translates validated settings into an argument array or native configuration without constructing a shell command from browser text. The Web UI does not accept arbitrary rclone flags or raw configuration. Any expert escape hatch remains a host-side SHA operation outside the browser UI. [AR-012; owner decision 2026-08-20]

The administration UI reports total, used, reserved, and available storage and attributes usage to the Hub, each daemon, reports, backups, operational logs, and temporary jobs where component APIs can do so. Estimated and exact usage are labeled distinctly. Configurable safe thresholds warn about storage pressure without claiming data loss unless loss is confirmed. The UI never provides a general filesystem browser. Cleanup operations are fixed and owned by the applicable component, such as expired temporary jobs, rotated operational logs, or superseded report copies where an approved policy permits removal; the Hub never deletes daemon readings directly. Before cleanup, the UI previews estimated reclaimed space and affected artifact counts and requires a current verified backup when the operation could remove the only retained copy. Retention changes govern future eligibility and do not immediately erase existing material. Multi-component cleanup reports exact partial results and is audited. Filesystem paths, filenames, and diagnostic details are disclosed only when required and authorized. [AR-002, AR-004, AR-012; owner decision 2026-08-20]

## 14. Services, packaging, and updates

**Implementation choice.** The Hub and daemons run as independent, least-privilege native systemd services. Exact supported Ubuntu versions, paths, unit names, Python environment tools, and package commands are implementation details documented by their owning repositories. Users and administrators do not manually alter managed Python environments. [AR-013]

Upgrades require compatibility checks, a safe pre-migration backup, controlled component-owned migrations, post-upgrade health checks, and documented recovery. The Hub may display update availability but does not perform host or component updates. Service and update management remain under SHA or host-administrator control. [AR-013]

The Web UI reports software-update information and readiness but never installs packages, runs update migrations, restarts components for an update, or updates the host. For the Hub, each daemon, deployed branding, and approved supporting infrastructure, it may show installed and available versions, release channel, compatibility state, release notes, security-fix status, backup readiness, expected interruption, migration expectations, and incompatible components. States distinguish checking, update available, compatibility unknown, blocked, and check failed. Update metadata refresh uses trusted signed sources and discloses no household, person, device, or health information. The browser cannot add arbitrary repositories, package names, channels, URLs, or commands. Installation remains a documented host-side SHA operation. After installation, the UI reports version consistency, migration outcome, component health, and recovery guidance and does not infer success from a changed version string alone. [AR-013; owner decision 2026-08-20]

The Web UI may expose only fixed, capability-scoped service operations. A Hub Administrator may view approved service status and request safe application-level actions such as synchronization or capability refresh. A System Recovery Administrator may request restart of an explicitly allowlisted Hub, daemon, MQTT, Mailpit, Samba, or backup service through a narrowly privileged service-management interface. The browser never supplies a service or unit name, command, argument, or arbitrary `systemctl` operation. Stop, disable, mask, package installation, software update, and host reboot remain host-side SHA operations. Before restart, the UI identifies affected functions and requires confirmation; it records the request and result in the audit trail. Restart attempts are rate-limited, and a restart loop is surfaced as a failure rather than retried indefinitely. [AR-011, AR-013; owner decision 2026-08-20]

Removing Docker images, packages, tags, and badges from Hub and daemon repositories means those applications are not distributed as containers. It does not remove Docker Engine from the appliance or ban containers as an infrastructure boundary. Approved supporting services, including the MQTT broker and Mailpit, may require and run through Docker while the Hub and daemons remain native systemd services. [AR-013]

## 15. Optional adapters

Home Assistant support is an optional adapter over the generic normalized MQTT contract. It is not a Hub or daemon dependency. Discovery uses stable opaque unique IDs and device identifiers, advertises only supported capabilities, reconciles after Home Assistant birth and configuration change, and clears obsolete retained discovery. Availability, state retention, expiry, and measurement freshness remain separate concepts. Per-sample continuous-session entities are not created; useful session summaries may be exposed. The official Home Assistant contract must be reverified when the adapter is implemented or upgraded. [AR-007]

Other subscribe-only consumers may use the generic MQTT contract without Home Assistant discovery. Backup transports and optional local display hardware are adapters or deployment options, not core authorities. [AR-001, AR-006, AR-008, AR-012]

## 16. Release and change control

Release planning must classify retained work as an invariant, required capability, optional adapter, implementation choice, or deferred investigation. A historical “initial release” list does not automatically define a new release. Plans are derived from approved decisions and verified current behavior. [AR-015]

Interface, API, event, capability, database, backup, and report changes define compatibility and deprecation behavior appropriate to their boundary. Implementation observations are not architecture unless adopted through review. Device behavior is not guaranteed solely because an earlier document or code snapshot reported it. [AR-005, AR-014, AR-015]

## 17. Focused document ownership

This specification owns system-wide authority and trust boundaries. Specialized material stays with the document or machine-readable contract that has the clearest maintainer:

| Material | Owning document or contract |
|---|---|
| Branding assets, visual semantics, accessibility presentation, themes, chart styling, and PDF layout | [`INTERFACE_AND_REPORT_STANDARDS.md`](INTERFACE_AND_REPORT_STANDARDS.md) |
| Concrete adoption behavior, UI edge cases, report jobs, and exact-byte PDF transport | [`ADOPTION.md`](ADOPTION.md) |
| REST paths, fields, schemas, errors, and authentication declarations | Each component's checked-in OpenAPI 3.1 contract |
| Runtime-supported functions and device behavior | Each daemon's versioned capability response |
| MQTT topics, payload schemas, delivery, retention, and ACL conformance | A future focused MQTT interface contract derived from section 7 |
| Backup manifests, snapshot procedures, restore ordering, and integrity verification | A future focused backup and restore contract derived from section 13 |
| Home Assistant discovery payloads and lifecycle details | A future adapter contract derived from section 15 and reverified against official documentation |
| Release contents and scheduling | A separately approved release plan |

Do not create a focused document merely to shorten this specification. Create one when the material has an independent compatibility surface, test suite, release cadence, or maintainer. Until a listed future contract exists, the applicable requirements in this specification remain controlling draft material and must not be treated as waived.

## 18. Adoption conditions

This draft becomes canonical only after all of the following:

1. every retained requirement remains traced in [`ARCHITECTURE_TRACEABILITY.md`](ARCHITECTURE_TRACEABILITY.md) to a protected source section, approved review decision, or approved focused standard;
2. the draft remains checked against all protected source sections and the completed interface/report contracts, with results recorded in [`ARCHITECTURE_CONSOLIDATION_CHECK.md`](ARCHITECTURE_CONSOLIDATION_CHECK.md);
3. specialized material is moved to focused contracts where that gives it a clearer owner;
4. the project owner and Claude Code review the consolidated result;
5. the project owner explicitly approves adoption; and
6. the protected source documents are separately designated as historical, converted to pointers, or archived.

Until those conditions are met, [`ARCHITECTURE_REVIEW_FINDINGS.md`](ARCHITECTURE_REVIEW_FINDINGS.md) remains the decision record and the protected documents remain unchanged.
