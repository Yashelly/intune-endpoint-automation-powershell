<#
.SYNOPSIS
Flags potential enrollment / policy application issues (placeholder-friendly).

.DESCRIPTION
Looks for devices with missing last check-in, error states, or missing profile assignment.
Replace sample dataset with Intune/Graph queries later.
#>

param(
  [int]$MaxDaysSinceCheckIn = 7,
  [string]$OutputPath = "out",
  [string]$ReportPrefix = "mw"
)

$repoRoot = Resolve-Path (Join-Path $PSScriptRoot "..")
$outDir = Join-Path $repoRoot $OutputPath
New-Item -ItemType Directory -Force -Path $outDir | Out-Null

$cutoff = (Get-Date).AddDays(-$MaxDaysSinceCheckIn)

# --- Sample data ---
$devices = @(
  [pscustomobject]@{ DeviceName="WIN-001"; LastCheckIn=(Get-Date).AddDays(-1);  Status="OK";        HasBaseline=$true },
  [pscustomobject]@{ DeviceName="WIN-002"; LastCheckIn=(Get-Date).AddDays(-12); Status="OK";        HasBaseline=$true },
  [pscustomobject]@{ DeviceName="WIN-003"; LastCheckIn=$null;                  Status="Error";     HasBaseline=$false }
)
# -------------------

$issues = $devices | Where-Object {
  ($_.LastCheckIn -eq $null) -or ($_.LastCheckIn -lt $cutoff) -or ($_.Status -ne "OK") -or (-not $_.HasBaseline)
} | ForEach-Object {
  [pscustomobject]@{
    DeviceName   = $_.DeviceName
    LastCheckIn  = $_.LastCheckIn
    Status       = $_.Status
    HasBaseline  = $_.HasBaseline
    IssueHint    = if ($_.Status -ne "OK") { "Status not OK" }
                  elseif (-not $_.HasBaseline) { "Missing baseline/profile" }
                  elseif ($_.LastCheckIn -eq $null) { "No check-in recorded" }
                  else { "Stale check-in" }
  }
}

$csv = Join-Path $outDir "$ReportPrefix-enrollment-issues.csv"
$issues | Export-Csv -NoTypeInformation -Encoding UTF8 -Path $csv

Write-Host "Potential issues: $($issues.Count)" -ForegroundColor Yellow
Write-Host "Exported: $csv" -ForegroundColor Green
