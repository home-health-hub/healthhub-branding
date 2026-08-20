# Health Hub architecture review findings

This document records evidence, proposed dispositions, and the project owner's approved architecture decisions from the read-only review. A proposal is not an approved architecture decision until the project owner accepts it. Approved dispositions are inputs to the future consolidated architecture specification. Rejected assumptions and unresolved implementation questions remain in the review result or approved disposition rather than being silently discarded. The protected Health Hub source documents remain unchanged.

## Finding statuses

- **Awaiting owner decision** — evidence and a proposal are ready, but no resolution is approved.
- **Approved** — the project owner accepted the stated resolution.
- **Needs verification** — current code, hardware, protocol, or primary external documentation must be checked first.
- **Unresolved** — evidence is incomplete or competing requirements remain.

## AR-001: System scope and single-appliance assumptions

**Status:** Approved 2026-08-20
**Classifications:** Consistent, Duplicate, Stale, Unverified, Outside scope

### Source evidence

- `Claude-foundation.md` sections 1–5 and 50 describe a unified Hub over independent daemons. They say components normally run on the same physical machine, daemon APIs remain the boundary, and daemons remain usable without the Hub.
- `Preliminary.md` sections 1–4 describe a personal or household appliance rather than a hospital, clinic, enterprise, or multi-station system. It says all Health Hub components are installed on the same physical machine while standalone daemons remain independently installable and useful.
- `Preliminary.md` section 27 repeats the single-household, normally-one-machine, independent-service, daemon-authority, and API-boundary constraints.
- `Claude-Addendum-HA.md` sections 1, 18, and 20 treat Home Assistant as an optional consumer and prohibit it from becoming a Hub or daemon dependency.
- Current interface/report contracts agree that Health Hub owns browser presentation while daemons remain independent authorities for their data, synchronization state, and PDFs.

### Consistent core

- The product is designed first for an individual or household.
- A normal integrated Health Hub deployment is one local appliance rather than a distributed clinical system.
- Health Hub and its supported daemons remain separate services with API boundaries even when colocated.
- A daemon can be installed and used without Health Hub.
- Optional integrations and displays are consumers and do not define the core system.

### Ambiguities and stale examples

- “All components are installed on the same physical machine” can be misread as prohibiting standalone daemon-only installations. The surrounding text indicates it describes an integrated Hub deployment, not every valid daemon deployment.
- “Not required” for remote discovery, registration, and WAN-facing daemon APIs does not necessarily mean “permanently forbidden.” The documents place them outside current scope.
- The four named daemon integrations and their diagrams are an initial set, not an architectural allowlist. They omit the later BBT work and any future supported manufacturer or device.
- A local Unix socket and localhost HTTP are examples of acceptable transports; selecting one requires an implementation decision.
- The detailed household-administration, host, and deployment model is outside branding scope and ultimately belongs in the consolidated Health Hub architecture specification.
- `Claude-foundation.md` section 25 and `Preliminary.md` section 10 explicitly revise an earlier external-consumer-only position: the Hub subscribes to each daemon's MQTT feed for near-real-time new-reading delivery rather than polling or adding webhooks. They reserve REST for on-demand queries, configuration, reports, assignment, and capability discovery. They do not describe MQTT commands or a broader general-purpose coordination protocol.

### Approved resolution

Define the deployment boundary as follows:

1. Health Hub is a personal or household health-data appliance, not a hospital, clinic, enterprise, or multi-station medical-record system.
2. A normal integrated deployment runs one Hub and its configured daemon services on one physical machine or equivalent single-host environment.
3. Supported daemons remain independently installable and usable without Health Hub; “single appliance” constrains the Hub deployment, not standalone daemon use.
4. The reviewed sources already assign MQTT the daemon-to-Hub near-real-time new-reading push role in an integrated deployment, with the Hub subscribing to daemon-owned raw topics.
5. The reviewed sources assign on-demand queries, configuration, reports, profile assignment, and capability discovery to daemon REST APIs. Whether MQTT should now become a broader coordination backbone is a separate decision for the detailed MQTT review.
6. A standalone daemon remains functional for its core synchronization, durable data, operational status, and PDF responsibilities without Health Hub. Its standalone requirements do not depend on Home Assistant or another external MQTT consumer.
7. Local-only API transports are preferred for the integrated deployment, but the architecture does not hardcode Unix sockets versus localhost HTTP.
8. Distributed Hub nodes, remote daemon registration, multi-Hub coordination, and WAN-exposed daemon APIs are outside current scope rather than declared impossible forever.
9. Device and daemon names in the source documents are examples of the initial integration set. New devices and manufacturers fit the same authority, MQTT, and API boundaries without changing the system architecture.
10. Optional displays, Home Assistant, scripts, and other external MQTT consumers remain optional clients. They consume the Hub's interfaces but do not define the Hub-to-daemon coordination model.

