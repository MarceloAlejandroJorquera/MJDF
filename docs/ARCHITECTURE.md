# Architecture

## Overview

MJDF separates DNS resolution, observation, policy, native routing, WFP enforcement and browser presentation. This separation is intentional: a browser page must not be the authority for a privileged network transition, and an observed hostname must not be presented as enforced unless the relevant enforcement plane can support that claim.

## Major components

### `DnsCore` / server

Owns DNS request handling, upstream forwarding, cache integration, metrics and live filter evaluation. Local DNS listeners accept UDP/TCP DNS and the DoH module exposes encrypted inbound DNS.

### `FilterEngine`

Evaluates configured blocklists and user Custom Rules. Whitelist precedence is applied before blacklist enforcement. Custom rule grammar is documented in `RULES.md`.

### `rules_store`

Persists Custom Rules as backend-owned state. The browser editor is a client of this store, not its authority. Immutable generations/recovery state are used to survive interrupted writes and process restarts.

### `system_dns`

Owns Windows DNS adapter routing, encrypted-DNS registration, rollback state, route preference and browser-policy synchronization support.

### `inbox_wfp`

Implements the release enforcement plane through the Windows user-mode WFP management API (`fwpuclnt.dll`). It owns attach-scoped dynamic filters and the startup-gate objects.

### `wfp_capture` / attribution sources

Provides lower-level observation and synchronization support. The normal v1 enforcement authority is inbox WFP, not a custom kernel driver.

### `browser_gui` / tray

Owns the native route state machine and Windows tray integration. Dashboard commands are queued to this native host. The route worker performs DNS/WFP/rules synchronization and publishes the final native state.

### dashboard server

Serves static UI/API/WebSocket content on loopback. Route status is read-only; privileged native routing is not implemented a second time in dashboard code.

## Attached transition

Conceptually:

1. receive native attach/toggle command;
2. mark route transition busy/yellow;
3. serialize against Rules mutation state;
4. verify local DNS + DoH listener readiness;
5. install/trust local DoH certificate as required;
6. configure Windows encrypted local DNS;
7. route active adapters to `127.0.0.1` / `::1`;
8. synchronize current Rules into local resolver + WFP hostname policy;
9. verify the WFP TCP/UDP 853 guard and hostname enforcement plane;
10. complete startup-gate handoff if applicable;
11. reconcile actual native DNS state;
12. publish final Attached state;
13. publish settled route generation;
14. clear route-busy ownership;
15. let the dashboard observe the result through its read-only status channel.

The ordering is important: `route_busy=false` must not be published before the final Attached/Detached state is committed.

## Detached/direct transition

The route worker serializes against the same Rules/native state, closes attach-scoped WFP enforcement, configures direct encrypted DNS, verifies Windows route state, persists the user's direct selector preference, publishes Detached/direct and settles the route generation.

## WFP filters

The normal attached session contains hard outbound port-853 block filters and hostname policy filters. Exact hostnames are represented as exact match conditions. Suffix semantics are used only for rules that explicitly express suffix/wildcard behavior.

WFP cannot match a hostname that Windows never provides at the authorization layer. MJDF does not infer encrypted application-layer names from ciphertext.

## Startup gate

The startup gate is distinct from the attach-scoped dynamic session. It exists to bridge normal filtered/autostart boot from early TCP/IP startup through BFE availability until the runtime plane is ready.

## Browser dashboard state authority

The dashboard may optimistically paint a yellow transition immediately after a click, but only the native route status endpoint can settle that presentation. Metrics/WebSocket payloads do not own route-state fields.
