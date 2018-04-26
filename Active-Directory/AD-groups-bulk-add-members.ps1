$group = "group-name"
$users = Get-ADUser -SearchBase "OU=Locations,dc=domain,dc=com" -Filter * -ResultSetSize 5000 | Select SAMAccountName

foreach ($user in $users) {

    $sam = $user.SAMAccountName
    Add-ADGroupMember -Identity $group -Members $sam -verbose

}
