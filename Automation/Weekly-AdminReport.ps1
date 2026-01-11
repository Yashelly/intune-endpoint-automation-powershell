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

.PARAMETER ConfigPath
Optional JSON config file. If provided, values are used as defaults.

.PARAMETER LogPath
Optional log file path. If not specified, a log file is created in the output folder.
#>

[CmdletBinding()]
param(
    [string]$OutputPath = "out",
    [string]$ReportPrefix = "mw",
    [string]$ConfigPath = "",
    [string]$LogPath = ""
)

. (Join-Path (Join-Path $PSScriptRoot "..") "src/EndpointAutomation.Common.ps1")

$ErrorActionPreference = 'Stop'

try {
    $outDir = New-OutputDirectory -OutputPath $OutputPath

    if ([string]::IsNullOrWhiteSpace($LogPath)) {
        $LogPath = Join-Path $outDir ("{0}-weekly.log" -f $ReportPrefix)
    }

    $config = $null
    if (-not [string]::IsNullOrWhiteSpace($ConfigPath)) {
        $config = Read-JsonConfig -Path $ConfigPath
    }

    $inactiveDays = if ($config -and $config.InactiveDays) { [int]$config.InactiveDays } else { 90 }

    Write-Log -Level Info -Message ("Starting weekly bundle. Output={0}" -f $outDir) -Source "Weekly-AdminReport" -LogPath $LogPath

    $repoRoot = Get-RepoRoot

    $tasks = @(
        @{
            Name = "Find-StaleDevices"
            Path = (Join-Path (Join-Path $repoRoot "EntraID") "Find-StaleDevices.ps1")
            Args = @{ OutputPath=$OutputPath; ReportPrefix=$ReportPrefix; InactiveDays=$inactiveDays; LogPath=$LogPath }
        },
        @{
            Name = "Get-DeviceComplianceSummary"
            Path = (Join-Path (Join-Path $repoRoot "Intune") "Get-DeviceComplianceSummary.ps1")
            Args = @{ OutputPath=$OutputPath; ReportPrefix=$ReportPrefix; LogPath=$LogPath }
        },
        @{
            Name = "Find-EnrollmentIssues"
            Path = (Join-Path (Join-Path $repoRoot "Intune") "Find-EnrollmentIssues.ps1")
            Args = @{ OutputPath=$OutputPath; ReportPrefix=$ReportPrefix; LogPath=$LogPath }
        },
        @{
            Name = "Export-AssignedPolicies"
            Path = (Join-Path (Join-Path $repoRoot "Intune") "Export-AssignedPolicies.ps1")
            Args = @{ OutputPath=$OutputPath; ReportPrefix=$ReportPrefix; LogPath=$LogPath }
        },
        @{
            Name = "Export-GroupMembers"
            Path = (Join-Path (Join-Path $repoRoot "EntraID") "Export-GroupMembers.ps1")
            Args = @{ OutputPath=$OutputPath; ReportPrefix=$ReportPrefix; LogPath=$LogPath }
        },
        @{
            Name = "Find-OrphanedUsers"
            Path = (Join-Path (Join-Path $repoRoot "EntraID") "Find-OrphanedUsers.ps1")
            Args = @{ OutputPath=$OutputPath; ReportPrefix=$ReportPrefix; LogPath=$LogPath }
        }
    )

    $results = @()
    $hasFailures = $false

    foreach ($t in $tasks) {
        $sw = [System.Diagnostics.Stopwatch]::StartNew()

        try {
            Write-Log -Level Info -Message ("Running {0}" -f $t.Name) -Source "Weekly-AdminReport" -LogPath $LogPath

            $scriptArgs = $t.Args
            $r = & $t.Path @scriptArgs

            $sw.Stop()

            $results += [pscustomobject]@{
                Script          = $t.Name
                Status          = "Success"
                DurationSeconds = [math]::Round($sw.Elapsed.TotalSeconds, 2)
                CsvPath         = $r.CsvPath
                Rows            = $r.Rows
                Error           = ""
            }
        }
        catch {
            $sw.Stop()
            $hasFailures = $true
            $errMsg = $_.Exception.Message

            Write-Log -Level Error -Message ("{0} failed: {1}" -f $t.Name, $errMsg) -Source "Weekly-AdminReport" -LogPath $LogPath

            $results += [pscustomobject]@{
                Script          = $t.Name
                Status          = "Failed"
                DurationSeconds = [math]::Round($sw.Elapsed.TotalSeconds, 2)
                CsvPath         = ""
                Rows            = 0
                Error           = $errMsg
            }
        }
    }

    $summaryPath = Join-Path $outDir ("{0}-weekly-summary.csv" -f $ReportPrefix)
    Export-ReportCsv -InputObject $results -Path $summaryPath | Out-Null

    Write-Log -Level Info -Message ("Summary written to {0}" -f $summaryPath) -Source "Weekly-AdminReport" -LogPath $LogPath

    if ($hasFailures) {
        Write-Log -Level Error -Message "One or more scripts failed." -Source "Weekly-AdminReport" -LogPath $LogPath
        exit 1
    }

    Write-Log -Level Info -Message ("Done. Reports are in ./{0}" -f $OutputPath) -Source "Weekly-AdminReport" -LogPath $LogPath
    exit 0
}
catch {
    Write-Log -Level Error -Message $_.Exception.Message -Source "Weekly-AdminReport" -LogPath $LogPath
    exit 1
}