### Destination

The eventual consolidated Health Hub architecture specification. The branding repository should retain only the browser-presentation, daemon-authority, identification, and report boundaries that directly govern branding/interface adoption.

## AR-002: Hub, daemon, driver, and device authority

**Status:** Approved 2026-08-20
**Classifications:** Consistent, Duplicate, Outside scope

### Review result

All three sources preserve the same core boundary: a physical device is accessed through its driver and daemon; the daemon owns synchronization, device-specific interpretation, durable measurements, operational status, and reports; the Hub consumes supported daemon interfaces and owns household organization, authorization, cross-device presentation, and browser interaction. Home Assistant and other integrations remain consumers.

The phrase “Hub data store” must not imply that copied or normalized measurements become a second authority. Hub-owned data may include accounts, permissions, preferences, audit records, integration configuration, cached projections, and references to daemon records. A cache must retain source identity and be rebuildable or explicitly classified if it is not.

### Approved disposition

Adopt the authority chain `physical device -> driver -> daemon -> supported API/event contract -> Hub presentation`. State explicitly that normalization, caching, and aggregation do not transfer measurement authority. Keep daemon configuration and device-specific behavior in the daemon. Put the complete rule in the consolidated architecture; retain its presentation consequences in the interface/report standards.

## AR-003: Person, account, actor, profile, device, and source identity

**Status:** Approved 2026-08-20
**Classifications:** Conflict, Stale, Unverified

### Source evidence and conflict

The Foundation and HA addendum often model one physical device as assigned to one profile at a time and preserve a logical person across device replacement. Preliminary later reports differing real daemon models: some readings are unassigned until an explicit assignment, while one O2Ring daemon instance represents one configured wearer. The current interface contracts also separate the person described by a record from the actor entering or changing it.

Those models cannot be collapsed into one universal `device -> profile` rule. A shared thermometer, scale, cuff, or manual entry may require per-record subject selection. Device memory slots are not Hub people. Accounts, people, profiles, actors, devices, daemon instances, transport identifiers, and source records are distinct identities even when a simple installation maps some one-to-one.

### Approved disposition

Use stable opaque IDs for every identity domain. Model the subject of each measurement independently from the actor and source device. Treat device-level profile assignment as a daemon-reported capability, not a universal invariant. Preserve reassignment history and actor audit data rather than rewriting provenance. Personal names in examples are display labels only and must never form stable identifiers or MQTT uniqueness keys. Preserve a valid reading as `Unassigned` when its subject is unknown, a prompt expires or is dismissed, or assignment would require guessing. This is a supported preservation state, not necessarily an explicit choice of “nobody.” Until assignment, exclude it from person-specific charts, reports, and Home Assistant entities while retaining its daemon source, timestamps, and later authorized assignment path.

## AR-004: Measurement ownership, provenance, timestamps, correction, and retention

**Status:** Approved 2026-08-20
**Classifications:** Consistent, Stale, Unverified

### Review result

The sources consistently separate a device-originating measurement time from daemon receipt or download time where hardware permits, and consistently leave long-term device data with the daemon. Preliminary correctly notes that some hardware supplies no trustworthy device clock.

The older two-timestamp model is incomplete for manual entry and later correction. The current contract additionally needs `taken_at` (or the best source event time), `received_at`, and `entered_at`, with time zone/offset, precision, uncertainty, provenance, source-record identity, and correction history where applicable. A missing device time is a known limitation, not permission to fabricate one. Duplicate import and clock correction policies are not defined in the sources.

### Approved disposition

