function Get-LoadedDrivers {
    <#
    .SYNOPSIS
        Synopsis for new script

    .DESCRIPTION
        Description for new script

    .PARAMETER Example
        Example parameter

    .PARAMETER Example2
        Example2 parameter, uses ValidateSet

    .EXAMPLE
        Get-LoadedDrivers

    .EXAMPLE
        Get-LoadedDrivers -Example example

    .LINK
        https://www.github.com/mriechmanbennett/EMMA/

    #>
    [CmdletBinding()]
    param(
        [Parameter(
            Mandatory=$false,
            ValueFromPipeline=$true,
            Position=0
            )]
        [string[]]$ComputerName = $env:COMPUTERNAME
    )

    #------------ Script start ------------#
    BEGIN {
        $FunctionName = "Get-LoadedDrivers"
		$StartTime = Get-Date
        $CurrentID = [System.Security.Principal.WindowsIdentity]::GetCurrent()
        $IsAdmin = [System.Security.Principal.WindowsPrincipal]::new($CurrentID).IsInRole('administrators')
		Write-Verbose "[BEGIN  ] Starting:   $FunctionName"
        Write-Verbose "[BEGIN  ] User:       $CurrentID.Name"
        Write-Verbose "[BEGIN  ] Computer    $env:COMPUTERNAME"
        Write-Verbose "[BEGIN  ] Is Admin:   $IsAdmin"
        Write-Verbose "[BEGIN  ] OS:         $((Get-CimInstance Win32_Operatingsystem).Caption)"
        Write-Verbose "[BEGIN  ] OS Version: $((Get-CimInstance Win32_Operatingsystem).Version)"
		Write-Verbose "[BEGIN  ] StartTime = $StartTime"
    }

    PROCESS {
        foreach ( $Computer in $ComputerName ) {
			Get-CimInstance Win32_SystemDriver -ComputerName $Computer | Where {$_.State -like "*running*"} | Select DisplayName, PathName
		}
    }

    END {
        $EndTime = Get-Date
		$TimeSpan = New-TimeSpan -Start $StartTime -End $EndTime
		Write-Verbose "[END    ] EndTime = $EndTime"
		Write-Verbose "[END    ] RunTime = $TimeSpan"
		Write-Verbose "[END    ] $FunctionName"
    }

}
