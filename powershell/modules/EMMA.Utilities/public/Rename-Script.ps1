function Rename-Script {
    <#
    .SYNOPSIS
        Rename an existing script file created with New-Script

    .DESCRIPTION
        Rename an existing script file created with New-Script

    .PARAMETER Path
        Path of the script file to rename

    .PARAMETER NewName
        New name for the script/cmdlet

    .EXAMPLE
        Rename-Script Old-Name.ps1 New-Name.ps1

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

    $OldName = ((Get-Item $Path).Name).Replace(".ps1","")

    Get-Content -ReadCount 0 -Path $Path | ForEach-Object { $_ -replace $OldName, $NewName } | Set-Content -Path $Path
    Rename-Item -Path $Path -NewName "$NewName.ps1"
}