Require daemons to expose the timestamp semantics and provenance they can actually support. Preserve raw/source values and identifiers alongside normalized display values. Keep corrections append-only or otherwise auditable. Define deduplication and retention per daemon, while the Hub treats projections as non-authoritative. Verify actual schemas, pruning, and correction behavior before fixing a universal data contract.

## AR-005: REST APIs, versioning, authentication, and local transport

**Status:** Approved 2026-08-20
**Classifications:** Consistent, Unverified, Stale

### Review result

The documents agree that REST remains the supported mechanism for on-demand queries, configuration, reports, assignment, and capability discovery. The Hub API must enforce the same authorization as its UI, while daemon APIs remain usable without the Hub. Localhost HTTP and Unix sockets are examples, not settled transport requirements.

Claims that every daemon currently uses `aiohttp`, `/api/v1`, an unauthenticated `/health`-like capabilities endpoint, and optional shared bearer authentication are dated implementation claims. “Public/user-accessible API” means supported and documented; it must not be read as unauthenticated or exposed beyond the local trust boundary. An unauthenticated capabilities response also needs a defined non-sensitive field set.

### Approved disposition

Standardize behavior and versioning before standardizing framework or transport. Require least-privilege Hub credentials, bounded timeouts, stable error semantics, pagination where needed, and explicit capability-schema versioning. Keep daemon authentication distinct from Hub user authorization. “Public API” means supported and documented, not publicly exposed or unauthenticated. Integrated deployments default to loopback-only access without requiring Unix sockets over localhost HTTP. The Hub API enforces the same authorization as the browser UI; automation credentials are individually scoped and revocable. Unauthenticated health/capability responses expose only explicitly approved non-sensitive fields.

Every Hub and daemon REST API must provide an OpenAPI 3.1 contract. Keep the source document checked in, serve it at a stable endpoint such as `/api/v1/openapi.json`, and validate in CI that it is syntactically valid and matches implemented routes. Document request/response/error schemas, authentication, report downloads, pagination, and capability responses without real health-data or credential examples. OpenAPI describes the static HTTP contract; `/api/v1/capabilities` remains a separate runtime/configuration description for the daemon instance. Define API, OpenAPI, and capability-schema compatibility and deprecation rules.

Daemons that support full-history browsing advertise an optional readings-history capability and provide a read-only paginated endpoint such as `GET /api/v1/readings`. Its contract defines stable ordering, pagination and filters, and returns stable reading identity, subject assignment state, measurement times, provenance, quality state, and correction state as applicable. Page/per-page pagination is acceptable initially; implementations should avoid an ordering contract that prevents later cursor pagination. The Hub uses this API to present daemon history and does not duplicate the daemon's authoritative database.

Daemons that own manual observations advertise an optional manual-entry capability and provide an endpoint such as `POST /api/v1/manual-entry`. This supports BBT-related observations such as cervical mucus, ovulation-predictor results, and notes without making those fields universal to every daemon. The Hub supplies the authorized form, while the daemon validates and writes the authoritative record. Entries include the subject, authenticated actor, `taken_at`, `entered_at`, observation type, typed value and unit where applicable, provenance, and a defined source classification. The source vocabulary must be extensible beyond `device` and `manual` so later imports do not require redefining existing meanings. Corrections use an auditable daemon API rather than direct Hub database access.

Both optional endpoints and their schemas must appear in the daemon's OpenAPI contract when implemented and in `/api/v1/capabilities` when enabled. A daemon that does not own either workflow does not advertise or implement it.

## AR-006: MQTT coordination, state, topics, and publisher authority

**Status:** Approved 2026-08-20
**Classifications:** Consistent, Duplicate, Unverified

### Review result

Foundation section 25, Preliminary sections 10/27/28, and the supplied Claude Code handoff agree: MQTT is a second channel, not a REST replacement. Daemons publish new-reading events through their existing off-by-default feature; the Hub subscribes for near-real-time intake. REST handles queries, configuration, reports, profile assignment, and capabilities. Daemons may publish only their own topics, the Hub only its own topics, and every other client is subscribe-only through broker ACLs.

The sources do not approve MQTT command topics. Their topic names, personal-name segments, JSON shapes, QoS, retained flags, event identity, replay behavior, ordering, duplicate handling, session payloads, and deletion/correction events remain examples or omissions. Retained current state is useful for consumers but cannot replace daemon SQLite history or prove that an event was ingested.

