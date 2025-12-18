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

function Write-Log {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateSet('Info','Warn','Error')]
        [string]$Level,

        [Parameter(Mandatory)]
        [string]$Message
    )

    $prefix = "[{0}] " -f $Level.ToUpperInvariant()

    switch ($Level) {
        'Info'  { Write-Information ($prefix + $Message) -InformationAction Continue }
        'Warn'  { Write-Warning ($prefix + $Message) }
        'Error' { Write-Error ($prefix + $Message) }
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

    $null = Split-Path -Parent $Path | ForEach-Object { New-Item -ItemType Directory -Force -Path $_ } 2>$null
    $InputObject | Export-Csv -NoTypeInformation -Encoding UTF8 -Path $Path
    return $Path
}
