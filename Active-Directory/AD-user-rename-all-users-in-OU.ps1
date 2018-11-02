$users = Get-ADUser -SearchBase "OU=Users,OU=Locations,dc=domain,dc=com" -Server dc.domain.com -Filter * -ResultSetSize 5000 

foreach ($user in $users) {

    Get-ADUser $user.distinguishedName -Server dc.domain.com -Properties Name,SamAccountName
    Rename-ADObject $user.DistinguishedName -Server dc.domain.com -NewName $user.SamAccountName -Verbose

}
