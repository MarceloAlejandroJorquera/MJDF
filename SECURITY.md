# Security Policy

MJ DNS FILTER is privileged networking software. Security reports involving DNS bypass, route corruption, unintended network exposure, WFP policy ownership, certificate handling, browser-policy ownership, privilege boundaries, or rule-persistence integrity are treated as security-relevant.

## Supported release

The current public security-supported release is **v1**. Users should reproduce issues on the newest published v1 binary before reporting unless the bug prevents updating.

## Reporting a vulnerability

Prefer GitHub's **Private vulnerability reporting / Security Advisories** feature when it is enabled for this repository.

Please do **not** publish exploit details in a normal Issue before maintainers have had an opportunity to evaluate a vulnerability that could:

- bypass filtering while MJDF reports healthy/attached;
- leave Windows without working DNS/network access;
- expose the loopback control API to another machine;
- allow an unprivileged process to trigger privileged route/WFP changes;
- cause MJDF to remove unrelated WFP, DNS, certificate, browser, or scheduled-task state;
- overwrite or roll back Rules without authorization;
- expose local certificate private keys or sensitive runtime state;
- turn a downloaded list/favIcon/browser response into code execution or local-file access.

A useful report contains:

- MJDF release version;
- Windows edition/build;
- exact reproduction steps;
- expected vs actual state;
- whether the tray and dashboard disagree;
- whether the route is `127.0.0.1/::1` or direct Cloudflare;
- relevant sanitized log excerpts;
- whether enterprise DNS/browser policy or endpoint-security software is present.

Do not attach an entire `%LOCALAPPDATA%\MJDF` directory without reviewing it. Runtime files can contain query history, custom rules, adapter information, certificate/key material and diagnostic state.

## Security design principles

The v1 release intentionally follows these principles:

- use inbox Windows BFE/WFP rather than requiring boot-security relaxation;
- verify critical WFP objects after installation;
- fail visibly instead of presenting a false green attached state;
- keep the browser dashboard loopback-only;
- keep privileged routing authority in the native host, not browser JavaScript;
- store mutable state beneath the user's Local AppData profile;
- use durable Rules generations/recovery data rather than browser memory as authority;
- preserve rollback state for DNS changes;
- remove only MJDF-owned browser/certificate/WFP state.

## Scope boundaries

A missing hostname for encrypted hard-coded-IP traffic is not automatically a vulnerability. MJDF does not decrypt arbitrary TLS/QUIC traffic or fabricate names not supplied by Windows. A report is security-relevant when MJDF claims a stronger enforcement state than it actually provides, or when a documented enforcement plane can be bypassed contrary to its stated model.
