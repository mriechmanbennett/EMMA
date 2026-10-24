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
		Foreach ( $Computer in $ComputerName ) {
			$GetWinEventParams = @{
				LogName      = 'Microsoft-Windows-TerminalServices-RemoteConnectionManager/Operational'
				FilterXPath  = '<QueryList><Query Id="0"><Select>*[System[EventID=1149]]</Select></Query></QueryList>'
				ComputerName = $Computer
			}
			if ($Limit) {
				$GetWinEventParams.Add("MaxEvents", $Limit)
			}
			if ($Credential) {
				$GetWinEventParams.Add("Credential", $Credential)
			}
			$EventLogRecords = Get-WinEvent @GetWinEventParams
		}

		# Turn the records into XML objects to parse
		[xml[]]$xml = foreach ($Record in $EventLogRecords) { $Record.ToXml() }
		$EventData = Foreach ($LogEvent in $xml.Event) {
			$Properties = @{
				PSTypeName 		= 'EMMA.Log.RDP'
				TimeCreated 	= (Get-Date ($LogEvent.System.TimeCreated.SystemTime) -Format 'yyyy-MM-dd HH:mm:ss')
				TimeCreatedFull = (Get-Date ($LogEvent.System.TimeCreated.SystemTime) -Format 'yyyy-MM-dd HH:mm:ss K')
				TimeCreatedRawTimestamp = Get-Date ($LogEvent.System.TimeCreated.SystemTime)
				User        	= $LogEvent.UserData.EventXML.Param1
				Domain      	= $LogEvent.UserData.EventXML.Param2
				ComputerName	= $Computer
				Client      	= $LogEvent.UserData.EventXML.Param3
			}
			$ThisObject = New-Object -Type PSObject -Property $Properties
			Write-Output $ThisObject
		} 
		Write-Output $EventData
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
