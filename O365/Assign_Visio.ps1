$monthDayYear = Get-Date -format "MMddyyy"
$timeRan = Get-Date -format "MMddyyy.HH.mm"
$path = "C:\scheduled-tasks\assign-licenses\Logs\"

# Check for existing file, if not found, create it
$fileExists = Test-Path $path$monthDayYear.txt -PathType Leaf
if ($fileExists -eq $true) {
    Add-Content -path $path$monthDayYear.txt ""
    Add-Content -path $path$monthDayYear.txt ""
    Add-Content -path $path$monthDayYear.txt "Visio - $timeRan"
} else {
    New-Item -path $path -Name $monthDayYear.txt -ItemType "file" -Value $monthDayYear
    Add-Content -path $path$monthDayYear.txt ""
    Add-Content -path $path$monthDayYear.txt  "Visio - $timeRan"
}


$domain = "domain.com"
$groupName = "Assign_Visio"

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

    #Loop thru array, set location and assign license
    foreach ($user in $userList | Sort-Object) {

        $person = Get-ADUser -Identity $user | Select UserPrincipalName,DistinguishedName
        #Add-Content -path $path$monthDayYear.txt $person.UserPrincipalName
        $statusOffice = Get-MsolUser -UserPrincipalName $person.UserPrincipalName | select isLicensed
        #Add-Content -path $path$monthDayYear.txt $status

        if ($statusOffice.IsLicensed -eq "True") {

            Set-MsolUserLicense -UserPrincipalName $person.UserPrincipalName -AddLicenses tenant:VISIOCLIENT -Verbose
            $statusVisio = Get-MsolUser -MaxResults 5000 | Where-Object {($_.licenses).AccountSkuId -match "VISIOCLIENT" -and $_.UserPrincipalName -eq $person.UserPrincipalName}

            if ($statusVisio.IsLicensed -eq "True") {

                Add-Content -path $path$monthDayYear.txt "License assigned successfully to $($person.UserprincipalName)"
                # Remove from assign group and set hidden attribute to false
                #Remove-ADGroupMember -Identity $groupName -Members $person.DistinguishedName -Confirm:$false
                Set-ADObject -Identity $group.distinguishedName -Remove @{member=$person.DistinguishedName}
            } else {

                 Add-Content -path $path$monthDayYear.txt "License assigned failed for user $($person.UserprincipalName)"

            }

        } else {
            Add-Content -path $path$monthDayYear.txt "$($person.UserprincipalName) does not have a base Office365 Email license."
        }
    }

}
