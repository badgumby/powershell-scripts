#List available licenses
Get-MsolAccountSku

#List sublicenses
$ServicePlans = Get-MsolAccountSku | Where {$_.SkuPartNumber -eq "ENTERPRISEPACK"}
$ServicePlans.ServiceStatus

#Create new license SKU definition (Only Exchange Online, Sharepoint Online, Office Online, Office 365 ProPlus)
$ExchangeOnlineSku = New-MsolLicenseOptions -AccountSkuId domain:ENTERPRISEPACK -DisabledPlans FORMS_PLAN_E3,STREAM_O365_E3,Deskless,FLOW_O365_P2,POWERAPPS_O365_P2,TEAMS1,PROJECTWORKMANAGEMENT,SWAY,INTUNE_O365,YAMMER_ENTERPRISE,RMS_S_ENTERPRISE,MCOSTANDARD

#Assign new license SKU
#Set-MsolUser -UserPrincipalName $user -UsageLocation $location
#Set-MsolUserLicense -UserPrincipalName $user -AddLicenses ExitCodeZero:ENTERPRISEPACK -LicenseOptions $ExchangeOnlineSku

#Set region
$location = "US"

#Set license type
#$license = "domain:EXCHANGESTANDARD"

#Array of users to assign licenses
$users = @()
$users += Get-ADUser -Filter * -SearchBase "OU=Users,OU=Locations,DC=domain,DC=com" | Select UserPrincipalName

#Loop thru array, set location and assign license
ForEach ($user in $users | Sort-Object) {
    Set-MsolUser -UserPrincipalName $user.UserPrincipalName -UsageLocation $location -Verbose
    Set-MsolUserLicense -UserPrincipalName $user.UserPrincipalName -RemoveLicenses domain:ENTERPRISEPACK -Verbose
    Set-MsolUserLicense -UserPrincipalName $user.UserPrincipalName -AddLicenses domain:ENTERPRISEPACK -LicenseOptions $ExchangeOnlineSku -Verbose
}
