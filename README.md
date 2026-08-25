# MJ DNS FILTER (MJDF) v1

<p align="center">
  <img src="assets/MJ_DNS_FILTER_256.png" width="160" alt="MJ DNS FILTER icon">
</p>

<p align="center">
  <img alt="Release v1" src="https://img.shields.io/badge/release-v1-2ea043">
  <img alt="Status Stable" src="https://img.shields.io/badge/status-stable-2ea043">
  <img alt="Windows x64" src="https://img.shields.io/badge/platform-Windows%20x64-0078D4">
  <img alt="Rust 1.97.1" src="https://img.shields.io/badge/Rust-1.97.1-b7410e">
  <img alt="WFP" src="https://img.shields.io/badge/enforcement-Windows%20WFP-5b5fc7">
</p>

**MJ DNS FILTER (MJDF)** is a Windows DNS visibility, filtering, and enforcement application designed to put DNS policy under direct local control without requiring a third-party DNS client, browser extension, packet-capture driver, or custom kernel driver.

The v1 release combines a local DNS/DoH resolver, a detailed default-browser dashboard, Windows DNS route management, persistent custom rules, blocklist management, multi-source DNS attribution, and Windows Filtering Platform (WFP) enforcement for hostname-aware connection policy and encrypted-DNS bypass control.

MJDF is intentionally built around a simple operational model:

> **Attached:** Windows uses MJDF on `127.0.0.1` and `::1`; MJDF filters locally and forwards allowed DNS upstream over encrypted DNS.  
> **Detached / direct:** Windows uses Cloudflare DNS directly instead of the local filter.

The dashboard sphere and the tray's DNS selector control the same native routing state.

---

## Contents

