# Health Hub daemon implementation verification

## Purpose

This is a read-only verification of implementation claims recorded during the cross-document architecture review. It describes current repository behavior; it does not approve that behavior as the final architecture. The protected Health Hub source documents were not changed.

## Snapshot

The review used each repository's fetched `origin/main` on 2026-08-20. The first four local checkouts were one Docker-removal commit behind, but those commits do not change daemon source, configuration, API, MQTT, report, storage, or systemd files.

| Daemon | Reviewed `origin/main` |
|---|---|
| TRUE METRIX | `6a34836223a13ea9c8ad0b24311fd5e82a073656` |
| Viatom O2Ring | `b9b7c4aab6362cc375fc85e57cc6a93d6dfa0648` |
| Etekcity scale | `641f059831256f3ee8655ba126565732c635ad7b` |
| Etekcity blood pressure | `fe1b4c335c6e9143e3685ea84ce52af0e7464a42` |
| Health thermometer | `547d36af1fd55531fa4994e9a4aec2c5a81c3c4f` |

This verification covers repository source and configuration. It does not claim installed-service, live-broker, hardware, or network validation.

## Verified common behavior

### REST API

All five daemons:

- depend on `aiohttp` and implement their API with `aiohttp.web`;
- place routes under `/api/v1/`;
- expose unauthenticated `GET /api/v1/health` and `GET /api/v1/capabilities`;
- expose `GET /api/v1/latest` and `GET /api/v1/report`;
- default the API to disabled and, when configured, to `127.0.0.1:8080`;
- optionally require one configured bearer token on routes other than health and capabilities;
- generate PDF or CSV reports in the daemon and return the resulting bytes from the report endpoint.

The API is supported local HTTP, not a Unix socket in the current implementations. The shared bearer token is daemon-level authentication, not Hub user authorization or per-client scope.

Route differences are intentional:

- TRUE METRIX exposes `GET` and `POST /api/v1/assign-device` because its configured relationship is meter-to-profile.
- Scale, blood-pressure, and health-thermometer daemons expose `GET` and `POST /api/v1/assign-profile` for per-reading tagging.
- O2Ring exposes `/api/v1/sessions` and `/api/v1/session-records` and has no assignment endpoint.

### Storage

All five daemons use Python's direct `sqlite3` API and component-owned SQLite files. None currently declares SQLAlchemy or Alembic, and none contains an Alembic revision tree.

This confirms SQLite and separate daemon ownership but identifies an implementation gap against the newly approved project persistence contract: SQLAlchemy 2.0-style models and Alembic migrations remain future work. Existing `CREATE TABLE IF NOT EXISTS` and ad hoc schema adjustment code must not be described as Alembic-managed migrations.

O2Ring has separate `live_readings`, `sessions`, and `session_records` tables with foreign-key enforcement and supporting indexes. The other reviewed daemons use one primary readings or measurements table, with their own source-specific columns and assignment behavior.

### MQTT

All five daemons implement optional publish-on-new-reading MQTT output:

- disabled by default;
- configured per daemon with broker, topic prefix, QoS, and retained-message settings;
- default QoS `0` and retained state enabled;
- published beneath `<daemon topic prefix>/<device identifier>/state`;
- attempted after durable local insertion, with broker failure logged rather than blocking or undoing local storage.

The implementations publish reading state only. No reviewed daemon implements MQTT command handling. This supports the documented split: MQTT supplies near-real-time reading events while REST remains responsible for query, configuration, report, assignment, and capability operations.

The current MQTT payload/topic contracts remain daemon-specific. Code inspection does not establish a shared event ID, schema version, replay contract, correction/deletion event, acknowledgement, or common delivery guarantee. Retained QoS-0 state is therefore a convenience projection, not durable transport or authoritative history.

### Reports

All five daemons contain ReportLab PDF generation, CSV generation, a CLI report entry point, and an on-demand `/api/v1/report` route. The four BLE daemons include weekly scheduled-report service/timer units; TRUE METRIX exposes report generation but does not contain the same weekly report timer in the reviewed tree.

Current report API generation is synchronous within the request and writes a temporary output before reading it into the HTTP response. It is not the asynchronous, restart-safe, bounded report-job model approved in the interface/report contract. Daemon report authority is implemented, but the durable job contract remains future implementation work.

