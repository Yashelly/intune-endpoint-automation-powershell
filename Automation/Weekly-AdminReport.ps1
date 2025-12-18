<#
.SYNOPSIS
Runs a weekly reporting bundle (portfolio-safe).

.DESCRIPTION
Executes selected Entra ID and Intune reporting scripts and writes outputs to a single folder.

Designed for:
- local execution
- Scheduled Task
- CI smoke run (optional)

Not designed for Intune "Proactive Remediations" (no detect/remediate split).

.PARAMETER OutputPath
Relative folder where reports are written (default: out).

.PARAMETER ReportPrefix
Prefix for report file names (default: mw).

.EXAMPLE
.\Weekly-AdminReport.ps1 -OutputPath out -ReportPrefix mw

.NOTES
- Non-destructive: reporting only
#>

[CmdletBinding()]
param(
    [string]$OutputPath = "out",
    [string]$ReportPrefix = "mw"
)

. (Join-Path (Join-Path $PSScriptRoot "..") "src/EndpointAutomation.Common.ps1")

$ErrorActionPreference = "Stop"

try {
    Write-Log -Level Info -Message "Running weekly reporting bundle..."

    & (Join-Path $PSScriptRoot "..\EntraID\Find-StaleDevices.ps1") -OutputPath $OutputPath -ReportPrefix $ReportPrefix | Out-Null
    & (Join-Path $PSScriptRoot "..\Intune\Get-DeviceComplianceSummary.ps1") -OutputPath $OutputPath -ReportPrefix $ReportPrefix | Out-Null
    & (Join-Path $PSScriptRoot "..\Intune\Find-EnrollmentIssues.ps1") -OutputPath $OutputPath -ReportPrefix $ReportPrefix | Out-Null
    & (Join-Path $PSScriptRoot "..\Intune\Export-AssignedPolicies.ps1") -OutputPath $OutputPath -ReportPrefix $ReportPrefix | Out-Null
    & (Join-Path $PSScriptRoot "..\EntraID\Export-GroupMembers.ps1") -OutputPath $OutputPath -ReportPrefix $ReportPrefix | Out-Null
    & (Join-Path $PSScriptRoot "..\EntraID\Find-OrphanedUsers.ps1") -OutputPath $OutputPath -ReportPrefix $ReportPrefix | Out-Null

    Write-Log -Level Info -Message ("Done. Reports are in ./{0}" -f $OutputPath)
    exit 0
}
catch {
    Write-Log -Level Error -Message $_.Exception.Message
    exit 1
}
