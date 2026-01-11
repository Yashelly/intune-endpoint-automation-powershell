<#
.SYNOPSIS
Exports a simplified view of Intune policy assignments.

.DESCRIPTION
Portfolio-safe reporting script. Uses sample policy assignment data by design.
In production, replace sample data with Microsoft Graph queries:
- GET /deviceManagement/deviceConfigurations
- GET /deviceManagement/deviceCompliancePolicies
- GET assignments for each policy

.PARAMETER OutputPath
Relative folder where reports are written (default: out).

.PARAMETER ReportPrefix
Prefix for report file names (default: mw).

.EXAMPLE
.\Export-AssignedPolicies.ps1 -OutputPath out -ReportPrefix mw

.NOTES
- Non-destructive: read-only reporting
- Local execution (User context)
#>

[CmdletBinding()]
param(
    [string]$OutputPath = "out",
    [string]$ReportPrefix = "mw",

    [string]$LogPath = ""
)

. (Join-Path (Join-Path $PSScriptRoot "..") "src/EndpointAutomation.Common.ps1")

$ErrorActionPreference = 'Stop'
try {
    $outDir = New-OutputDirectory -OutputPath $OutputPath
    Write-Log -Level Info -Message "Exporting policy assignments (sample dataset)" -Source "Export-AssignedPolicies" -LogPath $LogPath

    # --- Sample data (portfolio) ---
    $assignments = @(
        [pscustomobject]@{ PolicyType="Compliance";   PolicyName="Windows - Baseline Compliance"; Target="All users";  Exclusions="Break-glass"; Mode="Include" }
        [pscustomobject]@{ PolicyType="Configuration";PolicyName="Device restrictions";           Target="All devices"; Exclusions=$null;        Mode="Include" }
        [pscustomobject]@{ PolicyType="Security";     PolicyName="Defender ASR baseline";        Target="Pilot group"; Exclusions=$null;        Mode="Include" }
    )
    # -------------------------------

    $csvPath = Join-Path $outDir ("{0}-intune-policy-assignments.csv" -f $ReportPrefix)
    Export-ReportCsv -InputObject ($assignments | Sort-Object PolicyType, PolicyName) -Path $csvPath | Out-Null

    Write-Log -Level Info -Message ("Exported {0} assignments to {1}" -f $assignments.Count, $csvPath) -Source "Export-AssignedPolicies" -LogPath $LogPath
    return [pscustomobject]@{
        Script = "Export-AssignedPolicies"
        CsvPath = $csvPath
        Rows = $assignments.Count
    }
}
catch {
    Write-Log -Level Error -Message $_.Exception.Message -Source "Export-AssignedPolicies" -LogPath $LogPath
    throw
}
