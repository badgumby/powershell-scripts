$users = Get-ADUser -SearchBase "OU=Users,dc=domain,dc=com" -Filter * -ResultSetSize 5000
$group = "CN=GroupName,OU=Policy,DC=domain,DC=com"

foreach ($user in $users) {

    $info = Get-ADUser $user.distinguishedName
    Add-ADGroupMember -identity $group -members $info.DistinguishedName

}
