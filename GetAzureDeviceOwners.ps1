<#
    .SYNOPSIS
    A PowerShell script that retrieves from Azure AD a list of all users that own compliant devices with the specified OS
    
    .DESCRIPTION
    Connects to Azure AD and retrieves all devices that are compliant and have the specified OS as the OS type. 
    Then retrieves the registered owners of those devices and exports them to a CSV file. 

    .INPUTS
    Doesn't accept any inputs

    .OUTPUTS
    Outputs a CSV file in the same directory the script is run from
#>


#------------------------------------------ Start of main script -----------------------------------------------------#


$targetOS = "Windows"
$currentDate = (Get-Date).ToString("M-d-yyyy-hhmmss")
$exportFilePath = "$($PSScriptRoot)\$($targetOS)_Device_Owners_$($currentDate).csv"
$resultsFound = $false
$azureGroupID = "ed1c9378-3a5e-433d-8fc9-4c9d620d390d"


#-------------------------------------------- Connect to AzureAD ------------------------------------------------------#


try {    

    Write-Verbose "Connecting to AzureAD. This might take a moment..." -Verbose

    # Force TLS 1.2 encryption for compatibility with PowerShell Gallery
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

    # check to see if AzureAD module is installed and install if necessary
    # connect to AzureAD once module is installed

    if ($null -eq (Get-Module -ListAvailable -Name AzureAD)) {

        Write-Verbose "Installing AzureAD module..." -Verbose
        Install-Module AzureAD -Scope CurrentUser -Confirm 

    }      
    
    Connect-AzureAD -AccountId "electric.one@electricalbreakdown.com" -Verbose | Out-Null
    
}

catch {

    Write-Host "`nThere was a problem connecting to AzureAD. Please try again.`n" -ForegroundColor Red
    throw

}


#-------------------------- Search AzureAD for all compliant devices with the specified OS --------------------------------#


$azureDevices = Get-AzureADDevice -All $true | Where-Object {$_.DeviceOSType -eq $targetOS  -and $_.IsCompliant -eq $true}

if($null -ne $azureDevices){
    
    $resultsFound = $true

    $deviceOwners = foreach($device in $azureDevices){
    
        Get-AzureADDeviceRegisteredOwner -ObjectID $device.ObjectId | Select-Object DisplayName, UserPrincipalName, ObjectID    
    
    }

}

else {

    Write-Host "`nThere were no compliant $targetOS devices found.`n"

}


#----------------------------------------------- Export results to CSV ---------------------------------------------------#


if($resultsFound) {

    try  {

        Write-Verbose "Exporting device owners to CSV file..." -Verbose
        $deviceOwners | Select-Object -Property DisplayName, UserPrincipalName, ObjectID -Unique | Sort-Object -Property DisplayName | Export-Csv -Path $exportFilePath
        
        Write-Host "-------------------------------------------------------------------------------"
        Write-Host "All $targetOS device owners have been exported to: $exportFilePath" -ForegroundColor Green
        Write-Host "-------------------------------------------------------------------------------"

    }
     
    catch {

        Write-Host "`nThere was a problem exporting the file. Results have been displayed to the console.`n" -ForegroundColor Red        
        $azureUsers | Select-Object -Property DisplayName, UserPrincipalName, ObjectID -Unique | Sort-Object -Property DisplayName | Format-Table                

    }


    #--------------------------------- Add device owners to Azure group ----------------------------------------------#
    
    
    try{

        Write-Verbose "Adding users to Azure AD group..."
        $azureGroup = Get-AzureADGroup -ObjectId $azureGroupID

        foreach($owner in $deviceOwners) {

            Add-AzureADGroupMember -ObjectId $azureGroupID -RefObjectId $owner.ObjectID        

        }
    
        Write-Host "-------------------------------------------------------------------------------"
        Write-Host "$($deviceOwners.count) users have been added to the $($azureGroup.DisplayName) group." -ForegroundColor Green
        Write-Host "-------------------------------------------------------------------------------"
    }

    catch {

        Write-Host "There was a problem adding users to the $($azureGroup.DisplayName) group." -ForegroundColor Red
        throw

    }
}  # close if block


Read-Host "`nPress Enter key to exit"