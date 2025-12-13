<#
.SYNOPSIS
Generates a report of stale devices based on last sign-in (placeholder-friendly).

.DESCRIPTION
Portfolio-safe script structure: reads config, filters by inactivity window,
exports CSV, and prints summary. Replace Get-Data section with your tenant logic later.

.PARAMETER InactiveDays
Days since last sign-in to consider a device stale.

.OUTPUTS
CSV report in ./out
#>

param(
  [int]$InactiveDays = 90,
  [string]$OutputPath = "out",
  [string]$ReportPrefix = "mw"
)

# Optional local config (not committed)
$cfgPath = Join-Path $PSScriptRoot "..\config.json"
if (Test-Path $cfgPath) {
  $cfg = Get-Content $cfgPath -Raw | ConvertFrom-Json
  if ($cfg.InactiveDays) { $InactiveDays = [int]$cfg.InactiveDays }
  if ($cfg.OutputPath) { $OutputPath = [string]$cfg.OutputPath }
  if ($cfg.ReportPrefix) { $ReportPrefix = [string]$cfg.ReportPrefix }
}

$repoRoot = Resolve-Path (Join-Path $PSScriptRoot "..")
$outDir = Join-Path $repoRoot $OutputPath
New-Item -ItemType Directory -Force -Path $outDir | Out-Null

$cutoff = (Get-Date).AddDays(-$InactiveDays)

# --- Data source (replace with Graph/Entra queries in real use) ---
$devices = @(
  [pscustomobject]@{ DisplayName="WIN-001"; LastSignIn=(Get-Date).AddDays(-120); OperatingSystem="Windows"; AccountEnabled=$true; DeviceId="0001" },
  [pscustomobject]@{ DisplayName="WIN-002"; LastSignIn=(Get-Date).AddDays(-14);  OperatingSystem="Windows"; AccountEnabled=$true; DeviceId="0002" },
  [pscustomobject]@{ DisplayName="MAC-003"; LastSignIn=$null;                  OperatingSystem="macOS";   AccountEnabled=$true; DeviceId="0003" }
)
# ---------------------------------------------------------------

$report = $devices | ForEach-Object {
  $last = $_.LastSignIn
  $inactiveDays = if ($last) { (New-TimeSpan -Start $last -End (Get-Date)).Days } else { $null }
  $isStale = if ($last) { $last -lt $cutoff } else { $true }  # treat null as stale for review

  [pscustomobject]@{
    DisplayName    = $_.DisplayName
    OperatingSystem= $_.OperatingSystem
    AccountEnabled = $_.AccountEnabled
    LastSignIn     = $last
    InactiveDays   = $inactiveDays
    DeviceId       = $_.DeviceId
    IsStale        = $isStale
  }
}

$stale = $report | Where-Object IsStale | Sort-Object InactiveDays -Descending
$csv = Join-Path $outDir "$ReportPrefix-stale-devices.csv"
$stale | Export-Csv -NoTypeInformation -Encoding UTF8 -Path $csv

Write-Host "Stale devices: $($stale.Count) (>= $InactiveDays days or unknown last sign-in)" -ForegroundColor Green
Write-Host "Exported: $csv" -ForegroundColor Green
