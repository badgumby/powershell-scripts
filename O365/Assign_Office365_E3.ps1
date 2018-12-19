$monthDayYear = Get-Date -format "MMddyyy"
$timeRan = Get-Date -format "MMddyyy.HH.mm"
$path = "C:\scheduled-tasks\assign-licenses\Logs\"

# Check for existing file, if not found, create it
$fileExists = Test-Path $path$monthDayYear.txt -PathType Leaf
if ($fileExists -eq $true) {
    Add-Content -path $path$monthDayYear.txt ""
    Add-Content -path $path$monthDayYear.txt ""
    Add-Content -path $path$monthDayYear.txt "US Office365 E3 - $timeRan"
} else {
    New-Item -path $path -Name $monthDayYear.txt -ItemType "file" -Value $monthDayYear
    Add-Content -path $path$monthDayYear.txt ""
    Add-Content -path $path$monthDayYear.txt  "US Office365 E3 - $timeRan"
}


$domain = "domain.com"
$groupName = "Assign_Office365_E3"

$group = Get-ADGroup -Identity $groupName -Server $domain
$groupMembers = Get-ADGroup -Identity $groupName -Server $domain | Get-ADGroupMember -server $domain

$userList = @()
 foreach ($member in $groupMembers) {
    $userinfo = ""
    $userList+= $member
}

if (!$userList) {

    Add-Content -path $path$monthDayYear.txt "No users to assign licenses."

} else {

    Add-Content -path $path$monthDayYear.txt "We got some peeps!"

    Import-Module MsOnline
    # Retrieve secured credentials
    $credentials = Get-StoredCredential -Target Office365

    # Connect MSOnline
    Connect-MsolService -Credential $credentials

    #Create new license SKU definition (Only Exchange Online, Sharepoint Online, Office Online, Office 365 ProPlus)
    $ExchangeOnlineSku = New-MsolLicenseOptions -AccountSkuId tenant:ENTERPRISEPACK -DisabledPlans FORMS_PLAN_E3,STREAM_O365_E3,Deskless,FLOW_O365_P2,POWERAPPS_O365_P2,TEAMS1,PROJECTWORKMANAGEMENT,SWAY,INTUNE_O365,YAMMER_ENTERPRISE,RMS_S_ENTERPRISE,MCOSTANDARD

    #Loop thru array, set location and assign license
    foreach ($user in $userList | Sort-Object) {

        # Set Location (gets location from child domain DN)
        if ($user.distinguishedName -ilike "*DC=canada,DC=domain,DC=com") {
            $location = "CA"
            $userdomain = "canada.domain.com"
        } elseif ($user.distinguishedName -ilike "*DC=china,DC=domain,DC=com") {
            $location = "CN"
            $userdomain = "china.domain.com"
        }  elseif ($user.distinguishedName -ilike "*DC=mexico,DC=domain,DC=com") {
            $location = "MX"
            $userdomain = "mexico.domain.com"
        }  else {
            $location = "US"
            $userdomain = "domain.com"
        }

        $person = Get-ADUser -Identity $user -Server $userdomain | Select UserPrincipalName, distinguishedName

        Set-MsolUser -UserPrincipalName $person.UserPrincipalName -UsageLocation $location -Verbose
        Set-MsolUserLicense -UserPrincipalName $person.UserPrincipalName -AddLicenses tenant:ENTERPRISEPACK -LicenseOptions $ExchangeOnlineSku -Verbose
        $status = Get-MsolUser -UserPrincipalName $person.UserPrincipalName | select isLicensed

        if ($status.IsLicensed -eq "True") {

            Add-Content -path $path$monthDayYear.txt "License assigned successfully to $($person.UserprincipalName)"
            # Remove from assign group and set hidden attribute to false
            Set-ADObject -Identity $group.distinguishedName -Remove @{member=$person.DistinguishedName} -Confirm:$false
            Set-ADUser -Identity $user.distinguishedName -Server $userdomain -Replace @{msExchHideFromAddressLists=$false} -Confirm:$false

        } else {

            Add-Content -path $path$monthDayYear.txt "License failed to assign on user $($person.UserprincipalName)"

        }
    }

}
