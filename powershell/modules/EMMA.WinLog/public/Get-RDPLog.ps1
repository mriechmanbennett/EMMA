function Get-RDPLog() {
	<#
    .SYNOPSIS
        Pull RDP logs from a computer

    .DESCRIPTION
        Pull RDP logs from a computer

    .PARAMETER Computer
        Computer from which to retrieve logs. Defaults to the local device

    .PARAMETER Limit
        Specify the number of most recent results to return

    .EXAMPLE
        Get-RDPLog

    .EXAMPLE
        Get-RDPLog -Computer remote-host

		Gets logs from computer named 'remote-host'

    .LINK
        https://github.com/mriechmanbennett/EMMA/

    #>
	[CmdletBinding()]
	param(
		[Parameter(Mandatory = $false, ValueFromPipeline = $true)]
		[String[]]$ComputerName = $env:COMPUTERNAME,

		[Parameter(Mandatory = $false)]
		[Int32]$Limit,

		[Parameter(Mandatory = $false)]
		[PSCredential]$Credential
	)

	BEGIN {
		Write-Verbose "[BEGIN]"
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

		#[xml[]]$xml = $EventLogRecords | Foreach-Object { $_.ToXml() }
		# Turn the records into XML objects to parse
		[xml[]]$xml = foreach ($Record in $EventLogRecords) { $Record.ToXml() }
		$EventData = Foreach ($LogEvent in $xml.Event) {
			$Properties = @{
				PSTypeName = 'EMMA.Log.RDP'
				TimeCreated = (Get-Date ($LogEvent.System.TimeCreated.SystemTime) -Format 'yyyy-MM-dd hh:mm:ss K')
				User        = $LogEvent.UserData.EventXML.Param1
				Domain      = $LogEvent.UserData.EventXML.Param2
				Computer	= $Computer
				Client      = $LogEvent.UserData.EventXML.Param3
			}
			$ThisObject = New-Object -Type PSObject -Property $Properties
			Write-Output $ThisObject
		} 
		Write-Output $EventData
	}

	END {
		Write-Verbose "[END]"
	}
}
