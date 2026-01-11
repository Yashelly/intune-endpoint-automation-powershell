<#
.SYNOPSIS
Builds a platform/compliance state summary for managed devices.

.DESCRIPTION
Portfolio-safe reporting script. Uses sample device compliance data by design.
In production, replace sample data with Microsoft Graph Intune queries:
- GET /deviceManagement/managedDevices (select complianceState, operatingSystem, etc.)

.PARAMETER OutputPath
Relative folder where reports are written (default: out).

.PARAMETER ReportPrefix
Prefix for report file names (default: mw).

.EXAMPLE
.\Get-DeviceComplianceSummary.ps1 -OutputPath out -ReportPrefix mw

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
    Write-Log -Level Info -Message "Generating Intune device compliance summary (sample dataset)" -Source "Get-DeviceComplianceSummary" -LogPath $LogPath

    # --- Sample data (portfolio) ---
    $devices = @(
        [pscustomobject]@{ DeviceName="WIN-001"; Platform="Windows"; Compliance="Compliant"     }
        [pscustomobject]@{ DeviceName="WIN-002"; Platform="Windows"; Compliance="Noncompliant" }
        [pscustomobject]@{ DeviceName="IOS-003"; Platform="iOS";     Compliance="Unknown"      }
        [pscustomobject]@{ DeviceName="MAC-004"; Platform="macOS";   Compliance="Compliant"    }
    )
    # -------------------------------

    $summary = $devices |
        Group-Object Platform, Compliance |
        ForEach-Object {
            $platform, $state = $_.Name -split ",\s*"
            [pscustomobject]@{
                Platform   = $platform
                Compliance = $state
                Count      = $_.Count
            }
        } |
        Sort-Object Platform, Compliance

    $csvPath = Join-Path $outDir ("{0}-intune-compliance-summary.csv" -f $ReportPrefix)
    Export-ReportCsv -InputObject $summary -Path $csvPath | Out-Null

    Write-Log -Level Info -Message ("Exported compliance summary to {0}" -f $csvPath) -Source "Get-DeviceComplianceSummary" -LogPath $LogPath
    return [pscustomobject]@{
        Script = "Get-DeviceComplianceSummary"
        CsvPath = $csvPath
        Rows = $summary.Count
    }
}
catch {
    Write-Log -Level Error -Message $_.Exception.Message -Source "Get-DeviceComplianceSummary" -LogPath $LogPath
    throw
}
