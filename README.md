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

## Quick start

```powershell
# From repository root
pwsh .\Automation\Weekly-AdminReport.ps1 -OutputPath out -ReportPrefix mw
```

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
