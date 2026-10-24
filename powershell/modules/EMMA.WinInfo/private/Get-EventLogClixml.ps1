function Get-EventLogClixml {
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
        Get-EventLogClixml

    .EXAMPLE
        Get-EventLogClixml -Example example

    .LINK
        https://www.github.com/mriechmanbennett/EMMA/

    #>
    [CmdletBinding()]
    param(
        [Parameter(
            Mandatory=$false, ValueFromPipeline=$false)]
        [System.Collections.Hashtable]$FilterHashtable = $FilterHashtable,

        [Parameter(Mandatory = $false, ValueFromPipeline = $true)]
		[Alias('Computer')]
		[String[]]$ComputerName = $env:COMPUTERNAME,

		[Parameter(Mandatory = $false)]
		[Alias('MaxEvents')]
		[Int32]$Limit,

		[Parameter(Mandatory = $false)]
		[PSCredential]$Credential
    )

    #------------ Script start ------------#
    BEGIN {
        $FunctionName = "Get-EventLogClixml"
        $IsVerbose = $PSCmdlet.MyInvocation.BoundParameters['Verbose'].IsPresent
		if ($IsVerbose) {
			$StartTime = Get-Date
			$CurrentID = [System.Security.Principal.WindowsIdentity]::GetCurrent()
			$IsAdmin = [System.Security.Principal.WindowsPrincipal]::new($CurrentID).IsInRole('administrators')
            $Stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
		}
        Write-Verbose "[BEGIN  ] Starting:   $FunctionName"
        Write-Verbose "[BEGIN  ] User:       $CurrentID.Name"
        Write-Verbose "[BEGIN  ] Computer    $env:COMPUTERNAME"
        Write-Verbose "[BEGIN  ] Is Admin:   $IsAdmin"
        Write-Verbose "[BEGIN  ] OS:         $((Get-CimInstance Win32_Operatingsystem).Caption)"
        Write-Verbose "[BEGIN  ] OS Version: $((Get-CimInstance Win32_Operatingsystem).Version)"
		Write-Verbose "[BEGIN  ] StartTime = $StartTime"
    }

    PROCESS {
        foreach ( $Item in $InputObject ) {
			Write-Verbose "[PROCESS] Process $Item at $(Get-Date)"
		}
    }

    END {
        if ($IsVerbose) {
            $Stopwatch.Stop()
			$EndTime = Get-Date
			$TimeSpan = $Stopwatch.Elapsed
		}
		Write-Verbose "[END    ] EndTime = $EndTime"
		Write-Verbose "[END    ] RunTime = $TimeSpan"
		Write-Verbose "[END    ] $FunctionName"
    }

}
