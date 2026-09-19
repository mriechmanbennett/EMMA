function Get-DeviceByPrimaryUser {
    <#
    .SYNOPSIS
        Gets Intune primary devices given a user UPN

    .DESCRIPTION
        Gets Intune primary devices given a user UPN

    .PARAMETER Upn
        User UPN to search for devices

    .EXAMPLE
        Get-DeviceByPrimaryUser

    .EXAMPLE
        Get-DeviceByPrimaryUser username@domain.com
    
    .NOTES
        Original script contributed by Brian L
        Depends on Microsoft.Graph.Beta.DeviceManagement

    .LINK
        https://github.com/mriechmanbennett/EMMA/

    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$Upn
    )

    #------------ Script start ------------#
    #build Results and Data
    $results = @()
    $data = @()
    $upns = @()

    #Connect
    Connect-MgGraph -Scopes "DeviceManagementManagedDevices.Read.All, DeviceManagementConfiguration.Read.All"

    # usernames to search for
    $upns = @($Upn)

    #Get Intune Objects Per Device
    $intune_objs = Get-MGBetaDeviceManagementManagedDevice -All
    ForEach ($intune_obj in $intune_objs) {
        If ($intune_obj.UserPrincipalName -ne "") {
            $Primaryuserinfo = Get-MgBetaUserByUserPrincipalName -UserPrincipalName $intune_obj.UserPrincipalName
        }
        else {
            $Primaryuserinfo = ""
        }

        $intunecomps = Get-MgBetaDeviceManagementManagedDeviceCompliancePolicyState -ManagedDeviceId $($intune_obj.Id) | Where-Object { ($_.DisplayName -eq "Default Device Compliance Policy") -and ($_.UserPrincipalName -ne "System account") }

        ForEach ($intunecomp in $intunecomps) {

            $IntuneCompUserInfo = Get-MgBetaUserByUserPrincipalName -UserPrincipalName $intunecomp.UserPrincipalName
            $data += [PSCustomObject]@{
                Intune_Device_Name                  = $Intune_obj.DeviceName
                Intune_Device_Id                    = $Intune_obj.Id
                Intune_LastSync                     = $Intune_obj.LastSyncDateTime
                Intune_PrimaryUser                  = $Intune_obj.UserPrincipalName
                Intune_Comp_LastLogon_UserId        = $intunecomp.UserId
                Intune_Comp_LastLogon_UPN           = $Intunecomp.UserPrincipalName
                Entra_PrimaryUser_Email             = $Primaryuserinfo.Mail
                Entra_PrimaryUser_DistinguishedName = $Primaryuserinfo.OnPremisesDistinguishedName
                Entra_PrimaryUser_JobTitle          = $Primaryuserinfo.JobTitle
                Entra_CompUser_Email                = $IntuneCompUserInfo.Mail
                Entra_CompUser_DistinguishedName    = $IntuneCompUserInfo.OnPremisesDistinguishedName
                Entra_CompUser_JobTitle             = $IntuneCompUserInfo.JobTitle
                Entra_CompUser_UPN                  = $IntuneCompUserInfo.UserPrincipalName
                Entra_CompUser_UserId               = $intunecomp.UserId
            }
        }
    }

    # Build output object and write out
    ForEach ($upn in $upns) {
        $results += $data | Where-Object { ($_.Intune_PrimaryUser -eq $upn) -or ($_.Intune_Comp_LastLogon_UPN -eq $upn) }
    }

    $results | Out-GridView
}
