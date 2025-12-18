<#
.SYNOPSIS
Reports Entra ID devices that appear stale based on last sign-in activity.

.DESCRIPTION
Portfolio-safe, read-only reporting script. Uses a sample dataset by design.
In production, replace the sample dataset with Microsoft Graph queries to:
- GET /devices
- GET /auditLogs/signIns (or device sign-in properties where available)

The script exports a CSV report to the chosen output folder.

.PARAMETER InactiveDays
Devices with last sign-in older than this threshold are considered stale.

.PARAMETER TreatNullLastSignInAsStale
If set, devices with missing last sign-in data are marked as stale for review.

.PARAMETER OutputPath
Relative folder where reports are written (default: out).

.PARAMETER ReportPrefix
Prefix for report file names (default: mw).

.EXAMPLE
.\Find-StaleDevices.ps1 -InactiveDays 90 -OutputPath out -ReportPrefix mw

.NOTES
- Non-destructive: read-only reporting
- Local execution (User context)
#>

[CmdletBinding()]
param(
    [ValidateRange(1, 3650)]
    [int]$InactiveDays = 90,

    [switch]$TreatNullLastSignInAsStale,

    [string]$OutputPath = "out",

    [string]$ReportPrefix = "mw"
)

. (Join-Path (Join-Path $PSScriptRoot "..") "src/EndpointAutomation.Common.ps1")

try {
    $outDir = New-OutputDirectory -OutputPath $OutputPath
    $cutoff = (Get-Date).AddDays(-$InactiveDays)

    Write-Log -Level Info -Message ("Generating stale device report (InactiveDays={0}, Cutoff={1:yyyy-MM-dd})" -f $InactiveDays, $cutoff)

    # --- Sample data (portfolio) ---
    $devices = @(
        [pscustomobject]@{ DisplayName="WIN-001"; DeviceId="0001"; OperatingSystem="Windows"; AccountEnabled=$true;  LastSignIn=(Get-Date).AddDays(-12)  }
        [pscustomobject]@{ DisplayName="WIN-002"; DeviceId="0002"; OperatingSystem="Windows"; AccountEnabled=$true;  LastSignIn=(Get-Date).AddDays(-180) }
        [pscustomobject]@{ DisplayName="MAC-003"; DeviceId="0003"; OperatingSystem="macOS";   AccountEnabled=$true;  LastSignIn=$null                  }
        [pscustomobject]@{ DisplayName="IOS-004"; DeviceId="0004"; OperatingSystem="iOS";     AccountEnabled=$false; LastSignIn=(Get-Date).AddDays(-40)  }
    )
    # -------------------------------

    $report = foreach ($d in $devices) {
        $last = $d.LastSignIn
        $inactive = if ($last) { (New-TimeSpan -Start $last -End (Get-Date)).Days } else { $null }

        $stale =
            if ($last) { $last -lt $cutoff }
            elseif ($TreatNullLastSignInAsStale) { $true }
            else { $false }

        [pscustomobject]@{
            DisplayName     = $d.DisplayName
            DeviceId        = $d.DeviceId
            OperatingSystem = $d.OperatingSystem
            AccountEnabled  = $d.AccountEnabled
            LastSignIn      = $last
            InactiveDays    = $inactive
            IsStale         = $stale
        }
    }

    $csvPath = Join-Path $outDir ("{0}-entra-stale-devices.csv" -f $ReportPrefix)
    Export-ReportCsv -InputObject ($report | Sort-Object IsStale -Descending, InactiveDays -Descending, DisplayName) -Path $csvPath | Out-Null

    $countStale = ($report | Where-Object IsStale).Count
    Write-Log -Level Info -Message ("Exported {0} rows ({1} stale) to {2}" -f $report.Count, $countStale, $csvPath)
    exit 0
}
catch {
    Write-Log -Level Error -Message $_.Exception.Message
    exit 1
}
