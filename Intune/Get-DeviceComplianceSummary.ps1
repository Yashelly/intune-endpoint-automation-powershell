<#
.SYNOPSIS
Builds a compliance summary report (placeholder-friendly).

.DESCRIPTION
Creates a simple breakdown of compliant/noncompliant/unknown devices.
Replace sample dataset with Intune/Graph device compliance data later.
#>

param(
  [string]$OutputPath = "out",
  [string]$ReportPrefix = "mw"
)

$repoRoot = Resolve-Path (Join-Path $PSScriptRoot "..")
$outDir = Join-Path $repoRoot $OutputPath
New-Item -ItemType Directory -Force -Path $outDir | Out-Null

# --- Sample data ---
$devices = @(
  [pscustomobject]@{ DeviceName="WIN-001"; Platform="Windows"; Compliance="Compliant" },
  [pscustomobject]@{ DeviceName="WIN-002"; Platform="Windows"; Compliance="Noncompliant" },
  [pscustomobject]@{ DeviceName="IOS-003"; Platform="iOS";     Compliance="Unknown" }
)
# -------------------

$summary = $devices | Group-Object Platform, Compliance | ForEach-Object {
  $platform, $state = $_.Name -split ",\s*"
  [pscustomobject]@{
    Platform   = $platform
    Compliance = $state
    Count      = $_.Count
  }
} | Sort-Object Platform, Compliance

$csv = Join-Path $outDir "$ReportPrefix-compliance-summary.csv"
$summary | Export-Csv -NoTypeInformation -Encoding UTF8 -Path $csv

Write-Host "Exported compliance summary to: $csv" -ForegroundColor Green
