<#
.SYNOPSIS
Exports a simplified view of policy/profile assignments (placeholder-friendly).

.DESCRIPTION
Useful to audit "what is assigned to whom". Replace sample data with Graph later.
#>

param(
  [string]$OutputPath = "out",
  [string]$ReportPrefix = "mw"
)

$repoRoot = Resolve-Path (Join-Path $PSScriptRoot "..")
$outDir = Join-Path $repoRoot $OutputPath
New-Item -ItemType Directory -Force -Path $outDir | Out-Null

# --- Sample data ---
$assignments = @(
  [pscustomobject]@{ PolicyName="Baseline - Windows"; Type="Configuration"; Target="All Windows Devices" },
  [pscustomobject]@{ PolicyName="Compliance - Windows"; Type="Compliance";   Target="Windows - Prod" }
)
# -------------------

$csv = Join-Path $outDir "$ReportPrefix-policy-assignments.csv"
$assignments | Export-Csv -NoTypeInformation -Encoding UTF8 -Path $csv

Write-Host "Exported: $csv" -ForegroundColor Green
