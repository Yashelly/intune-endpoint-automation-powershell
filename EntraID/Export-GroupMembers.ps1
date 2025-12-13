<#
.SYNOPSIS
Exports group members to CSV (portfolio-safe structure).

.DESCRIPTION
Accepts a GroupName/GroupId placeholder and exports a normalized member list.
Replace the sample dataset with Graph queries in real use.
#>

param(
  [string]$GroupName = "Example-Group",
  [string]$OutputPath = "out",
  [string]$ReportPrefix = "mw"
)

$repoRoot = Resolve-Path (Join-Path $PSScriptRoot "..")
$outDir = Join-Path $repoRoot $OutputPath
New-Item -ItemType Directory -Force -Path $outDir | Out-Null

# --- Data source (replace with Graph queries) ---
$members = @(
  [pscustomobject]@{ DisplayName="User One"; UserPrincipalName="user1@example.com"; Type="User" },
  [pscustomobject]@{ DisplayName="User Two"; UserPrincipalName="user2@example.com"; Type="User" }
)
# ------------------------------------------------

$csv = Join-Path $outDir "$ReportPrefix-group-members-$($GroupName.Replace(' ','_')).csv"
$members | Select-Object DisplayName, UserPrincipalName, Type | Export-Csv -NoTypeInformation -Encoding UTF8 -Path $csv

Write-Host "Exported members for '$GroupName' to: $csv" -ForegroundColor Green
