# Requires -Version 5.1
# Pester v5+

$ErrorActionPreference = 'Stop'

Describe "Portfolio script quality gates" {

    $scriptFiles = Get-ChildItem -Path $PSScriptRoot\.. -Recurse -Filter *.ps1 |
        Where-Object { $_.FullName -notmatch "\\.git\\" }

    It "All scripts should parse without syntax errors" {
        foreach ($f in $scriptFiles) {
            { [System.Management.Automation.Language.Parser]::ParseFile($f.FullName, [ref]$null, [ref]$null) | Out-Null } | Should -Not -Throw
        }
    }

    It "Scripts should not use Write-Host" {
        foreach ($f in $scriptFiles) {
            (Get-Content -Raw $f.FullName) | Should -Not -Match '\bWrite-Host\b'
        }
    }

    It "Scripts should have comment-based help header" {
        foreach ($f in $scriptFiles) {
            $raw = Get-Content -Raw $f.FullName
            $raw | Should -Match '<#\s*\.SYNOPSIS'
        }
    }

    It "Scripts should use CmdletBinding" {
        foreach ($f in $scriptFiles) {
            $raw = Get-Content -Raw $f.FullName
            $raw | Should -Match '\[CmdletBinding\(\)\]'
        }
    }
}
