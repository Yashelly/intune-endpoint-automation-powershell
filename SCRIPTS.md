# Script index

All scripts in this repository are **portfolio-safe** and use **sample datasets** by design.

## Contract (applies to all scripts)

- **Execution context:** Local run (User context)
- **Behavior:** Read-only reporting (non-destructive)
- **Exit codes:**
  - `0` = success
  - `1` = runtime error

## EntraID

| Script | Purpose | Output |
|---|---|---|
| `EntraID/Find-StaleDevices.ps1` | Report devices considered stale based on last sign-in | `*-entra-stale-devices.csv` |
| `EntraID/Export-GroupMembers.ps1` | Export group members (normalized) | `*-entra-group-members.csv` |
| `EntraID/Find-OrphanedUsers.ps1` | Find users missing expected group membership | `*-entra-orphaned-users.csv` |

## Intune

| Script | Purpose | Output |
|---|---|---|
| `Intune/Get-DeviceComplianceSummary.ps1` | Compliance summary by platform/state | `*-intune-compliance-summary.csv` |
| `Intune/Find-EnrollmentIssues.ps1` | Detect devices with possible enrollment/sync issues | `*-intune-enrollment-issues.csv` |
| `Intune/Export-AssignedPolicies.ps1` | Export a simplified view of policy assignments | `*-intune-policy-assignments.csv` |

## Automation

| Script | Purpose | Output |
|---|---|---|
| `Automation/Weekly-AdminReport.ps1` | Runs the full reporting bundle | Multiple CSV files in output folder |