### Configuration and services

All five use INI configuration and ship separate systemd units for the acquisition daemon and HTTP API. Each unit runs under a daemon-specific user and group. BLE services declare Bluetooth ordering/wants; TRUE METRIX uses its USB/HID-specific service arrangement.

All five ship scheduled alert checks. O2Ring schedules checks every 15 minutes; the other reviewed daemons use hourly timers. Scheduled reports and alerts are implementation features, not proof that notification policy, deduplication, or clinical thresholds have been approved for the Hub.

## Per-daemon identity and timestamp findings

| Daemon | Current subject/profile model | Current time model |
|---|---|---|
| TRUE METRIX | Meter IDs resolve to configured or dynamic profiles through an assignment store; the database reading is not rewritten into a universal Hub identity model. | Preserves meter `device_time`; ingestion/synchronization metadata exists separately. |
| O2Ring | No per-reading assignment endpoint; one daemon/configuration context represents its wearer while physical addresses remain source identity. | Live `recorded_at` is separate from session `start_time` and download/session metadata. |
| Etekcity scale | Reading has a nullable profile and may be tagged after capture. | Arrival-oriented `recorded_at`; device capabilities must be consulted before assuming device time. |
| Etekcity blood pressure | Reading has a nullable profile; the cuff's user slot remains separate from the Hub profile. | Arrival-oriented `recorded_at`; the claimed lack of a device clock still requires driver/protocol verification. |
| Health thermometer | Reading has a nullable profile and may be tagged after capture. | Stores `recorded_at` and a nullable `measured_at`, exposing the distinction through capabilities. |

The implementation evidence confirms that one universal device-to-profile rule would be wrong. The Hub must consume each daemon's declared model and still maintain its own distinct person, actor, source, and authorization identities.

## Claim-register disposition

| Claim | Result |
|---|---|
| Versioned API and capabilities endpoint | Confirmed in all five current daemon source trees. |
| Off-by-default MQTT publish on new reading | Confirmed in all five current daemon source trees. |
| `aiohttp.web` and optional shared bearer token | Confirmed as current implementation, not required architecture. |
| SQLite as daemon-owned durable storage | Confirmed; SQLAlchemy/Alembic are not yet implemented. |
| Different assignment/profile models | Confirmed; precise hardware meaning remains device-specific. |
| O2Ring split live/session storage | Confirmed. |
| Daemon alert checks | Confirmed as scheduled source/config features; live delivery was not tested. |
| Daemon PDF generation | Confirmed; durable asynchronous report jobs are not implemented. |
| Retention/pruning policy | Not completed in this pass. |
| Hardware/protocol limitations | Not completed in this pass. |
| Installed systemd behavior | Unit files inspected; live installation/runtime behavior not tested. |
| Home Assistant discovery compatibility | Requires current official Home Assistant documentation and Hub implementation review. |

## Architecture versus implementation

The following are verified current behavior:

- independent daemon-owned SQLite data;
- local versioned REST APIs and capability documents;
- optional daemon-to-broker publish-on-reading MQTT;
- daemon-owned PDF/CSV generation;
- separate daemon and API systemd services;
- capability-specific identity and timestamp semantics.

The following remain desired architecture or migration work:

- SQLAlchemy 2.0-style persistence and Alembic revisions;
- durable asynchronous report jobs;
- a finalized common MQTT envelope, delivery, replay, correction, and topic contract;
- Hub-issued scoped authorization mapped safely to daemon credentials;
- complete backup/restore, audit, retention, and migration behavior;
- a consolidated capability schema with explicit schema compatibility rules.

## Next verification boundary

The hardware/protocol review below completes the source-level portion of that work. Physical testing remains open wherever the evidence table says it has not occurred.

## Hardware and protocol verification

### Driver snapshot

The review used fetched `origin/main` driver sources. Existing checkouts were not modified; an untracked `HEALTH_HUB_INTEGRATION.md` in the Etekcity BP checkout was left untouched.

