# Security Model

## Trust boundary

MJDF is a local privileged networking application. The native process is trusted to manage Windows DNS and MJDF-owned WFP/browser/certificate state. The browser dashboard is not trusted as an independent privileged state authority; it communicates requests to the native host and reads final state back.

## Privileges

Administrator rights are required for:

- binding/configuring privileged DNS behavior as applicable;
- changing adapter DNS configuration;
- registering secure DNS settings;
- installing local CA trust;
- changing supported browser policy;
- installing/removing WFP policy;
- creating privileged autostart scheduled-task behavior.

## WFP model

Normal v1 enforcement uses inbox BFE/WFP user-mode policy management. Attach-scoped filters are placed in a dynamic session. MJDF performs read-back/health checks before presenting a healthy attached state.

The release deliberately avoids requiring a locally signed custom kernel driver. This preserves compatibility with Secure Boot and HVCI/Memory Integrity rather than asking users to weaken those protections.

## Fail-closed boot gate

For remembered filtered/autostart operation, MJDF can arm boot-time and persistent WFP filters during orderly shutdown so next boot begins closed to ordinary non-loopback egress until the local runtime plane is proven ready.

The gate is MJDF-owned and should be removed for remembered direct mode or when MJDF will not autostart.

## Certificate model

MJDF creates local certificate material for its loopback HTTPS DoH endpoint. The private key remains local. Firefox may require explicit enterprise certificate policy in addition to Windows root trust.

Never attach private key files to a public Issue.

## Browser policy ownership

MJDF should alter only the DNS/certificate policy values it owns. Direct mode cleanup must not remove unrelated organization/browser policy.

## Network-listener exposure

The dashboard is designed for `127.0.0.1`, not remote administration. There is no v1 remote-authentication boundary intended for exposing the control UI to a LAN/WAN.

The DNS and DoH data-plane listeners are separate. The shipped IPv4 configuration uses `0.0.0.0:53` and `0.0.0.0:8080`; these can be reachable from other hosts if Windows Firewall permits them. Operators who only want same-machine filtering should restrict inbound access or narrow the bind address. Exposing MJDF as a LAN resolver changes the attack surface and should be deliberate.

## Input surfaces

Security-sensitive input surfaces include:

- DNS packet parsing;
- DoH HTTP payloads;
- downloaded blocklists;
- remote favicon/manifest responses;
- browser API requests;
- Rules text/patterns;
- persisted runtime JSON/TOML.

Changes to these paths should preserve bounded parsing, explicit URL/network restrictions and safe local-file behavior.

## Limits of enforcement claims

A policy can only be enforced at a layer that has enough information. If Windows authorizes a hard-coded IP connection without a usable name and the application hides DNS semantics in encrypted payload, WFP hostname policy cannot match a hostname that is not present. MJDF should report that boundary rather than fabricate enforcement evidence.
