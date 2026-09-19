function Split-TextFile {
    <#
    .SYNOPSIS
        Script to split a text file into separate smaller files

    .DESCRIPTION
        Script to split a text file into separate smaller files.

    .PARAMETER Path
        Path of the input file to split up

    .PARAMETER MaxSize
        Maximum size of the output files in MB

    .EXAMPLE
        Split-TextFile Stuff.log

    .EXAMPLE
        Split-TextFile -Path Stuff.log -MaxSize 500

    .LINK
        https://www.github.com/mriechmanbennett/EMMA/

    #>
    [CmdletBinding()]
    param(
        [Parameter(
            Mandatory=$true,
            ValueFromPipeline=$true,
            Position=0
            )]
        [string[]]$Path,

        [Parameter(
            Mandatory=$false,
            ValueFromPipeline=$false
            )]
        [int]$MaxSize = 500,

        [Parameter(
            Mandatory=$false,
            ValueFromPipeline=$false
            )]
        [string]$Destination = $PWD
    )

    #------------ Script start ------------#
    BEGIN {
        $FunctionName = "Split-TextFile"
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

        # Calculate the max size in bytes from MB
        $MaxSizeBytes = $MaxSize * 1MB

        # Try to create destination path if it does not exist
        if (!(Test-Path $Destination)) { New-Item -Path $Destination -ItemType Directory | Out-Null }
    }

    PROCESS {
        foreach ( $Item in $Path ) {
			Write-Verbose "[PROCESS] Process $Item at $(Get-Date)"

            # Test if source file exists
            if (!(Test-Path -PathType Leaf -Path $Item)) { Write-Error "Specified file does not exist"; break }
            $FullItemPath = Get-Item -Path $Item | Select-Object FullName

            # Get current file name
            $CurrentItemName = Split-Path -Path $FullItemPath -Leaf
            Write-Verbose "[PROCESS] CurrentItemName $FullItemPath"

            # Process the file
            # Initialize stream reader
            $reader = [System.IO.StreamReader]::new($FullItemPath)
            if ($reader -eq $null) { Write-Verbose "[PROCESS] Stream reader was null"; break }
            $chunkNumber = 1
            $currentFile = "$Destination\Split_$CurrentItemName`_$chunkNumber.txt"
            $writer = [System.IO.StreamWriter]::new($currentFile, $false)
            $currentSize = 0

            # Process file
            while (!$reader.EndOfStream) {
                $line = $reader.ReadLine()
                $lineBytes = [System.Text.Encoding]::UTF8.GetByteCount($line + [Environment]::NewLine)
                if ($currentSize + $lineBytes -gt $MaxSizeBytes) {
                    # Close current file and start a new one
                    $writer.Close()
                    $chunkNumber++
                    Write-Verbose "[PROCESS] Max size reached while writing $currentFile"
                    $currentFile = "$Destination\Split_$CurrentItemName`_$chunkNumber.txt"
                    Write-Verbose "[PROCESS] Starting $currentFile"
                    $writer = [System.IO.StreamWriter]::new($currentFile, $false)
                    $currentSize = 0
                } $writer.WriteLine($line)
                $currentSize += $lineBytes
            }
            # Clean up the objects we're finished with
            $writer.Close()
            $reader.Close()

            Write-Verbose "[PROCESS] Finished splitting $CurrentItemName"
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