### Approved disposition

Preserve the REST/event split. Define a machine-stable topic namespace using opaque profile/source IDs and human-readable labels only in payloads. Require event IDs or source-record IDs, schema versions, event time plus publication time, idempotent Hub ingestion, explicit QoS/retain rules, and broker-enforced ACL tests. Reserve command/control unless separately approved. Treat retained messages as current-state projections, never authoritative history.

## AR-007: Home Assistant discovery and independence

**Status:** Approved 2026-08-20
**Classifications:** Consistent, Duplicate, Unverified

### Review result

The HA addendum largely duplicates Foundation sections 30–39. Both correctly make Home Assistant optional, generate discovery from actual capabilities, preserve stable logical identity across device replacement where appropriate, and separate Hub/device availability from measurement freshness.

Current official Home Assistant documentation confirms component discovery, stable `unique_id`, device-registry grouping, availability topics, configuration updates, and removal through empty discovery payloads. It accepts retained discovery but prefers republishing after the Home Assistant birth message. Its MQTT Sensor documentation warns against retaining sensor state when using `expire_after`, because a stale replay can make an expired sensor appear available again. Per-sample O2Ring entities remain explicitly rejected; useful summaries are acceptable.

### Approved disposition

Keep a generic normalized MQTT contract independent of Home Assistant and implement discovery as an adapter. Use stable opaque unique IDs and device identifiers, publish only capability-supported entities, reconcile after Home Assistant birth and configuration changes, and clear obsolete retained discovery. Keep state retention, expiry, availability, and freshness separate. Reverify the official contract when the adapter is implemented or upgraded.

## AR-008: Browser UI, dashboards, displays, sessions, and input

**Status:** Approved 2026-08-20
**Classifications:** Consistent, Conflict, Stale

### Review result

Preliminary calls the Web UI primary, while Foundation contains numerous five-inch HDMI, rotation, and night-mode examples. These are compatible if a small local display is one responsive browser client, not a separate UI authority. Current approved interface work broadens this to keyboard, mouse, tablet, and other touch displays with appropriate alternative text and screen-reader support.

Preliminary also says the station has a physical screen for confirmation codes. That is a stronger deployment requirement than merely supporting an optional display and could prevent headless or browser-only deployments. Explicit session initiation is consistent; presence or biometric identity detection is rejected. USB keys are optional examples.

### Approved disposition

Keep all browser presentation in the Hub and require responsive, keyboard-, mouse-, touch-, and assistive-technology-friendly interaction. Treat exact display size, rotation hardware, night mode, and USB keys as deployment options. Daemons remain independently usable without the Hub browser interface. Never use biometrics or automatic presence detection to infer who is taking a reading.

Support two explicit person-confirmation workflows:

1. **Station-assisted confirmation:** A separate Hub station display presents a short-lived code, and the signed-in person enters it on their phone, tablet, or computer. The code must not be displayed and entered on the same device.
2. **Personal-device confirmation:** Without a station display, the signed-in person explicitly selects and confirms the session or reading from their phone, tablet, or computer.

A permanently attached station display is optional for Health Hub overall but required when station-assisted confirmation is enabled. Personal-device confirmation establishes authenticated user intent but does not independently prove physical proximity.

## AR-009: Charts, summaries, notifications, goals, and diagnostic restraint

**Status:** Approved 2026-08-20
**Classifications:** Consistent, Unverified

### Review result

The sources consistently limit the Hub to descriptive current/recent views, trends, summaries, and changes over time. They reject diagnosis and clinical interpretation. Device-specific continuous sessions remain distinct from point readings.

Preliminary assigns the Hub a substantial alert engine while daemons already provide Apprise-based device notifications. Ownership, deduplication across daemon and Hub alerts, threshold provenance, escalation, acknowledgment, and missing-data behavior are not defined. User goals and optional thresholds can easily appear clinical if language and defaults are careless.

### Approved disposition

Keep graphs and summaries descriptive and non-diagnostic. Show units, time basis, missing periods, stale data, uncertainty, and provenance where relevant; never treat missing data as a healthy or normal result. Keep device-specific sessions distinct from point measurements. Separate operational alerts from user-configured health-data notifications. Do not present default thresholds as medical advice, and treat goals as explicit personal annotations rather than diagnoses or clinical targets. Define daemon/Hub ownership and deduplication so one condition does not produce conflicting duplicate alerts. Retain alert history, acknowledgment, permissions, and delivery-failure state independently from Apprise or another delivery provider.

