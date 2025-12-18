<#
.SYNOPSIS
Finds users missing expected access group membership.

.DESCRIPTION
Portfolio-safe detection logic for access hygiene checks.
Uses sample datasets by design. In production, replace data with Graph queries:
- GET /users
- GET /groups/{id}/members

.PARAMETER ExpectedGroup
Group name that users should be members of.

.PARAMETER OutputPath
Relative folder where reports are written (default: out).

.PARAMETER ReportPrefix
Prefix for report file names (default: mw).

.EXAMPLE
.\Find-OrphanedUsers.ps1 -ExpectedGroup "Baseline-Access" -OutputPath out

.NOTES
- Non-destructive: read-only reporting
- Local execution (User context)
#>

[CmdletBinding()]
param(
    [ValidateNotNullOrEmpty()]
    [string]$ExpectedGroup = "Baseline-Access",

    [string]$OutputPath = "out",

    [string]$ReportPrefix = "mw"
)

. (Join-Path (Join-Path $PSScriptRoot "..") "src/EndpointAutomation.Common.ps1")

try {
    $outDir = New-OutputDirectory -OutputPath $OutputPath
    Write-Log -Level Info -Message ("Finding users missing group '{0}' (sample dataset)" -f $ExpectedGroup)

    # --- Sample data (portfolio) ---
    $users = @(
        [pscustomobject]@{ DisplayName="Robertas Burbo"; UserPrincipalName="robertas@example.com"; ObjectId="u-0001" }
        [pscustomobject]@{ DisplayName="Alice Admin";    UserPrincipalName="alice@example.com";    ObjectId="u-0002" }
        [pscustomobject]@{ DisplayName="Bob User";       UserPrincipalName="bob@example.com";      ObjectId="u-0003" }
    )

    $groupMembers = @(
        "u-0001",
        "u-0002"
    )
    # -------------------------------

    $missing = $users | Where-Object { $groupMembers -notcontains $_.ObjectId } | ForEach-Object {
        [pscustomobject]@{
            DisplayName       = $_.DisplayName
            UserPrincipalName = $_.UserPrincipalName
            ObjectId          = $_.ObjectId
            MissingGroup      = $ExpectedGroup
        }
    }

    $csvPath = Join-Path $outDir ("{0}-entra-orphaned-users.csv" -f $ReportPrefix)
    Export-ReportCsv -InputObject ($missing | Sort-Object DisplayName) -Path $csvPath | Out-Null

    Write-Log -Level Info -Message ("Exported {0} orphaned users to {1}" -f $missing.Count, $csvPath)
    exit 0
}
catch {
    Write-Log -Level Error -Message $_.Exception.Message
    exit 1
}
