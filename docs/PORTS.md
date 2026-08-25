# Ports and Network Endpoints

| Component | Default | Scope |
| --- | --- | --- |
| DNS UDP/TCP | `0.0.0.0:53` plus `[::1]:53` | IPv4 wildcard + IPv6 loopback | Windows itself uses `127.0.0.1`/`::1`; wildcard IPv4 can be LAN-reachable if firewall permits |
| DoH | `0.0.0.0:8080` plus `[::1]:8080` | IPv4 wildcard + IPv6 loopback | local browser URL uses `https://127.0.0.1:8080/dns-query` |
| Dashboard | `127.0.0.1:27853` preferred | loopback-only | falls forward through the reserved local range up to 27863 if needed |
| Upstream DoH | TCP 443 | outbound | configured upstream provider endpoints |
| DoT/DoQ guard | remote TCP/UDP 853 | outbound | blocked while attached |

## Firewall note

The public desktop workflow is local filtering, but the shipped DNS/DoH IPv4 wildcard binds can accept traffic from non-loopback interfaces if Windows Firewall permits it. If you do not intend to serve DNS to other machines, restrict inbound TCP/UDP 53 and TCP 8080 to local/trusted scope or change the listener configuration.

The dashboard is separate and remains loopback-only.
