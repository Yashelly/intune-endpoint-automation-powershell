# Endpoint Automation (PowerShell) — Intune / Modern Workplace Portfolio

A focused portfolio repository of **read-only PowerShell reporting scripts** for **Microsoft Intune** and **Microsoft Entra ID** (Modern Workplace / Endpoint Management).

The goal is to demonstrate **enterprise-safe automation patterns**:
- clear script contracts (parameters, outputs, exit codes)
- consistent logging
- non-destructive behavior (reporting/audit)
- CI linting and basic tests

> **Important:** Scripts intentionally use **sample datasets** to keep the repository tenant-agnostic and safe to share publicly.
> Each script documents where Microsoft Graph calls would be used in production.

---

## What’s inside

- `Intune/` — compliance and operational reporting (portfolio-safe)
- `EntraID/` — identity/device hygiene reporting (portfolio-safe)
- `Automation/` — wrapper scripts to run report bundles
- `src/` — shared helper functions used by scripts
- `tests/` — Pester tests for basic quality gates

---

## Execution model

- **Execution context:** Local run (User context)
- **Designed for:** local execution, Scheduled Task, CI lint/test
- **Not designed for:** Intune Proactive Remediations (no detect/remediate split)

---

## Safety & behavior

- **Non-destructive by design:** no tenant writes, no deletes, no device actions
- **Idempotent:** re-running produces the same type of output without side effects
- **Outputs:** CSV reports in `./out` by default

---

## Prerequisites
- PowerShell 7+ (recommended). PowerShell 5.1 on Windows is also supported for basic script execution.

## Quick start

```powershell
# From repository root (Windows)
pwsh .\Automation\Weekly-AdminReport.ps1 -OutputPath out -ReportPrefix mw

# From repository root (Linux/macOS)
pwsh ./Automation/Weekly-AdminReport.ps1 -OutputPath out -ReportPrefix mw
```

## Configuration (optional)

To keep the repo tenant-agnostic, scripts default to safe, local-only behavior.
If you want to tweak common parameters without changing command lines:

1) Copy the example config:

```bash
cp config.example.json config.json
```

2) Edit `config.json` (it is ignored by git via `.gitignore`).

Supported keys: `InactiveDays`, `OutputPath`, `ReportPrefix`.

3) Run the bundle with the config file:

```powershell
# Windows
pwsh .\Automation\Weekly-AdminReport.ps1 -ConfigPath config.json

# Linux/macOS
pwsh ./Automation/Weekly-AdminReport.ps1 -ConfigPath config.json
```

Notes:
- Command-line parameters override values from the JSON config.
- You can also provide `-LogPath` to write a run log to a specific file.

---

## Output

All scripts write reports to an output folder (default `./out`), for example:
- `mw-intune-compliance-summary.csv`
- `mw-intune-enrollment-issues.csv`
- `mw-intune-policy-assignments.csv`
- `mw-entra-stale-devices.csv`
- `mw-entra-group-members.csv`
- `mw-entra-orphaned-users.csv`

---

## Quality gates

This repo includes:
- **PSScriptAnalyzer** ruleset (`PSScriptAnalyzerSettings.psd1`)
- **Pester** tests (`tests/`)
- **GitHub Actions** CI workflow (`.github/workflows/ci.yml`)

---

## License

MIT — see `LICENSE`.

## Author’s note

This is a portfolio snapshot and is not actively maintained.

This repository reflects how I approach endpoint automation as a Modern Workplace / Intune engineer.
The focus is on safe, predictable, and non-destructive reporting scripts with clear execution behavior
and maintainable structure.

I intentionally avoid tenant-modifying or destructive automation here.
In real production environments, such changes require proper design, review, and governance.
