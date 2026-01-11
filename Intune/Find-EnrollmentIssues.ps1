<#
.SYNOPSIS
Reports potential enrollment or sync issues for managed devices.

.DESCRIPTION
Portfolio-safe detection logic. Uses sample device state data by design.
In production, replace sample data with Microsoft Graph Intune queries:
- GET /deviceManagement/managedDevices (enrolledDateTime, lastSyncDateTime, managementAgent, etc.)

.PARAMETER StaleSyncHours
Devices with last sync older than this threshold are flagged.

.PARAMETER OutputPath
Relative folder where reports are written (default: out).

.PARAMETER ReportPrefix
Prefix for report file names (default: mw).

.EXAMPLE
.\Find-EnrollmentIssues.ps1 -StaleSyncHours 72 -OutputPath out

.NOTES
- Non-destructive: read-only reporting
- Local execution (User context)
#>

[CmdletBinding()]
param(
    [ValidateRange(1, 8760)]
    [int]$StaleSyncHours = 72,

    [string]$OutputPath = "out",

    [string]$ReportPrefix = "mw",

    [string]$LogPath = ""
)

. (Join-Path (Join-Path $PSScriptRoot "..") "src/EndpointAutomation.Common.ps1")

$ErrorActionPreference = 'Stop'
try {
    $outDir = New-OutputDirectory -OutputPath $OutputPath
    $cutoff = (Get-Date).AddHours(-$StaleSyncHours)

    Write-Log -Level Info -Message ("Finding enrollment/sync issues (StaleSyncHours={0}, Cutoff={1:yyyy-MM-dd HH:mm})" -f $StaleSyncHours, $cutoff) -Source "Find-EnrollmentIssues" -LogPath $LogPath

    # --- Sample data (portfolio) ---
    $records = @(
        [pscustomobject]@{ DeviceName="WIN-001"; User="robertas@example.com"; Enrolled=$true;  LastSync=(Get-Date).AddHours(-8);   EnrollmentType="Autopilot";  Notes=$null }
        [pscustomobject]@{ DeviceName="WIN-002"; User="bob@example.com";      Enrolled=$true;  LastSync=(Get-Date).AddHours(-120); EnrollmentType="Company Portal"; Notes="No recent sync" }
        [pscustomobject]@{ DeviceName="IOS-003"; User="alice@example.com";    Enrolled=$false; LastSync=$null;                     EnrollmentType="Unknown";    Notes="Enrollment incomplete" }
    )
    # -------------------------------

    $issues = foreach ($r in $records) {
        $syncStale = if ($r.LastSync) { $r.LastSync -lt $cutoff } else { $true }
        $enrollmentIssue = -not $r.Enrolled

        if ($syncStale -or $enrollmentIssue) {
            [pscustomobject]@{
                DeviceName      = $r.DeviceName
                User            = $r.User
                Enrolled        = $r.Enrolled
                LastSync        = $r.LastSync
                EnrollmentType  = $r.EnrollmentType
                SyncStale       = $syncStale
                EnrollmentIssue = $enrollmentIssue
                Notes           = $r.Notes
            }
        }
    }

    $csvPath = Join-Path $outDir ("{0}-intune-enrollment-issues.csv" -f $ReportPrefix)
    Export-ReportCsv -InputObject ($issues | Sort-Object EnrollmentIssue -Descending, SyncStale -Descending, DeviceName) -Path $csvPath | Out-Null

    Write-Log -Level Info -Message ("Exported {0} issues to {1}" -f $issues.Count, $csvPath) -Source "Find-EnrollmentIssues" -LogPath $LogPath
    return [pscustomobject]@{
        Script = "Find-EnrollmentIssues"
        CsvPath = $csvPath
        Rows = $issues.Count
    }
}
catch {
    Write-Log -Level Error -Message $_.Exception.Message -Source "Find-EnrollmentIssues" -LogPath $LogPath
    throw
}
