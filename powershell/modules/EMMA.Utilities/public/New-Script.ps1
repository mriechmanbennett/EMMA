function New-Script() {
    <#
    .SYNOPSIS
        Create new Powershell script file containing a basic template.

    .DESCRIPTION
        Create new Powershell script file containing a basic template.
        Takes a script name or a path to where the new script file should be created.
        A path name should include the desired script file name itself.

    .PARAMETER ScriptNameOrPath
        First position argument, takes a string with the desired script name or a path
        for the new script file. Path can be relative or absolute.

    .PARAMETER Synopsis
        String that populates the Synopsis text. Defaults to filler.

    .PARAMETER Description
        String that populates the Description text. Defaults to filler.

    .PARAMETER Link
        String that populates the Link text. Defaults to a generic URL.
        If the variable $EM_Var.NewScriptLink is set, it will use that instead.

    .EXAMPLE
        New-Script
        Creates a new script in the current directory with filler default options.

    .EXAMPLE
        New-Script Get-ExampleScript
        Creates a new script in the current directory with the name Get-ExampleScript.ps1.
    
    .EXAMPLE
        New-Script Folder\Here\Get-ExampleScript.ps1
        Creates a new script named Get-ExampleScript at the relative
        path "Folder\Here\Get-ExampleScript.ps1"

    .LINK
        https://github.com/mriechmanbennett/EMMA/

    #>

    [CmdletBinding()]
    param(
        # Name for the new script
        [Parameter(Mandatory=$false, Position=0)]
        [String]$ScriptNameOrPath = 'New-ExampleScript',

        # Synopsis
        [Parameter(Mandatory=$false)]
        [String]$Synopsis = "Synopsis for new script",
            
        # Argument for the manifest description
        [Parameter(Mandatory=$false)]
        [String]$Description = "Description for new script",

        [Parameter(Mandatory=$false)]
        [String]$Link
    )

    
    if ([string]::IsNullOrWhiteSpace($Link)) {
        $Link = if ([string]::IsNullOrEmpty($EM_Var.NewScriptLink)) {
            'https://www.github.com/mriechmanbennett/EMMA/'
        } else {
            $($EM_Var.NewScriptLink)
        }
    }


    # Determine if we were passed a script name or full path for the new script file
    if ( $ScriptNameOrPath.Contains("\") ) {
        # Throw error if path is not syntactically valid
        if ( !(Test-Path -Path $ScriptNameOrPath -IsValid) ) {
            throw "Path is not valid"
        }

        if ( $ScriptNameOrPath.EndsWith(".ps1") ){
            # if this is a path not in the current directory, and it ends with the file name
            $ScriptPath = $ScriptNameOrPath
            $ScriptFileName = Split-Path $ScriptPath -Leaf
            $ScriptName = $ScriptFileName.Trim('.ps1')
            
            # Throw error if the new path does not exist
            $ScriptParentPath = Split-Path $ScriptNameOrPath -Parent
            if ( !(Test-Path -Path $ScriptParentPath) ) {
                throw "Path does not exist"
            }
        }
        else {
            # If this is a path not in the current directory, and ends without .ps1
            throw "Valid .ps1 file name must be specified as part of the path"
        }
    }
    else {
        if ( $ScriptNameOrPath.EndsWith(".ps1") ) {
            # If this is a path in the current directory
            $ScriptName = $ScriptNameOrPath.Trim('.ps1')
            $ScriptPath = $ScriptNameOrPath
        }
        else {
            # If this is the name of a script with no path specified
            $ScriptName = $ScriptNameOrPath
            $ScriptPath = "$ScriptNameOrPath.ps1"
        }
    }


    $ScriptTemplate = @"
function $ScriptName {
    <#
    .SYNOPSIS
        $Synopsis

    .DESCRIPTION
        $Description

    .PARAMETER Example
        Example parameter

    .PARAMETER Example2
        Example2 parameter, uses ValidateSet

    .EXAMPLE
        $ScriptName

    .EXAMPLE
        $ScriptName -Example example

    .LINK
        $Link

    #>
    [CmdletBinding()]
    param(
        [Parameter(
            Mandatory=`$false,
            ValueFromPipeline=`$true,
            Position=0
            )]
        [string[]]`$InputObject = `"ExampleValue`",

        [Parameter(Mandatory=`$false)]
        [ValidateSet('One','Two','Three','All')]
        [string]`$Example2 = 'All'
    )

    #------------ Script start ------------#
    BEGIN {
        `$FunctionName = `"$ScriptName`"
        `$IsVerbose = `$PSCmdlet.MyInvocation.BoundParameters['Verbose'].IsPresent
		if (`$IsVerbose) {
			`$StartTime = Get-Date
			`$CurrentID = [System.Security.Principal.WindowsIdentity]::GetCurrent()
			`$IsAdmin = [System.Security.Principal.WindowsPrincipal]::new(`$CurrentID).IsInRole('administrators')
		}
        Write-Verbose `"[BEGIN  ] Starting:   `$FunctionName`"
        Write-Verbose `"[BEGIN  ] User:       `$CurrentID.Name`"
        Write-Verbose `"[BEGIN  ] Computer    `$env:COMPUTERNAME`"
        Write-Verbose `"[BEGIN  ] Is Admin:   `$IsAdmin`"
        Write-Verbose `"[BEGIN  ] OS:         `$((Get-CimInstance Win32_Operatingsystem).Caption)`"
        Write-Verbose `"[BEGIN  ] OS Version: `$((Get-CimInstance Win32_Operatingsystem).Version)`"
		Write-Verbose `"[BEGIN  ] StartTime = `$StartTime`"
    }

    PROCESS {
        foreach ( `$Item in `$InputObject ) {
			Write-Verbose "[PROCESS] Process `$Item at `$(Get-Date)"
		}
    }

    END {
        if (`$IsVerbose) {
			`$EndTime = Get-Date
			`$TimeSpan = New-TimeSpan -Start `$StartTime -End `$EndTime
		}
		Write-Verbose `"[END    ] EndTime = `$EndTime`"
		Write-Verbose `"[END    ] RunTime = `$TimeSpan`"
		Write-Verbose `"[END    ] `$FunctionName`"
    }

}
"@


    $ScriptTemplate | Out-File -FilePath $ScriptPath
    Write-Output $ScriptPath
}