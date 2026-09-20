function Get-RDPLog {
	<#
    .SYNOPSIS
        Pull RDP logs from a computer

    .DESCRIPTION
        Pull RDP logs from a computer

    .PARAMETER ComputerName
        Computer from which to retrieve logs. Defaults to the local device

    .PARAMETER Limit
        Specify the number of most recent results to return

    .EXAMPLE
        Get-RDPLog

    .EXAMPLE
        Get-RDPLog -ComputerName remote-host

		Gets logs from computer named 'remote-host'

    .LINK
        https://github.com/mriechmanbennett/EMMA/

    #>
	[CmdletBinding()]
	param(
		[Parameter(
			Mandatory = $false,
			ValueFromPipeline = $true,
			Position = 0
		)]
		[string[]]$ComputerName = $env:COMPUTERNAME
	)

	#------------ Script start ------------#
	BEGIN {
		$FunctionName = "Get-RDPLog"
		$IsVerbose = $PSCmdlet.MyInvocation.BoundParameters['Verbose'].IsPresent
		if ($IsVerbose) {
			$StartTime = Get-Date
			$CurrentID = [System.Security.Principal.WindowsIdentity]::GetCurrent()
			$IsAdmin = [System.Security.Principal.WindowsPrincipal]::new($CurrentID).IsInRole('administrators')
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
		foreach ( $Computer in $ComputerName ) {
			Write-Verbose "[PROCESS] Process $Item at $(Get-Date)"
			Invoke-Command  {
				Get-WinEvent -FilterHashtable (
					@{
						Logname = 'Microsoft-Windows-TerminalServices-RemoteConnectionManager/Operational';
						ID      = 1149;
					}
				) 
			}
		}
	}

	END {
		if ($IsVerbose) {
			$EndTime = Get-Date
			$TimeSpan = New-TimeSpan -Start $StartTime -End $EndTime
		}
		Write-Verbose "[END    ] EndTime = $EndTime"
		Write-Verbose "[END    ] RunTime = $TimeSpan"
		Write-Verbose "[END    ] $FunctionName"
	}

}
