# Privacy

MJ DNS FILTER is designed as a local Windows networking tool. It does not require an MJDF cloud account and the application does not depend on a hosted MJDF telemetry service.

## Data stored locally

MJDF stores mutable runtime state under `%LOCALAPPDATA%\MJDF`, including configuration, Rules, immutable Rules history/recovery records, downloaded blocklists, logs, DNS rollback state, route preference, certificate/key material and cached icons.

The dashboard's query history can reveal domains resolved by the machine. Treat logs, screenshots and Rules as potentially sensitive.

## Network destinations

MJDF can generate outbound traffic for the following functional reasons:

- forwarding allowed DNS queries to configured upstream DNS providers;
- downloading user-configured remote blocklists;
- retrieving site favicons/branding for dashboard display;
- normal browser traffic to the locally served dashboard remains loopback-only.

The default configuration uses Cloudflare DNS-over-HTTPS as primary upstream and Google DNS-over-HTTPS as fallback. Changing `config.toml` changes the upstream privacy relationship.

## Favicons

When favicon discovery is enabled by normal dashboard use, MJDF may contact public endpoints associated with a queried domain. Cached icons reduce repeated discovery. This means a domain shown in the dashboard can cause an additional HTTP/HTTPS icon request independent of the original DNS query.

## Browser policies

While MJDF owns the filtered route, it can write supported browser DNS/certificate policy so browser encrypted-DNS behavior remains compatible with the local resolver. These changes are local to Windows/browser configuration; they are not uploaded to MJDF.

## What to redact from bug reports

Review before sharing:

- domain/query history;
- blacklist/whitelist/hidden rules;
- `%LOCALAPPDATA%\MJDF\logs`;
- DNS adapter rollback information;
- local certificate private keys;
- screenshots showing personal browsing activity.

## Listener exposure

The dashboard is loopback-only, but the shipped configuration uses wildcard IPv4 binds for DNS (`0.0.0.0:53`) and DoH (`0.0.0.0:8080`). Windows Firewall/network profile therefore matters. If other machines should not use this PC as a resolver, restrict those inbound ports or narrow the configured listener address.