| Driver/library | Reviewed commit | Evidence represented by the repository |
|---|---|---|
| TRUE METRIX USB HID | `6f938997566454fafb17a94fd0c124609b76be73` | Protocol port plus unit tests; README explicitly says it has not been tested with hardware. |
| TRUE METRIX BLE | `8cc4602c809a95ce8e5595a039c247fad1c8134a` | Standard Bluetooth Glucose Profile confirmed by a documented live capture; client implementation still labels end-to-end testing incomplete. |
| Viatom O2Ring BLE/OxyII | `cf1f556e182dac08744c93341bb773ec9837c71f` | Separate legacy and OxyII implementations with protocol fixtures and device-family-specific behavior. |
| Etekcity scale BLE | `d13dd21aeda16bdc963566a727fba3b096d75bb0` | Multiple model protocols, advertisement detection, GATT acquisition, and capability registry. |
| Etekcity BP BLE | `e2a9136dd8f4ed8430e612c94f510afd13b53a85` | Reverse-engineered multi-packet protocol; README identifies one tested model and treats same-protocol models as possible rather than guaranteed. |
| Bluetooth Health Thermometer Profile | `ecf6484600c4fad845cd22974e0f40dc01571859` | Standard-profile implementation derived from two vendor clients; README explicitly says no live capture or physical-device validation yet. |

### TRUE METRIX

USB HID and BLE both expose a meter-generated reading timestamp. The daemon correctly preserves that `device_time` separately from UTC `synced_at`. The timestamp is naive local meter time; neither transport supplies a trustworthy time zone or offset. The Hub must not reinterpret it as UTC.

The HID path downloads framed records and verifies the aggregate download checksum. It supports model/serial/firmware identity and control-solution flags, but the library explicitly omits meter-reported units, clock-change logs, and ketone records. Its implementation is based on a public protocol port and tests, not current physical-hardware validation.

The BLE path uses the standard Glucose Service and correlates measurement/context notifications by sequence number. A real TRUE METRIX AIR capture showed the meter streaming its stored history automatically after subscription, rather than requiring the usual Record Access Control Point request. Completion is inferred from a device-specific completion notification or quiet-period heuristic, so a quiet period is not a universal protocol guarantee. Ketones and clock-setting remain unsupported.

Architecture consequence: retain transport and completion metadata, deduplicate idempotently, and expose acquisition completeness rather than claiming that every BLE synchronization is provably complete.

### Viatom O2Ring and OxyII

The driver supports two incompatible protocol families. Legacy O2Ring-class devices and the newer OxyII/O2Ring-S T8520 require different discovery, framing, commands, live decoding, and stored-file parsing. A generic “O2Ring protocol” capability is therefore insufficient; protocol family must remain explicit.

Live readings and stored sessions are genuinely different records. Live data carries receipt-time context and instantaneous SpO2/pulse/battery/status. Stored files contain fixed-interval session samples and summary metadata. OxyII records do not carry per-sample timestamps; sample time is derived from the filename/session start plus the file interval.

OxyII discovery can see different addresses/modes while worn versus idle. The recording-mode address is not necessarily connectable for synchronization. A stored file may reach its advertised byte count before its 48-byte trailer is flushed, so byte count alone does not prove completion. The parser exposes `trailer_confirmed`; a session must not become authoritative/final until that confirmation exists. OxyII also lacks several legacy configuration-write features.

Architecture consequence: capabilities must identify protocol family, live/session modes, connection mode, sample interval, timestamp derivation, and session-finalization state. The Hub must not flatten samples into point readings or treat an unconfirmed file as a completed reportable session.

### Etekcity scale

The scale library supports multiple models and two acquisition shapes: GATT notification sessions for some models and advertisement-carried measurements for others. Its model registry declares per-model support for weight, impedance/body composition, heart rate, and related fields. Unknown Etekcity-platform advertisements can be surfaced without falsely assigning a known model.

The daemon always supports weight-only operation and records only fields actually reported. Body-composition values are derived from impedance plus personal inputs and algorithms; they are not direct physical measurements equivalent to weight. Some models supply no impedance, and reports can explicitly skip those derived metrics.

The daemon assigns `recorded_at` from the host's UTC clock when the notification/advertisement is received. The reviewed acquisition path supplies no device measurement timestamp. A stable-weight notification is the acquisition event; absence of a reading or optional field must not be converted into zero.

Architecture consequence: capability and provenance must distinguish direct weight, raw impedance, and calculated body metrics. Model detection, acquisition transport, host receipt time, and algorithm/version inputs must be retained if derived metrics are exposed.