- [Project goals](#project-goals)
- [What MJDF does](#what-mjdf-does)
- [How it works](#how-it-works)
- [Detection and attribution](#detection-and-attribution)
- [Blocking and enforcement](#blocking-and-enforcement)
- [Encrypted DNS](#encrypted-dns)
- [Dashboard](#dashboard)
- [Rules](#rules)
- [Lists](#lists)
- [Attach / detach model](#attach--detach-model)
- [Fail-closed startup protection](#fail-closed-startup-protection)
- [Requirements](#requirements)
- [Installation](#installation)
- [First run](#first-run)
- [Ports and local endpoints](#ports-and-local-endpoints)
- [Data and persistence](#data-and-persistence)
- [Privacy](#privacy)
- [Security model](#security-model)
- [Known boundaries](#known-boundaries)
- [Troubleshooting](#troubleshooting)
- [Binary distribution model](#binary-distribution-model)
- [Release verification](#release-verification)
- [Repository documentation](#repository-documentation)

---

## Project goals

MJDF was created around a stricter goal than a conventional hosts-file blocker or DNS proxy: **observe as much name-resolution activity as Windows exposes, make policy decisions locally, and enforce those decisions as close to the network boundary as practical while staying compatible with normal Windows security settings.**

The project therefore emphasizes the following goals.

### 1. Broad DNS visibility

A useful DNS blocker first needs to know what is happening. MJDF combines its own resolver traffic with Windows-native observation sources so activity that does not arrive as an ordinary UDP/53 packet can still be represented where the operating system exposes enough information.

### 2. Local, explicit policy

User-authored rules are stored locally. Whitelist, blacklist, and hidden-list semantics are explicit and deterministic. A plain hostname is exact; wildcard behavior must be written as a wildcard.

### 3. Enforcement, not only classification

A red row should not merely be a cosmetic label. MJDF's attached state includes a Windows WFP policy plane and refuses to report a healthy attached state when the required local DNS listeners or WFP enforcement plane cannot be verified.

### 4. Encrypted upstream DNS

Allowed queries can be forwarded upstream through DNS-over-HTTPS rather than exposing ordinary plaintext UDP DNS to the configured upstream resolver.

### 5. Resistance to common bypass paths

While attached, MJDF uses Windows Filtering Platform rules to block standard outbound TCP/UDP port `853`, covering conventional DNS-over-TLS and DNS-over-QUIC use on their standard port. Browser DNS-over-HTTPS integration is also managed for supported browsers while the local encrypted resolver is active.

### 6. No custom release kernel driver

The normal v1 enforcement plane uses Microsoft's inbox **Base Filtering Engine / Windows Filtering Platform**. The release does **not** require a custom kernel driver, WDK installation, TESTSIGNING, Secure Boot changes, or an HVCI / Memory Integrity exception.

### 7. Safe routing transitions

Changing between local filtering and direct DNS is a state transition, not just a registry toggle. MJDF verifies listener readiness, rules state, Windows DNS routing, WFP state, and final route settlement before presenting the steady state.

### 8. Operational transparency

The dashboard exposes query history, source/type attribution, block/allow state, statistics, active lists, and custom rules. It is intended to make policy behavior inspectable instead of hidden behind a background service.

---

## What MJDF does

MJDF v1 provides the following major capabilities:

- local DNS server on IPv4 and IPv6 loopback;
- inbound local DNS-over-HTTPS endpoint;
- encrypted upstream DNS-over-HTTPS forwarding;
- fallback upstream handling;
- native Windows DNS adapter routing;
- IPv4 and IPv6 DNS configuration;
- Windows secure-resolver registration for local DoH;
- default-browser dashboard served only on loopback;
- native Windows tray control;
- blacklist, whitelist, and hidden-list custom rules;
- explicit wildcard rule syntax;
- downloaded blocklist management;
- scheduled refresh of configured remote blocklists;
- DNS caching with bounded TTL handling;
- live query history;
- source/process attribution when Windows provides it;
- query-type and source statistics;
- lower-level Windows resolver / host observations;
- WFP hostname-policy enforcement where Windows exposes a hostname at authorization time;
- outbound TCP/UDP 853 blocking while attached;
- browser DoH policy integration for supported browser families;
- automatic elevation when privileged networking changes are required;
- autostart support from the tray;
- persisted route preference;
- fail-closed next-boot protection for remembered filtered/autostart operation;
- durable rule storage under the user's Local AppData profile;
- migration of supported legacy MJDF runtime state;
- single-instance GUI behavior;
- single-EXE release layout.

---

## How it works

MJDF is not one monolithic packet filter. It is a set of cooperating control, resolver, observation, and enforcement planes.

### Local resolver plane

When attached, Windows DNS is routed to:

- IPv4: `127.0.0.1`
- IPv6: `::1`

MJDF listens locally for DNS traffic, evaluates each hostname against its filter engine, returns a blocking response when required, and forwards allowed requests upstream.

The default configuration uses encrypted upstream DNS-over-HTTPS. The included configuration currently defines Cloudflare as the primary upstream and Google DNS as fallback.

### Local encrypted-DNS plane

MJDF exposes an RFC 8484-style HTTPS DNS endpoint used locally at:

`https://127.0.0.1:8080/dns-query`

and the corresponding IPv6 loopback endpoint. MJDF creates and manages a local certificate identity and registers/trusts it as required for the encrypted resolver. Supported browser policies are synchronized to the selected route.

**Important:** the shipped configuration binds the primary IPv4 DNS and DoH listeners to `0.0.0.0` (`53` and `8080`). That means they can be reachable through non-loopback IPv4 interfaces if the Windows firewall/network profile permits it. The desktop routing workflow itself uses loopback, but operators who do not intend to serve other machines should restrict inbound TCP/UDP 53 and TCP 8080 with Windows Firewall or change the listener configuration to the desired scope before treating the host as an isolated local-only resolver.

### Native Windows routing plane

MJDF manages active physical/default-route adapters rather than assuming a single interface. It applies and verifies both IPv4 and IPv6 DNS state using Windows-native interfaces, with narrowly scoped fallbacks if the primary Windows DNS-setting path does not settle correctly.

The application retains rollback state so it can restore or safely move away from the local resolver when appropriate.

### Rules plane

Custom rules are maintained as a durable canonical state, not solely as browser textarea contents. Changes are committed through backend transactions and persisted beneath `%LOCALAPPDATA%\MJDF`.

The rule engine is synchronized with both the local DNS resolver and the WFP hostname-policy plane.

### WFP enforcement plane

While attached, MJDF opens an attach-scoped dynamic WFP/BFE session. The session carries:

- outbound TCP port 853 block filters;
- outbound UDP port 853 block filters;
- hostname-aware connection filters for concrete names that MJDF policy requires to be blocked;
- exact/suffix filters only when the rule semantics explicitly require them.

MJDF verifies the filters it installs before treating the enforcement plane as healthy. Dynamic attach-scoped filters disappear when the session is closed or the process terminates.

### Observation plane

MJDF merges multiple sources of DNS/name-resolution evidence. This includes local resolver traffic plus Windows-native lower-level observations. The exact source shown in the dashboard depends on which Windows subsystem exposed the information.

This is why the Live log can contain conventional DNS types such as `A` or `AAAA` as well as lower-level `HOST` or `RES` observations.

---

## Detection and attribution

DNS activity on modern Windows does not always look like a simple UDP packet from an application to port 53. Applications can use the Windows resolver, cached name resolution, browser resolver stacks, TCP DNS, local multicast protocols, encrypted DNS, or pre-existing connections.

MJDF therefore uses overlapping visibility sources and de-duplicates them into a practical user-facing history.

### Normal resolver traffic

Queries that reach the local MJDF resolver are the strongest and most direct form of visibility because MJDF sees the complete DNS question and directly controls the response.

### Windows resolver observations

MJDF consumes Windows name-resolution observations to recover activity from applications and system components that may otherwise be difficult to associate with a conventional local socket query.

### WFP-related observations

Windows Filtering Platform can expose connection and name-resolution information at lower layers. When a concrete hostname is present and policy can be proven armed, MJDF can represent a lower-level observation as policy-enforced rather than merely observed.

### Process/source labeling

Where Windows supplies process identity, MJDF attempts to normalize common process names into readable labels such as Firefox, Edge, Chrome, or system sources.

Attribution is evidence-based. MJDF does not invent a process or hostname when Windows has not supplied enough information.

### HOST and RES entries

`HOST` and `RES` are provenance/query-type indicators for lower-level host or resolver observations. They are not synonyms for “unblockable.” Their effective allowed/blocked presentation depends on whether MJDF has a factual resolver outcome or a proven WFP hostname-policy outcome for the observation.

---

## Blocking and enforcement

MJDF uses more than one enforcement point.

### DNS-response enforcement

For requests handled by the local resolver, blacklist policy can be enforced directly at DNS-response time. The default configured block action is `NXDOMAIN`.

### WFP hostname enforcement

For hostname-aware outbound connection authorization, MJDF can commit a matching hostname to the attach-scoped WFP policy plane. This adds another enforcement layer beyond returning a blocked DNS response.

MJDF uses Windows-provided peer/effective-name conditions. A hostname filter can only match when Windows supplies a usable hostname at the relevant authorization layer.

### Port 853 guard

Attached mode installs hard block filters for outbound TCP and UDP remote port `853`. This targets the standard port used by DNS-over-TLS and DNS-over-QUIC.

### Whitelist precedence

The whitelist is authoritative over custom blocking policy. MJDF rebuilds or updates the active hostname-policy plane as required when custom rules change so stale block filters do not silently override a new exception.

---

## Encrypted DNS

MJDF distinguishes several different encrypted-DNS problems.

### Upstream privacy

By default, MJDF can forward allowed queries to upstream providers through DNS-over-HTTPS. This protects the DNS transport between MJDF and the configured upstream endpoint.

### Local browser integration

When the filtered route is active, MJDF can configure supported browser policy so the browser uses the local encrypted resolver instead of bypassing the local DNS path.

The project contains integration logic for common Chromium-family browsers and Firefox. Browser policy behavior varies by browser version and enterprise-policy behavior, so the dashboard exposes integration diagnostics rather than assuming success.

### Standard DoT / DoQ bypass

Outbound TCP/UDP 853 is blocked while attached through WFP.

### Arbitrary HTTPS/QUIC DoH boundary

MJDF does **not** decrypt arbitrary application TLS or QUIC traffic. If an application sends DNS-like traffic inside ordinary HTTPS/QUIC to a hard-coded IP and Windows does not expose the target hostname to the policy layer, MJDF cannot safely fabricate the hidden name from ciphertext.

That boundary is deliberate. Full recovery of arbitrary application-layer encrypted DNS would require application instrumentation, a terminating proxy/decryption architecture, or a deeper specialized network component with different security and trust implications.

---

## Dashboard

MJDF serves its UI to the Windows default browser from loopback. There is no embedded WebView2, Sciter, Wry, Winit, or similar renderer dependency in the release binary.

The preferred dashboard address starts at:

`http://127.0.0.1:27853/`

If that port is occupied, MJDF can move through a small reserved local range.

### Live!

The Live page is the real-time operational view. It shows query/host activity, source, type, latency and effective policy state. Consecutive/coalescent activity is grouped for readability while detail dialogs retain the underlying member events.

The ACTION lever allows a visible hostname to be added to the blacklist or whitelist without manually switching to the Rules page.

<p align="center">
  <img width="1435" height="1211" alt="assets/screenshots/live-query-log" src="https://github.com/user-attachments/assets/8916896d-d126-4ca2-a335-2421da89dc24" />
  <em>Live Query Log showing grouped DNS activity, source attribution, filtering state, latency, rule actions, and Top Blocked / Top Queried summaries.</em>
</p>

### Stop / Play

Stop freezes the **visible Live table**. Filtering and internal collection continue; buffered activity becomes visible again when Play is pressed. Rule changes while stopped do not force new query rows onto the visible frozen table.

### Stats

The Stats page summarizes query activity, common names, sources and types. Drill-down dialogs expose the underlying event details.

<p align="center">
  <img width="1435" height="1339" alt="assets/screenshots/stats" src="https://github.com/user-attachments/assets/ebc8eda7-894f-423f-80e9-e241ecf5a9f2" />
  <em>Statistics dashboard with query activity history, resolver totals, blocked/allowed/cached/observed distribution, source and record-type attribution, session performance, and domain rankings.</em>
</p>

<p align="center">
  <em>Statistics dashboard with query activity history, resolver totals, blocked/allowed/cached/observed distribution, source and record-type attribution, session performance, and domain rankings.</em>
</p>

### Lists

The Lists page manages downloaded blocklists and their state. Configured remote lists can be refreshed automatically according to the configuration schedule.

<p align="center">
  <img width="1435" height="1192" alt="assets/screenshots/lists" src="https://github.com/user-attachments/assets/c797ddd2-04a8-4330-833d-759c4f801236" />
  <em>Blocklist Manager exposing selectable Hagezi, security, privacy, content, and native-tracker filtering categories.</em>
</p>

### Rules


The Rules page exposes three user-authored rule sets:

- **Blacklist** — domains/patterns to block;
- **Whitelist** — exceptions/allowed names with precedence over custom blocking;
- **Hiddenlist** — names hidden from dashboard presentation; this is a visibility rule, not a network allow/block rule.

Rules are persisted independently from attach/detach state.

<p align="center">
  <img width="1435" height="1193" alt="rules" src="https://github.com/user-attachments/assets/a27e82c7-4e94-4651-9df1-93410e72854f" />
  <em>Persistent Blacklist, Whitelist, and Hiddenlist editors with explicit hostname and wildcard rule syntax.</em>
</p>

<p align="center">
</p>

---

## Rules

The v1 custom-rule grammar is intentionally explicit.

### Exact hostname

```text
google.com
```

matches **only** `google.com`.

It does not implicitly match:

```text
www.google.com
mail.google.com
accounts.google.com
```

### Wildcard/subdomain rule

```text
*.google.com
```

is the explicit form for matching subdomains. It does not silently convert every plain hostname into a suffix rule.

### Structural wildcard

Broader wildcard expressions supported by the filter engine are evaluated by the user-mode rule engine. When a concrete blocked hostname is observed and WFP hostname enforcement is available, MJDF commits the concrete hostname rather than pretending WFP supports a wildcard form that it does not actually implement.

### Rule ordering and precedence

1. Whitelist exceptions take precedence over custom blacklist policy.
2. Blacklist policy applies to names that are not whitelisted.
3. Hiddenlist controls dashboard visibility only.

### Persistence

Custom rule state is stored as backend-owned durable state below `%LOCALAPPDATA%\MJDF\config`. Text mirrors and recovery files exist for resilience, but the browser page itself is not the persistence authority.

For release testing, rule persistence should be verified across:

- immediate detach/attach;
- tray route changes;
- dashboard sphere route changes;
- application restart;
- Windows restart when autostart is enabled.

---

## Lists

MJDF supports local/downloaded blocklist files in addition to custom Rules.

The default configuration points the filter engine at:

```text
blocklists/*.txt
```

beneath the runtime data root.

Remote lists added through the dashboard can be recorded in the local list manifest and refreshed by the auto-updater. The default configuration enables auto-update and schedules it for `03:00` local time.

Downloaded third-party lists remain subject to their own licenses and terms. MJDF does not imply ownership of list contents.

---

## Attach / detach model

There are two user-visible DNS modes.

### Attached — filtered local DNS

Windows DNS is configured to use MJDF:

```text
127.0.0.1
::1
```

The local DNS + DoH listeners must be healthy, Windows DNS must verify the expected route, and the attach-scoped WFP enforcement plane must be ready before MJDF reports the final healthy attached state.

### Detached — direct encrypted DNS

The direct selector uses Cloudflare DNS instead of the local filtering resolver. The application remembers the user's selected route mode and restores that intent appropriately on later launches.

### Sphere and tray

The dashboard sphere and the tray DNS selector use the same native command worker and the same final routing state. The browser dashboard is a presentation/control client; it is not allowed to own an independent DNS-routing implementation.

### State colors

The application uses color to communicate route health/transition state. In general:

- **green** — verified attached/healthy filtered state;
- **yellow** — transition or incomplete settlement;
- **red** — detached/error/not filtering state, depending on context.

Always inspect the sphere/tray tooltip details when diagnosing a non-green state.

---

## Fail-closed startup protection

When autostart is enabled and the remembered selection is the filtered route, MJDF can arm a Windows WFP startup gate for the next normal boot/shutdown cycle.

The purpose is to prevent ordinary non-loopback application egress from escaping before the local DNS/Rules/WFP runtime plane has completed startup.

The startup handoff is designed around Windows inbox WFP behavior:

- a boot-time filter covers the early TCP/IP phase;
- a persistent counterpart covers the BFE-managed phase;
- loopback remains usable so MJDF can start its local services;
- DHCP and necessary IPv6 link-control bootstrap traffic receive narrow exceptions;
- the gate is removed only after local DNS/DoH and runtime WFP enforcement are verified.

While this barrier is genuinely active, local resolver requests can be returned as temporary startup failures rather than being forwarded.

### Important abrupt-power boundary

A normal Windows shutdown gives MJDF an opportunity to arm the next-boot gate. A user-mode application cannot retroactively install a boot-time policy before it has ever run after an unexpected power loss or crash. Absolute pre-user-mode protection after every possible abrupt failure would require a different always-installed service/boot/kernel architecture.

---

## Requirements

### Runtime

- **Operating system:** 64-bit Windows on x86-64.
- **Release target:** `x86_64-pc-windows-msvc`.
- **Privileges:** administrator elevation is required for DNS adapter changes, certificate trust, browser policy, scheduled-task/autostart integration and WFP policy management.
- **Windows services:** Base Filtering Engine / Windows Filtering Platform must be available and policy writes must not be prohibited by administrator/enterprise policy.
- **Ports 53 and 8080:** MJDF must be able to bind its configured DNS and DoH sockets. Another service owning those addresses/ports will prevent normal operation.
- **Default browser:** required for the full dashboard UI. The native tray remains a Windows UI component.
- **Network:** required for upstream DNS, remote blocklists, and optional favicon discovery.

### Not required

The normal v1 release does **not** require:

- WebView2 runtime;
- Sciter;
- Wry/Winit;
- a custom MJDF kernel driver;
- Windows Driver Kit for runtime use;
- TESTSIGNING mode;
- disabling Secure Boot;
- disabling HVCI / Memory Integrity.

### Tested support statement

The project is developed for modern Windows x64 and uses current Windows DNS/WFP APIs. Before claiming a specific Windows edition/build as supported on the GitHub release page, test the final public binary on that edition. Enterprise DNS/browser policy can intentionally prevent MJDF from taking ownership of settings.

---

## Installation

MJDF v1 is distributed as a **single executable**.

1. Download `MJDFv1.exe` from the GitHub Releases page.
2. Download `SHA256SUMS.txt` from the same release.
3. Verify the executable hash before running it.
4. Place `MJDFv1.exe` in a permanent folder you control. Avoid running a long-lived autostart configuration from a temporary Downloads cleanup folder.
5. Run `MJDFv1.exe`.
6. Accept the Windows UAC prompt when MJDF requests elevation.
7. The tray icon appears and the dashboard opens in the Windows default browser.

No embedded browser runtime is installed.

### Windows reputation warnings

A new unsigned or newly signed binary can trigger Microsoft Defender SmartScreen reputation prompts even when its hash is valid. Verify that you downloaded the file from the project's official GitHub release and compare its SHA-256 digest with the published checksum.

If you later code-sign releases, document the expected publisher certificate in this section and in the release notes.

---

## First run

On first use, MJDF initializes its per-user runtime directory under:

```text
%LOCALAPPDATA%\MJDF
```

It creates configuration/rule state as needed, starts local DNS services, creates the local encrypted-DNS certificate material, and asks Windows for the privileged changes required by the selected route.

When attaching to the local filtered route, MJDF verifies:

1. IPv4 local DNS listener readiness;
2. IPv6 local DNS listener readiness;
3. local DoH listener readiness;
4. local certificate trust;
5. Windows secure-resolver registration;
6. adapter DNS routing;
7. rules synchronization;
8. WFP 853 guard health;
9. hostname-policy capability;
10. final native route state.

The sphere may be yellow while that transaction is settling. It should not remain yellow after the native state has settled.

---

## Ports and local endpoints

| Purpose | Address / port | Direction | Notes |
| --- | --- | --- | --- |
| DNS resolver | configured IPv4 bind, default `0.0.0.0:53`; Windows client uses `127.0.0.1:53` | inbound | default IPv4 listener is network-facing unless firewalled |
| DNS resolver | `[::1]:53` | loopback inbound | additional IPv6 loopback listener when primary bind is IPv4 |
| DoH | configured IPv4 bind, default `0.0.0.0:8080`; Windows/browser local URL uses `https://127.0.0.1:8080/dns-query` | inbound | default IPv4 listener can be network-facing unless firewalled |
| Local IPv6 DoH | `https://[::1]:8080/dns-query` | loopback inbound | additional IPv6 loopback listener when primary bind is IPv4 |
| Dashboard | `http://127.0.0.1:27853/` | loopback only | preferred port; nearby fallback ports may be used |
| Standard DoT/DoQ | remote `853/TCP` and `853/UDP` | outbound | blocked by WFP while attached |
| Upstream DoH | HTTPS / 443 | outbound | provider endpoints from config |

The dashboard itself is loopback-only. DNS/DoH listeners are separately configurable and the shipped IPv4 defaults are wildcard binds (`0.0.0.0`). If the machine is on an untrusted network, review Windows Firewall rules before release/deployment so MJDF does not unintentionally become a LAN-accessible resolver.

---

## Data and persistence

The canonical writable runtime root is:

```text
%LOCALAPPDATA%\MJDF
```

Important subpaths include:

```text
%LOCALAPPDATA%\MJDF\config
%LOCALAPPDATA%\MJDF\blocklists
%LOCALAPPDATA%\MJDF\logs
```

The runtime may contain:

- `config.toml`;
- canonical Rules state and immutable rule-history checkpoints;
- whitelist/blacklist/hidden text mirrors;
- DNS routing rollback state;
- remembered routing preference;
- local TLS certificate/key material;
- browser-policy ownership state;
- downloaded blocklists;
- cached site/source icons;
- diagnostic logs.

Do not publish your runtime `config` directory with a bug report without reviewing it first. It can reveal browsing/query history, custom domain rules, local adapter information, and certificate material.

---

## Privacy

MJDF is designed as a local control application and does not require a hosted MJDF account or MJDF telemetry service.

However, network privacy still depends on the features you use:

- allowed DNS queries are sent to the configured upstream resolver;
- the default configuration uses Cloudflare DoH with Google DoH as fallback;
- remote blocklists contact the list URL you configure;
- favicon discovery may contact public web endpoints associated with visible domains;
- browser DNS policy changes affect how supported browsers resolve names while MJDF owns the filtered route.

See [`PRIVACY.md`](PRIVACY.md) for the complete data-flow summary.

---

## Security model

MJDF is privileged networking software. Treat it accordingly.

### Privileged operations

MJDF can:

- change DNS settings on active adapters;
- install/remove its local certificate trust material;
- write supported browser enterprise-policy keys related to DNS/certificate use;
- create/remove its autostart scheduled task;
- add/remove MJDF-owned WFP filters;
- block outbound network traffic during fail-closed startup handoff.

### Ownership boundaries

MJDF should only remove or restore settings that it owns or that it previously captured as rollback state. It should not broadly delete unrelated WFP policy, certificates, browser policy, or DNS configuration.

### BFE/WFP failure behavior

A healthy green attached state requires the expected WFP enforcement plane. If administrator policy prevents MJDF from installing or verifying that plane, attach should fail visibly instead of pretending enforcement is present.

### Local dashboard

The dashboard is served on loopback. The DNS/DoH resolver listeners are a separate surface: the shipped IPv4 configuration binds them to `0.0.0.0`. Restrict them with Windows Firewall or narrow the configured bind address when remote resolver service is not intended. Do not expose the dashboard itself to another machine; the v1 UI is designed for same-machine control.

See [`SECURITY.md`](SECURITY.md) and [`docs/SECURITY-MODEL.md`](docs/SECURITY-MODEL.md).

---

## Known boundaries

MJDF aims for broad visibility and enforcement, but Windows and encrypted application protocols impose real boundaries.

### No fabricated hostname from ciphertext

If a program connects directly to a hard-coded IP and hides its target in encrypted TLS/QUIC application data, MJDF cannot derive a reliable hostname merely from ciphertext.

### Existing connections

A hostname policy installed after an already-authorized connection exists cannot necessarily retroactively terminate that connection. Reconnect/restart the application when testing a newly added connection-level rule.

### WFP hostname availability

Hostname filters require Windows to provide a suitable peer/effective hostname at connection authorization. Not every application/network flow carries that information.

### Browser policy variation

Browser enterprise-DNS settings can vary across versions and may be overridden by organization policy. MJDF verifies what it can and exposes integration status instead of assuming control.

### Local cache effects

Operating-system, browser, application and MJDF caches can affect the timing of visible DNS activity. A missing new DNS query does not always mean a connection occurred without name resolution; the name may already have been cached.

### Multicast/local name resolution

mDNS, LLMNR and NetBIOS name-service traffic have different semantics from unicast Internet DNS. MJDF may observe these classes, but they should not be interpreted identically to a normal recursive DNS request.

---

## Troubleshooting

### MJDF cannot attach / sphere stays red

Check:

- another service is not already using port 53;
- BFE/WFP services are running;
- Windows/enterprise policy allows DNS and WFP changes;
- the application is running elevated;
- `%LOCALAPPDATA%\MJDF\logs` for the most recent error;
- IPv4 and IPv6 local listeners are available;
- endpoint/security software is not blocking loopback DNS/DoH.

### Sphere stays yellow

The yellow state means a transition has not settled. The dashboard polls authoritative native routing state. If it remains yellow, check the tray state and logs. A release build should not require a browser refresh or a second tray click to complete a dashboard-originated transition.

### Browser works differently from Windows DNS tools

Inspect browser integration details in the sphere tooltip. Firefox and Chromium-family browsers can maintain independent encrypted-DNS policy/caches.

### No queries appear from an application

Possible reasons include:

- cached DNS;
- an already-open connection;
- hard-coded IP use;
- an application-managed encrypted resolver;
- name information unavailable in the Windows observation plane;
- hidden-list rules suppressing the row from the dashboard.

### A rule does not affect a subdomain

This is expected for an exact rule. Use an explicit wildcard when you intend to cover subdomains.

### Need emergency direct DNS recovery

Use the tray's direct DNS selector when available. If MJDF itself cannot complete a route operation, Windows DNS can be restored manually from an elevated Windows networking shell or Settings. Do not delete `%LOCALAPPDATA%\MJDF\config\dns-session.json` before recovery if it contains the only rollback snapshot of a custom pre-MJDF DNS configuration.

More cases are documented in [`docs/TROUBLESHOOTING.md`](docs/TROUBLESHOOTING.md).

---

## Binary distribution model

The public MJDF repository is intentionally **binary-only**. The application source tree, Rust project files, build scripts, internal build configuration, and development toolchain are not published in this repository.

The supported public runtime artifact is:

```text
MJDFv1.exe
```

The executable is distributed through the repository's **GitHub Releases** page rather than committed to the `main` branch. This keeps the repository history focused on release documentation, security/privacy information, checksums, issue reporting, and user-facing technical reference material.

For each official release, obtain the executable and its checksum from the **same GitHub Release**. Do not treat files from mirrors, reposts, or third-party bundles as official merely because the filename matches.

The `main` branch intentionally contains no MJDF application source code. GitHub's automatically generated “Source code (zip)” and “Source code (tar.gz)” archives therefore contain only the public repository documentation/metadata for that tag; they are **not** MJDF source distributions.

See [`BINARY_DISTRIBUTION.md`](BINARY_DISTRIBUTION.md) for the publication and verification model.

---

## Release verification

Every public binary release should include:

```text
MJDFv1.exe
SHA256SUMS.txt
generate-SHA256-MJDFv1.bat
```

The repository includes `generate-SHA256-MJDFv1.bat` for producing the checksum file and `verify-SHA256-MJDFv1.bat` for local verification.

Example PowerShell verification:

```powershell
Get-FileHash .\MJDFv1.exe -Algorithm SHA256
```

Compare the resulting digest with the official `SHA256SUMS.txt` attached to the same GitHub release.

Never trust a checksum copied from an unrelated mirror; obtain the executable and checksum from the project's official release page.

---

## Repository documentation

- [`CHANGELOG.md`](CHANGELOG.md) — public release history.
- [`SECURITY.md`](SECURITY.md) — vulnerability reporting and security support.
- [`PRIVACY.md`](PRIVACY.md) — data flow and local storage.
- [`CONTRIBUTING.md`](CONTRIBUTING.md) — issue/report/documentation contribution guidance for the binary-only repository.
- [`SUPPORT.md`](SUPPORT.md) — support/bug-report guidance.
- [`ROADMAP.md`](ROADMAP.md) — post-v1 direction.
- [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) — technical architecture.
- [`docs/INSTALLATION.md`](docs/INSTALLATION.md) — installation/update notes.
- [`BINARY_DISTRIBUTION.md`](BINARY_DISTRIBUTION.md) — binary-only publication and checksum model.
- [`docs/COMMAND-LINE.md`](docs/COMMAND-LINE.md) — command-line/reference switches.
- [`docs/RULES.md`](docs/RULES.md) — exact/wildcard rule semantics.
- [`docs/SECURITY-MODEL.md`](docs/SECURITY-MODEL.md) — privileged operations and trust boundaries.
- [`docs/TROUBLESHOOTING.md`](docs/TROUBLESHOOTING.md) — operational diagnostics.
- [`docs/UNINSTALL-RECOVERY.md`](docs/UNINSTALL-RECOVERY.md) — removal and emergency recovery.
- [`docs/FAQ.md`](docs/FAQ.md) — common questions.
- [`docs/RELEASE-CHECKLIST.md`](docs/RELEASE-CHECKLIST.md) — release QA checklist.

---

## Project status

**v1 is the first public binary release.** The release line is focused on Windows x64, a single executable, inbox-WFP enforcement, default-browser dashboard control, local Rules, and explicit routing between filtered loopback DNS and direct encrypted DNS.

Bug reports should include reproducible steps and sanitized diagnostics. Networking/security bugs that could expose users to bypass or route-loss conditions should be reported privately when possible; see [`SECURITY.md`](SECURITY.md).

---

## License

Unless a later release explicitly adopts another license, this binary-only repository/package uses the conservative terms in [`LICENSE`](LICENSE). Public access to the repository or executable does **not** imply an open-source license or source-code availability.

Third-party dependencies retain their own licenses. See [`THIRD_PARTY_NOTICES.md`](THIRD_PARTY_NOTICES.md).