## AR-010: Daemon-owned PDFs and Hub coordination

**Status:** Approved 2026-08-20
**Classifications:** Consistent, Duplicate

### Review result

Foundation, Preliminary, and the approved report contract agree that daemons arbitrate device-specific doctor-facing PDF generation. The Hub requests, displays, and downloads the exact daemon-produced bytes for an authorized person; it must not silently reconstruct, restyle, merge, or become the authority for those reports. A daemon must still generate PDFs through its API without the Hub.

Preliminary permits Hub-created cross-device summaries. These must be clearly different artifacts and must not be presented as daemon clinical reports. The approved branding direction excludes decorative iconography from doctor-facing PDFs.

### Approved disposition

Each daemon exclusively generates its device-specific doctor-facing PDFs and must do so through its API without requiring the Hub. The Hub requests, authorizes, displays, and downloads the daemon's exact PDF bytes; it does not reconstruct, restyle, merge, annotate, or silently replace them. Define media type, filename, content disposition, authorization, durable job status, errors, integrity metadata, and bounded streaming/download behavior at the report API boundary. Identify the generating daemon and selected parameters in Hub presentation. Doctor-facing PDFs contain no decorative branding iconography. Any future Hub-created cross-device summary is a separate, clearly labeled, non-diagnostic artifact with its own provenance and is never presented as a daemon report.

## AR-011: Roles, permissions, delegation, recovery, and audit

**Status:** Approved 2026-08-20
**Classifications:** Conflict, Unverified, Outside scope

### Review result

Preliminary alone specifies exactly one Security/Health Administrator, separate Hub, User, and System Recovery Administrators, key rules, and no two-person approval. These are consequential security choices rather than examples, but they are not corroborated by the other sources or a threat model. The role names also risk conflating technical authority with access to another person's health data, which Preliminary itself says must remain separate.

The audit principles are sound: record actor, action, time, result, security-sensitive changes, and protect audit history from ordinary administrators. The documents do not settle emergency access, minors/dependents, incapacity, account deletion, delegation expiry, recovery without health-data disclosure, or audit retention.

### Approved disposition

Define permissions as capabilities and keep actor, subject, technical administration, health-data delegation, and recovery authority orthogonal. Every person owns access to their health data by default and grants explicit, revocable, persisted delegation. Maintain one active primary Security/Health Administrator (SHA), plus Hub Administrator, User Administrator, and System Recovery Administrator roles with their documented scopes. Administrative roles are composable and non-exclusive: the SHA may assign one account to multiple roles, the SHA may also hold other roles, and every assignment is independently revocable and audited. Effective technical permissions are the union of assigned roles. Except for the explicitly documented SHA access to all Samba report shares, no technical role automatically grants another person's health-data access. The SHA has read-only Samba access to shares belonging to other users and normal owner permissions on the SHA's own share. The SHA is also the host operating-system administrator and can ultimately access host-stored data outside application controls; the product must not imply otherwise. On initial login, each user receives a one-time notification-center notice describing this access. Persist the acknowledged notice version and notify again after a material policy change. Warn when combined roles reduce separation of duties without prohibiting the combination in a household system. Disabling or revoking one administrative role does not remove other roles, normal-user access, or health data. SHA transfer is a separate audited security/recovery operation.

Require append-only or tamper-evident audit behavior recording actor, action, target, time, result, and relevant reason. Ordinary administrators cannot edit or delete audit history. Recovery authority must not silently grant routine health-data access. Define emergency access, minors/dependents, incapacity, delegation expiry, account deletion, recovery succession, and audit retention before implementation.

## AR-012: Backup, restore, unrecoverable data, Samba, and filesystems

**Status:** Approved 2026-08-20
**Classifications:** Conflict, Unverified, Outside scope

### Review result

This material appears mainly in Preliminary. Local backup as a default and clear warnings about disk/theft/fire risk are reasonable. However, saying Samba provides convenient authorized access can be read as mandatory even though direct filesystem exposure expands the health-data attack surface and bypasses application-level authorization unless carefully designed.

