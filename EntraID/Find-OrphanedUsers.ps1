<#
.SYNOPSIS
Finds users missing expected group membership (placeholder-friendly).

.DESCRIPTION
Used for access hygiene checks. Replace sample arrays with Graph results later.
#>

param(
  [string]$ExpectedGroup = "Baseline-Access",
  [string]$OutputPath = "out",
  [string]$ReportPrefix = "mw"
)

$repoRoot = Resolve-Path (Join-Path $PSScriptRoot "..")
$outDir = Join-Path $repoRoot $OutputPath
New-Item -ItemType Directory -Force -Path $outDir | Out-Null

# --- Sample data ---
$users = @(
  [pscustomobject]@{ DisplayName="User One"; UPN="user1@example.com"; Groups=@("Baseline-Access","VPN") },
  [pscustomobject]@{ DisplayName="User Two"; UPN="user2@example.com"; Groups=@("VPN") }
)
# -------------------

$missing = $users | Where-Object { $_.Groups -notcontains $ExpectedGroup } | ForEach-Object {
  [pscustomobject]@{
    DisplayName = $_.DisplayName
    UPN         = $_.UPN
    Missing     = $ExpectedGroup
  }
}

$csv = Join-Path $outDir "$ReportPrefix-orphaned-users.csv"
$missing | Export-Csv -NoTypeInformation -Encoding UTF8 -Path $csv

Write-Host "Users missing '$ExpectedGroup': $($missing.Count)" -ForegroundColor Green
Write-Host "Exported: $csv" -ForegroundColor Green
