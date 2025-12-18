<#
.SYNOPSIS
Exports group members to CSV (portfolio-safe structure).

.DESCRIPTION
Portfolio-safe, read-only reporting script. Uses a sample dataset by design.
In production, replace sample data with Microsoft Graph queries:
- GET /groups?$filter=displayName eq '{name}'
- GET /groups/{id}/members

.PARAMETER GroupName
Target group display name (used in report metadata).

.PARAMETER OutputPath
Relative folder where reports are written (default: out).

.PARAMETER ReportPrefix
Prefix for report file names (default: mw).

.EXAMPLE
.\Export-GroupMembers.ps1 -GroupName "Intune-Admins" -OutputPath out

.NOTES
- Non-destructive: read-only reporting
- Local execution (User context)
#>

[CmdletBinding()]
param(
    [ValidateNotNullOrEmpty()]
    [string]$GroupName = "Example-Group",

    [string]$OutputPath = "out",

    [string]$ReportPrefix = "mw"
)

. (Join-Path (Join-Path $PSScriptRoot "..") "src/EndpointAutomation.Common.ps1")

try {
    $outDir = New-OutputDirectory -OutputPath $OutputPath
    Write-Log -Level Info -Message ("Exporting members for group '{0}' (sample dataset)" -f $GroupName)

    # --- Sample data (portfolio) ---
    $members = @(
        [pscustomobject]@{ GroupName=$GroupName; MemberType="User";  DisplayName="Robertas Burbo"; UserPrincipalName="robertas@example.com"; ObjectId="u-0001" }
        [pscustomobject]@{ GroupName=$GroupName; MemberType="User";  DisplayName="Alice Admin";    UserPrincipalName="alice@example.com";    ObjectId="u-0002" }
        [pscustomobject]@{ GroupName=$GroupName; MemberType="Device";DisplayName="WIN-001";       UserPrincipalName=$null;                 ObjectId="d-0001" }
    )
    # -------------------------------

    $csvPath = Join-Path $outDir ("{0}-entra-group-members.csv" -f $ReportPrefix)
    Export-ReportCsv -InputObject ($members | Sort-Object MemberType, DisplayName) -Path $csvPath | Out-Null

    Write-Log -Level Info -Message ("Exported {0} members to {1}" -f $members.Count, $csvPath)
    exit 0
}
catch {
    Write-Log -Level Error -Message $_.Exception.Message
    exit 1
}