A consistent backup cannot be assumed from independent live SQLite files. The sources do not fully define database snapshots, encryption keys, credentials, report files, audit logs, integrity verification, restore ordering, schema compatibility, or partial-daemon failure. “Unrecoverable” must distinguish data never captured from data lost after capture.

### Approved disposition

Make backup capability mandatory. Define a manifest-based component backup contract using safe SQLite online-backup or other WAL-aware snapshot procedures, encrypted secrets handling, integrity checks, schema/version metadata, documented restore order, partial-failure handling, and tested restore. Include required configuration, report metadata, audit data, and protected key-recovery material without exposing credentials or encryption keys through ordinary shares. Preserve daemon authority after restoration. Distinguish data never captured, not yet synchronized, intentionally excluded, and lost after capture. Clearly state that a local backup alone does not protect against disk failure, theft, or fire. Rclone, removable storage, and other backup transports remain optional.

Samba is a required user report-access channel in an integrated Health Hub installation, separate from backup. Users can access their authorized PDFs through both the Hub Web UI and per-user Samba shares. Shares expose only authorized report/export areas containing the daemon's exact PDF bytes and required source/provenance metadata; they never expose SQLite/WAL files, raw daemon directories, configuration, credentials, keys, audit logs, or internal job storage. Apply health-data delegation consistently across Web UI and Samba. The SHA has read-only access to every other user's Samba share and owner access to the SHA's own share. Other technical roles require explicit user delegation. Manage authentication, ownership, revocation, and best-available access logging through the Hub while acknowledging that the SHA, as host OS administrator, can access host-stored data outside Samba controls.

## AR-013: Installation, services, host OS, Python environments, and updates

**Status:** Approved 2026-08-20
**Classifications:** Consistent, Stale, Unverified, Outside scope

### Review result

Independent systemd services and daemon independence are compatible with the single-host appliance model. Exact Debian/Ubuntu versions, paths, service names, Python tooling, and virtual-environment commands are implementation and packaging choices, not enduring architecture. The Web UI may report update availability while CLI tooling performs updates; that policy is distinct from whether future safe update automation is ever allowed.

The persistence standard now selected for project databases is SQLite with SQLAlchemy 2.0 style and Alembic migrations. That choice applies to each component database, without creating a shared cross-daemon database or moving daemon-owned measurements into the Hub.

### Approved disposition

Run the Hub and every daemon as independent, least-privilege native systemd services. Each component owns its own SQLite database, uses SQLAlchemy 2.0 style, and maintains its own Alembic migration history. A component never opens or migrates another component's database. Upgrades require compatibility checks, a safe pre-migration backup, controlled migrations, post-upgrade health checks, and documented recovery. The Hub may report update availability but does not perform host or component updates. Service and update management remain under SHA/host-administrator control, and users or administrators do not manually alter managed Python environments.

Treat exact supported Ubuntu versions, filesystem paths, service names, Python environment tooling, and package commands as documented implementation and packaging choices rather than permanent architecture. Removing Docker images, packages, tags, and badges from the Hub or daemon repositories means those applications are not distributed as containers; it does not remove Docker Engine from the host or prohibit containers as an infrastructure boundary. Approved supporting services, including the MQTT broker and Mailpit, may require and run through Docker while the Hub and daemons remain native systemd services. Verify current units and packaging before presenting implementation details as guaranteed behavior.

## AR-014: Device capabilities, replacement, and manufacturer-neutral expansion

**Status:** Approved 2026-08-20
**Classifications:** Consistent, Stale, Unverified

### Review result

All sources support capability-driven integration and warn against erasing device-specific behavior. Weight-only scales, O2Ring spot/session separation, differing profile models, unavailable device clocks, and replacement history are useful examples. They are not universal contracts. The original four-device list is stale as a support boundary because BBT, non-contact health thermometers, and future devices must fit the architecture without naming a manufacturer.

Claims about exact daemon capabilities and hardware limitations were reported from an earlier code review but remain dated for this review.

### Approved disposition

Make capability discovery schema-versioned and additive. Keep logical health-data source, physical device, daemon instance, and measurement capability as separate identities. Replacing a physical device preserves existing history and its original device provenance rather than rewriting it as though the replacement produced the readings. Require the Hub and other consumers to tolerate unknown capabilities and use manufacturer-neutral UI language. Device-specific behavior—including profile models, available clocks, session semantics, measurements, assignment support, and manual-entry support—must be advertised rather than assumed. Mark hardware or protocol behavior as guaranteed only after verification for the applicable daemon and device combination.

