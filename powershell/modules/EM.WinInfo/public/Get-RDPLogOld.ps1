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
		[Parameter(Mandatory=$false)]
		[Int32]$Limit,

		[Parameter(Mandatory=$false)]
		[String]$Computer = $env:COMPUTERNAME
	)

	$LogName = 'Microsoft-Windows-TerminalServices-RemoteConnectionManager/Operational' 
    $LogFilter = '<QueryList><Query Id="0"><Select>*[System[EventID=1149]]</Select></Query></QueryList>'

    $RDPAuths = Get-WinEvent -LogName $LogName -FilterXPath $LogFilter -ComputerName $Computer
	
	$Count = 0

    [xml[]]$xml = $RDPAuths | Foreach-Object {$_.ToXml()}
	$EventData = Foreach ($LogEvent in $xml.Event) {
		New-Object PSObject -Property @{
			TimeCreated = (Get-Date ($LogEvent.System.TimeCreated.SystemTime) -Format 'yyyy-MM-dd hh:mm:ss K')
			User = $LogEvent.UserData.EventXML.Param1
			Domain = $LogEvent.UserData.EventXML.Param2
			Client = $LogEvent.UserData.EventXML.Param3
		}
		# If Limit is set, break when we reach it
		if ($Limit) {
			$Count++
			if ($Count -ge $Limit) { break }
		}
	} 
	$EventData | Format-Table
}