### Etekcity blood pressure

The reverse-engineered protocol builds one reading from a stateful sequence: an optional display-unit packet, a systolic/diastolic packet carrying device user slot, and a pulse/motion/irregular-heartbeat packet that completes the reading. A missing earlier packet causes the final pulse packet to be rejected rather than stored as a partial measurement. An error packet may replace a successful sequence.

No timestamp or clock field exists in the decoded reading or documented measurement packets. Current daemon `recorded_at` is therefore host receipt time. The device's user value is only physical memory slot 0 or 1 and is not evidence of a Hub person. The protocol supports mmHg/kPa display state but normalizes pressure values for storage while retaining source flags.

The code and README support one explicitly tested monitor model; other models using the same apparent protocol remain unverified.

Architecture consequence: the earlier “no device-side timestamp available” claim is confirmed for the implemented packet protocol. Store the slot separately, preserve motion/irregular/error quality flags, and require an explicit Hub subject assignment.

### Bluetooth Health Thermometer Profile

The driver implements the standard Health Thermometer Service and Temperature Measurement characteristic. It decodes the device-reported Celsius/Fahrenheit flag, IEEE-11073 floating-point value, optional embedded date/time, and optional temperature type/body site. Battery and device information are optional standard-service reads.

The timestamp and temperature type are optional by protocol. Embedded time is naive and has no zone/offset. The daemon therefore stores host UTC `recorded_at` for every reading and nullable device `measured_at`. The class has no device user slot and no implemented history download; the client waits for one live measurement per connection. Intermediate Temperature, Measurement Interval, and separately read Temperature Type are not implemented.

The protocol interpretation is supported by two unrelated vendor clients, but the library explicitly has not been tested through a live capture or physical thermometer. It must not be described as hardware-validated support yet.

Architecture consequence: generic Health Thermometer support must remain capability- and evidence-qualified. Preserve original units and optional body site, never invent `measured_at`, and distinguish standard-profile compatibility from tested device/model support.

### Evidence-level conclusions

- **Confirmed by current code:** decoded fields, timestamp handling, state-machine completion rules, capability branches, and daemon persistence behavior.
- **Confirmed by recorded real-hardware evidence:** TRUE METRIX AIR's standard BLE profile and observed stored-history streaming behavior.
- **Supported by reverse engineering and fixtures, with model limits:** O2Ring/OxyII, scale families, and Etekcity BP behavior as documented by their repositories.
- **Protocol-correct-on-paper, not hardware validated:** TRUE METRIX HID and the generic Health Thermometer client.
- **Not established by source review:** RF reliability, full history completeness under disconnects, pairing behavior on every host adapter, behavior of untested models, or clinical accuracy.

These distinctions must be retained in capability and support documentation. Implemented, protocol-derived, observed on hardware, and clinically validated are different claims.

## Remaining verification boundary

Retention/pruning policies still need their own implementation review; they are storage policy rather than a hardware/protocol limitation. Current Home Assistant assumptions are verified below.

## External-system verification: Home Assistant MQTT

### Primary sources and review date

Reviewed 2026-08-20 against current official Home Assistant documentation:

