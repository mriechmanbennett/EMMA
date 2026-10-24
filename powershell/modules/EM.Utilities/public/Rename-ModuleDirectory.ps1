function Rename-ModuleDirectory {
    <#
    .SYNOPSIS
        Rename a module directory created with New-ModuleDirectory

    .DESCRIPTION
        Rename a module directory created with New-ModuleDirectory
        Takes a path to the module directory
        Updates the folder and file names and updates the module name within files.

    .PARAMETER Path
        Example parameter

    .EXAMPLE
        Rename-ModuleDirectory Test-Module

    .LINK
        https://github.com/mriechmanbennett/EMMA/

    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$True,Position=0)]
        [string]$Path,

        [Parameter(Mandatory=$True,Position=1)]
        [string]$NewName
    )

    #------------ Script start ------------#

    # Exit script if Path is invalid
    if ( !(Test-Path $Path) ) {
        Write-Error "Path does not exist $Path"
        exit
    }

    $OldName = (Get-Item $Path).Name

    Get-Content -ReadCount 0 -Path "$Path/$OldName.psd1" | ForEach-Object { $_ -replace $OldName, $NewName } | Set-Content -Path "$Path/$OldName.psd1"

    Rename-Item -Path "$Path/$OldName.psm1" -NewName "$NewName.psm1"
    Rename-Item -Path "$Path/$OldName.psd1" -NewName "$NewName.psd1"
    Rename-Item -Path $Path -NewName $NewName

}
