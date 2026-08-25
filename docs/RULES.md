# Custom Rules

MJDF has three user-authored rule lists: Blacklist, Whitelist and Hiddenlist.

## Exact-by-default grammar

A plain hostname is exact:

```text
example.com
```

matches only `example.com`.

It does not automatically include `www.example.com` or any other subdomain.

## Wildcards

Use an explicit wildcard when broader matching is intended:

```text
*.example.com
```

Wildcard behavior is evaluated by the MJDF rule engine. WFP enforcement uses only representations it can truthfully express; complex wildcard matches can be converted into concrete exact-host blocks as those hostnames are observed.

## Whitelist

Whitelist entries take precedence over Custom Blacklist policy. A whitelist exception should not silently whitelist unrelated subdomains unless the rule itself contains wildcard semantics.

## Hiddenlist

Hiddenlist controls dashboard visibility. It does not mean allow or block. Exact/wildcard parsing follows the same explicit grammar used by user-authored filtering rules.

## ACTION levers

The Live ACTION lever performs a backend transaction against the current Rules state. The response returned to the browser is the canonical persisted state. Route transitions are not supposed to create independent Rules generations.

## Persistence location

Rules live under `%LOCALAPPDATA%\MJDF\config`. The backend maintains canonical/generation/recovery state; text files are mirrors/recovery aids rather than browser-owned authority.

## Test cases

Before each release verify:

- add two blacklist entries, immediately detach/attach, both remain;
- add two whitelist entries, immediately detach/attach, both remain;
- repeat using tray route changes;
- repeat using dashboard sphere route changes;
- restart MJDF and verify all entries;
- `example.com` does not match `sub.example.com`;
- `*.example.com` does match intended subdomains;
- Hidden exact rules do not hide unlisted subdomains.
