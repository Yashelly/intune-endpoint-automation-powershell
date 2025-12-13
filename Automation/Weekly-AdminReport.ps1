<#
.SYNOPSIS
Runs a weekly reporting bundle (placeholder-friendly).

.DESCRIPTION
Calls other scripts and consolidates outputs into ./out
#>

param(
  [string]$OutputPath = "out"
)

Write-Host "Running weekly admin report bundle..." -ForegroundColor Cyan

& (Join-Path $PSScriptRoot "..\EntraID\Find-StaleDevices.ps1") -OutputPath $OutputPath
& (Join-Path $PSScriptRoot "..\Intune\Get-DeviceComplianceSummary.ps1") -OutputPath $OutputPath
& (Join-Path $PSScriptRoot "..\Intune\Find-EnrollmentIssues.ps1") -OutputPath $OutputPath

Write-Host "Done. Reports are in ./$OutputPath" -ForegroundColor Green