## AR-015: Release scope, deferred work, and implementation constraints

**Status:** Approved 2026-08-20
**Classifications:** Conflict, Stale, Unverified

### Review result

Foundation's 20-item “initial release” list includes normalized MQTT output, Home Assistant discovery, a five-inch display, rotation, and night mode. Preliminary adds extensive identity, roles, Samba, alerts, backup, host, update, and audit requirements while explicitly saying it is not an implementation specification. These cannot all be assumed to be one minimal release.

The documents mix four kinds of statement: enduring architecture, product requirement, illustrative design, and observed implementation. This is the main cause of apparent conflict and scope growth.

### Approved disposition

Classify every retained requirement as an architecture invariant, required product capability, optional adapter, implementation choice, or deferred investigation. Establish a new release plan from the approved owner decisions and verified current behavior. Do not inherit the dated initial-release list wholesale because it mixes architecture, UI proposals, implementation details, and optional integrations.

## Implementation claim register

These claims are not accepted as current merely because Preliminary section 28 labels them confirmed. Current repository verification is recorded in [`ARCHITECTURE_IMPLEMENTATION_VERIFICATION.md`](ARCHITECTURE_IMPLEMENTATION_VERIFICATION.md); hardware and external-system claims still require their own evidence before consolidation.

| ID | Claim | Review state |
|---|---|---|
| CR-001 | Every supported daemon exposes versioned `/api/v1` routes and `GET /api/v1/capabilities`. | Confirmed in the five current daemon source trees. |
| CR-002 | Every supported daemon implements off-by-default MQTT publish-on-new-reading. | Confirmed in the five current daemon source trees; delivery/replay guarantees remain undefined. |
| CR-003 | All daemon HTTP servers use `aiohttp.web` and optional shared bearer tokens. | Confirmed current implementation; framework-specific and not an architecture requirement. |
| CR-004 | Every daemon uses SQLite for authoritative durable measurement storage. | Confirmed; all five use direct `sqlite3`, with no current SQLAlchemy or Alembic implementation. |
| CR-005 | TrueMetrix and Etekcity support assignment models differing from O2Ring's configured-wearer model. | Confirmed in current schemas, configuration, and endpoints; identity must remain capability-driven. |
| CR-006 | The BP protocol has no device-side clock and its memory slot is not a Hub profile. | Confirmed for the implemented reverse-engineered packet protocol; other models remain unverified. |
| CR-007 | O2Ring live readings and downloaded sessions use distinct tables and semantics. | Confirmed in daemon storage and API source; driver/session-finalization behavior remains for hardware review. |
| CR-008 | Daemons provide notifications and scheduled staleness/range checks. | Scheduled alert code/configuration and units confirmed; live provider behavior not tested. |
| CR-009 | Each daemon generates its own device-specific PDFs. | Confirmed; current on-demand API generation is synchronous rather than a durable asynchronous job. |
| CR-010 | Daemon retention/pruning exists and is covered by `test_prune.py`. | Deferred to a separate storage-policy review; not established by the hardware/protocol pass. |
| CR-011 | Current service units, users, paths, dependencies, and update procedures match the preliminary deployment model. | Unit files, daemon-specific users, paths, and dependencies inspected; installed runtime and update behavior not tested. |
| CR-012 | Current Home Assistant discovery requirements match the proposed topics, retained state, IDs, units, and availability model. | Verified with refinements: stable IDs/device context and cleanup are required; birth-triggered republishing is preferred; retained sensor state conflicts with naive `expire_after` use. |

## Cross-document conclusion

The documents are directionally compatible but are not safe to merge mechanically. Their durable center is the independent-daemon authority model, Hub-owned household presentation and access control, REST for request/response operations, MQTT for near-real-time daemon events and optional normalized consumers, daemon-owned PDFs, capability-driven expansion, and non-diagnostic presentation. Identity policy, role design, local-screen requirements, backup/file access, exact MQTT contracts, and release scope still require explicit decisions. All current-behavior claims require verification before the consolidated architecture can call them facts.
