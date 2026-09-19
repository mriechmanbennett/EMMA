<#
.SYNOPSIS
    Generate markdown documentation for the project

.DESCRIPTION
    Generate markdown documentation for the project
    Uses the PlatyPS module to dynamically document the project's
    Powershell modules. This script is brittle; it is only intended
    to work within the context of this project.

.PARAMETER NoForce
    Switch parameter; prevent overwriting existing files

.PARAMETER Clean
    Remove documentation files for modules and commands no longer present in the module.

.EXAMPLE
    Build-Documentation

.EXAMPLE
    Build-Documentation -NoForce

.LINK
    https://github.com/mriechmanbennett/EMMA/

#>
[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [switch]$NoForce,

    [Parameter(Mandatory=$false)]
    [switch]$Clean
)

#------------ Script start ------------#

# Install PlatyPS
# Install-PSResource -Name Microsoft.PowerShell.PlatyPS
try { Import-Module -Name Microsoft.PowerShell.PlatyPS }
catch { Write-Host "platyPS module could not be imported"; exit }
finally { Write-Host "Imported platyPS module" }

# Set file paths
$RepositoryPath = (Get-Item -Path $PSScriptRoot).Parent
$DocsPath = "$RepositoryPath\docs"
$PSModuleDocsPath = "$DocsPath\powershell-module-docs"
$PSModulesFolderPath = "$RepositoryPath\powershell\modules"

# Get list of modules and import them to this session
$ModuleList = @( (Get-ChildItem -Path $PSModulesFolderPath -Directory).BaseName )

if ($Clean) {
    Get-ChildItem -Path $PSModuleDocsPath | Remove-Item -Recurse
}

# Write module documentation
foreach ($ModuleName in $ModuleList) {
    $newMarkdownCommandHelpSplat = @{
        ModuleInfo = Get-Module -Name $ModuleName
        OutputFolder = $PSModuleDocsPath
        WithModulePage = $true
        Force = $true
    }
    New-MarkdownCommandHelp @newMarkdownCommandHelpSplat
}

# Write parent README.md
$NewReadme = @"
# EMMA Powershell Modules

Documentation for project Powershell modules.

This README and docs are managed via [script](../../scripts-meta/Build-Documentation.ps1)

## Index


"@

foreach ($ModuleName in $ModuleList) {
    $NewReadme += "- [$ModuleName](./$ModuleName/$ModuleName.md)" + [Environment]::NewLine
}

Set-Content -Force -Path "$PSModuleDocsPath\README.md" -Value $NewReadme -NoNewLine