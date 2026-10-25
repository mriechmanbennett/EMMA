function Get-EventLogClixml {
    <#
    .SYNOPSIS
        Get Windows event log data from a computer and return as a clixml string

    .DESCRIPTION
        Get Windows event log data from a computer and return as a clixml string.
        This is needed only to abstract away the actual PSRemoting/RPC stuff.

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

        # Strongly type the output object to make my monkey brain happy
        [string]$OutputXml = ''
    }

    PROCESS {
        foreach ( $Computer in $ComputerName ) {
			Write-Verbose "[PROCESS] Process $Item at $(Get-Date)"
		}
    }

    END {

        # The .Net object works in Core as well, but avoiding it lets the
        # non-verbose script work in constrained language mode (i think)
        if ('Desktop' -eq $PSEdition) {
            $OutputXml = [System.Management.Automation.PSSerializer]::Serialize($myObject, 10)
        }
        else {
            $OutputXml = ConvertTo-CliXml $OutputObject
        }

        Write-Output $OutputXml

        # Verbose stuff
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
