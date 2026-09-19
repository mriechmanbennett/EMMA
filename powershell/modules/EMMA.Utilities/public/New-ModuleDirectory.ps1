function New-ModuleDirectory() {
    <#
    .SYNOPSIS
        Create a new Powershell module directory skeleton

    .DESCRIPTION
        Create a new Powershell module directory skeleton
        Uses a template module file. Currently very fragile and needs fixed.

    .PARAMETER ModuleName
      Name of the new module

    .EXAMPLE
        New-ModuleDirectory TestModule

    .LINK
        https://github.com/mriechmanbennett/security-admin-tools/

    #>
    [CmdletBinding()]
    param(
        # Name for the new module
        [Parameter(Mandatory=$true, Position=0)]
        [String]$ModuleName,
    
        # Path for the new module directory to be built in
        # Default path assumes script is run from its location in the git repository
        [Parameter(Mandatory=$false)]
        [String]$ParentPath = (
            (Get-Location).ToString()
        ),
    
        # Argument for the manifest author name
        [Parameter(Mandatory=$false)]
        [String]$Author = "Unknown",
        
        # Argument for the manifest description
        [Parameter(Mandatory=$false)]
        [String]$Description = "New module",
    
        # Argument for the manifest company name
        [Parameter(Mandatory=$false)]
        [String]$CompanyName = "Company name",
    
        # Argument for the manifest starting version
        [Parameter(Mandatory=$false)]
        [String]$ModuleVersion = "0.0.1",
    
        # Argument for CompatiblePSEditions
        [Parameter(Mandatory=$false)]
        [String[]]$CompatiblePSEditions = @('Desktop','Core')
    )
    
    # Set optional $SAT2_Var default values
    if ($Author -eq 'Unknown') {
        if ( !([string]::IsNullOrEmpty($SAT2_Var.AuthorName)) ) {
        $Author = $SAT2_Var.AuthorName
        }
    }
    
    if ($CompanyName -eq 'Company name') {
        if ( !([string]::IsNullOrEmpty($SAT2_Var.CompanyName)) ) {
            $CompanyName = $SAT2_Var.CompanyName
        }
    }
    
    # Variables for files to create
    $NewModulePath = $ParentPath + "\" + $ModuleName
    $NewModuleRootDirectories = @('private','public','files')
    $NewModuleRootFiles = @("$ModuleName.psm1")
    
    # Options for the call to New-ModuleManifest
    $FunctionsToExport = '*'
    $CmdletsToExport = '*'
    $VariablesToExport = '*'
    
    # Break if module directory already exists
    if (Test-Path -Path $NewModulePath) { Write-Output "Module name already exists"; break }
    
    # Create module directory and initial files
    New-Item $NewModulePath -ItemType Directory
    
    Foreach ($DirectoryName in $NewModuleRootDirectories) {
        $ThisPath = $NewModulePath + "\$DirectoryName"
        New-Item -Path $ThisPath -ItemType Directory
    }
    
    Foreach ($FileName in $NewModuleRootFiles) {
        $ThisPath = $NewModulePath + "\$FileName"
        New-Item -Path $ThisPath -ItemType File
    }
    
    # Create manifest file
    New-ModuleManifest  -Path "$NewModulePath\$ModuleName.psd1" `
                        -RootModule "$ModuleName.psm1" `
                        -Description $Description `
                        -ModuleVersion $ModuleVersion `
                        -Author $Author `
                        -CompanyName $CompanyName `
                        -FunctionsToExport $FunctionsToExport `
                        -CmdletsToExport $CmdletsToExport `
                        -VariablesToExport $VariablesToExport `
                        -CompatiblePSEditions $CompatiblePSEditions
    
    # Create root module file
    Get-Content -Path "$PSScriptRoot\..\files\RootModuleTemplate.txt" | Out-File -FilePath "$NewModulePath\$ModuleName.psm1"
}