- [MQTT integration and discovery](https://www.home-assistant.io/integrations/mqtt/)
- [MQTT Sensor](https://www.home-assistant.io/integrations/sensor.mqtt/)
- [Sensor device classes](https://www.home-assistant.io/integrations/sensor/)
- [Developer sensor entity model](https://developers.home-assistant.io/docs/core/entity/sensor/)

Home Assistant behavior is an external compatibility target, not a Health Hub authority. Reverify these contracts when implementing or upgrading the adapter.

### Discovery topics and stable identity

Component discovery uses:

```text
<discovery_prefix>/<component>/[<node_id>/]<object_id>/config
```

The default discovery prefix is `homeassistant`, but it is configurable. Current guidance says that, for an entity with `unique_id`, using that value as `object_id` and omitting `node_id` is best practice. The topic layout in the older Health Hub source is therefore illustrative rather than final.

Home Assistant assigns an `entity_id` when the entity is first loaded. A configured `unique_id` lets a user rename the entity while preserving its Entity Registry identity. Device-registry grouping works only when `unique_id` is set and the discovery payload supplies a `device` context with at least one identifier or connection.

Health Hub consequence:

- Generate machine-stable, opaque `unique_id` and device identifiers.
- Never derive them from a person's mutable display name, physical-device replacement alone, or entity label.
- Keep friendly names in discovery display fields.
- Decide deliberately whether Home Assistant's device represents a logical person/source grouping, a physical device, or the Hub. Do not make one HA device entry stand for several identity domains accidentally.

### Discovery lifecycle

Home Assistant accepts retained discovery configuration, but its current documentation describes responding to Home Assistant's birth message as the better approach. The default birth topic is `homeassistant/status`. A publisher should subscribe for that message and republish discovery, with randomized delay when many entities would otherwise create broker load.

Publishing an empty payload to a discovery topic removes the component; retained discovery must be cleared so removed or renamed capabilities do not return as ghost entities. Updating a valid discovery topic updates its configuration. Device-based discovery has additional migration and removal rules, including stable matching `unique_id` and device identifiers.

Health Hub consequence:

- Implement discovery as reconciled desired state, not append-only publication.
- Republish after Home Assistant birth and after relevant Hub configuration/capability changes.
- Track previously published topics and clear obsolete retained configurations explicitly.
- Rate-limit or jitter bulk republishing.

### State retention, expiry, and availability

Retained state gives a newly subscribed entity an immediate last-known value. It does not mean that value is fresh or authoritative. Home Assistant warns that retained messages survive publisher and broker restarts and can create ghost entities.

For MQTT Sensor, `expire_after` can mark a sensor unavailable when no update arrives. The official sensor documentation specifically discourages retaining state when `expire_after` is used: after restart, the broker can replay an old retained value and make an expired sensor appear available again. Home Assistant already stores/restores sensor state and tracks remaining expiry time.

Availability topics represent publisher/device availability. A sensor can use one `availability_topic` or multiple availability entries with an availability mode; these must not be confused with measurement freshness. Home Assistant birth/will behavior also does not prove that a daemon has recently contacted its physical device.

Health Hub consequence:

- Keep Hub service availability, daemon/device availability, measurement freshness, and last-known value as distinct concepts.
- Do not combine retained state with `expire_after` without a tested design that avoids stale resurrection.
- Prefer an explicit availability topic for Hub-published entities and expose measurement age separately.
- Never use retained MQTT state as the Hub's durable ingestion or historical source.

### Sensor classes, units, and statistics

Current Home Assistant sensor classes include:

- `blood_glucose_concentration`, with `mg/dL` and `mmol/L`;
- `temperature`, with `°C`, `°F`, or `K`;
- `weight`, with supported mass units including `kg`, `lb`, and `st`;
- generic `pressure`, which accepts `mmHg` and `kPa` but does not provide a complete blood-pressure observation model.

There is no reviewed native sensor device class for a compound blood-pressure reading, SpO2 session, or complete O2Ring session. Systolic, diastolic, pulse, SpO2, and session summaries may need separate sensor entities with careful names and units. Device class must not be invented merely to obtain an icon.

Point-in-time health readings are measurements, not monotonically increasing totals. If long-term statistics are enabled, `state_class: measurement` is the plausible class for compatible numeric entities; `total` and `total_increasing` are not appropriate. Exact recorder/statistics behavior should be integration-tested before promising historical charts.

Home Assistant warns against frequently changing timestamp attributes and unnecessary `force_update`, because they cause additional state writes. Separate timestamp sensors are preferable when timestamps need first-class entity behavior.

### Compatibility disposition

The source architecture is correct that Home Assistant must remain optional and capability-driven. The following refinements are required:

1. Generic normalized MQTT remains independent from Home Assistant discovery.
2. Discovery is generated by a Hub adapter from actual supported capabilities.
3. Stable opaque IDs, explicit device context, and lifecycle cleanup are mandatory.
4. Birth-triggered reconciliation is preferred over relying only on retained discovery.
5. Retained current state is optional and must not be paired casually with expiry.
6. Availability and freshness remain separate.
7. Only official device classes and exact supported units are used.
8. O2Ring raw session samples are not expanded into hundreds of Home Assistant entities.
9. Home Assistant receives projections, not daemon authority or clinical interpretation.
10. Broker ACLs remain a deployment security responsibility; Home Assistant discovery does not enforce the project's subscribe-only policy for external clients.
