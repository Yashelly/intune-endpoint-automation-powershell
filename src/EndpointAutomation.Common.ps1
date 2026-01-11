<#
.SYNOPSIS
Common helper functions for portfolio scripts.

.DESCRIPTION
Small, dependency-free helpers to keep individual scripts readable and consistent.
Designed for local execution and CI linting/testing.

.NOTES
- No secrets are loaded from disk by default.
- All helpers are non-destructive.
#>

Set-StrictMode -Version Latest

function Get-RepoRoot {
    [CmdletBinding()]
    param()

    # Works when scripts are called directly or from subfolders.
    $root = Resolve-Path (Join-Path $PSScriptRoot "..")
    return $root
}

function New-OutputDirectory {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$OutputPath
    )

    $repoRoot = Get-RepoRoot
    $outDir = Join-Path $repoRoot $OutputPath
    New-Item -ItemType Directory -Force -Path $outDir | Out-Null
    return (Resolve-Path $outDir).Path
}

function Read-JsonConfig {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Path
    )

    if (-not (Test-Path -LiteralPath $Path)) {
        throw "Config file not found: $Path"
    }

    $raw = Get-Content -LiteralPath $Path -Raw -ErrorAction Stop
    return ($raw | ConvertFrom-Json -ErrorAction Stop)
}

function Write-Log {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateSet('Info','Warn','Error')]
        [string]$Level,

        [Parameter(Mandatory)]
        [string]$Message,

        [string]$Source = "",

        [string]$LogPath = ""
    )

    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $src = if ([string]::IsNullOrWhiteSpace($Source)) { "" } else { " [$Source]" }
    $prefix = "[{0}] [{1}]{2} " -f $timestamp, $Level.ToUpperInvariant(), $src
    $line = $prefix + $Message

    switch ($Level) {
        'Info'  { Write-Information $line -InformationAction Continue }
        'Warn'  { Write-Warning $line }
        'Error' { Write-Error $line -ErrorAction Continue }
    }

    if (-not [string]::IsNullOrWhiteSpace($LogPath)) {
        try {
            $parent = Split-Path -Parent $LogPath
            if (-not [string]::IsNullOrWhiteSpace($parent)) {
                $null = New-Item -ItemType Directory -Force -Path $parent -ErrorAction SilentlyContinue
            }
            Add-Content -LiteralPath $LogPath -Value $line -ErrorAction Stop
        }
        catch {
            # Logging should not break report generation.
            Write-Warning ("[Write-Log] Failed to write to log file '{0}': {1}" -f $LogPath, $_.Exception.Message)
        }
    }
}

function Export-ReportCsv {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [object[]]$InputObject,

        [Parameter(Mandatory)]
        [string]$Path
    )

    $parent = Split-Path -Parent $Path
    if (-not [string]::IsNullOrWhiteSpace($parent)) {
        $null = New-Item -ItemType Directory -Force -Path $parent -ErrorAction SilentlyContinue
    }

    # Atomic write: export to temp file first, then move into place.
    $tmp = "$Path.tmp"
    $InputObject | Export-Csv -NoTypeInformation -Encoding UTF8 -Path $tmp -ErrorAction Stop
    Move-Item -Path $tmp -Destination $Path -Force -ErrorAction Stop

    return $Path
}
