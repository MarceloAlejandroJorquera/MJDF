# FAQ

## Is MJDF a hosts-file blocker?
No. It runs a local DNS/DoH resolver, evaluates policy, manages Windows DNS routing and uses WFP for additional connection/encrypted-DNS enforcement.

## Does `example.com` whitelist every subdomain?
No. Plain custom rules are exact. Use an explicit wildcard when subdomains are intended.

## Does Hiddenlist allow a domain?
No. Hiddenlist affects dashboard visibility only.

## Is a custom kernel driver required?
No. The v1 release uses inbox BFE/WFP for enforcement.

## Must Secure Boot or Memory Integrity be disabled?
No. The normal release path is designed not to require that.

## Does MJDF decrypt HTTPS/QUIC to find hidden DoH names?
No. It blocks standard TCP/UDP 853 while attached and manages supported browser DNS behavior, but it does not fabricate names from arbitrary encrypted application traffic.

## Why can HOST/RES rows appear?
They represent lower-level Windows host/name-resolution observations. Their policy color reflects factual/proven enforcement state where available.

## Does Stop disable filtering?
No. Stop freezes the visible Live table. Filtering and collection continue.

## Where are my Rules?
Under `%LOCALAPPDATA%\MJDF\config`, in backend-owned persistent state and mirrors/recovery records.

## Is the dashboard exposed to the LAN?
The dashboard is loopback-only. The DNS/DoH data-plane listeners are separate; the shipped IPv4 config uses wildcard binds, so review Windows Firewall if you do not intend to serve other machines.

## Why does MJDF require administrator rights?
Because it changes Windows DNS, secure resolver/certificate/browser integration, WFP policy and optional autostart state.
