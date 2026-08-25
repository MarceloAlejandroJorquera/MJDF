# Binary Distribution Model

MJ DNS FILTER v1 is published as a **binary-only Windows x64 application**.

## Official application artifact

The supported public executable is:

```text
MJDFv1.exe
```

Official binaries are attached to GitHub Releases. They are not committed to the repository's `main` branch.

## What the repository contains

The public branch contains user-facing material only:

- detailed project documentation;
- installation, operation, Rules, ports, recovery, and troubleshooting references;
- privacy and security policies;
- issue-report templates;
- branding/screenshots intended for the project page;
- SHA-256 generation and verification helpers;
- release notes and changelog.

The public branch does **not** contain the MJDF application source tree, Rust manifests, compiler configuration, internal build scripts, or development CI used to produce the executable.

## Authenticity and checksum verification

Each release should publish at minimum:

```text
MJDFv1.exe
SHA256SUMS.txt
generate-SHA256-MJDFv1.bat
verify-SHA256-MJDFv1.bat
```

Verify the executable against the `SHA256SUMS.txt` attached to the **same release**.

PowerShell can independently calculate the digest:

```powershell
Get-FileHash .\MJDFv1.exe -Algorithm SHA256
```

A matching filename without a matching digest is not sufficient evidence that a file is the official release.

## GitHub-generated source archives

GitHub automatically offers “Source code (zip)” and “Source code (tar.gz)” for tags. Because this repository is intentionally binary-only, those archives contain the repository documentation/metadata for that tag, **not the MJDF application source code**.

## Updates

A later release may change the distribution model, license, or published artifacts. Any such change must be stated explicitly in that release.
