$users = Get-ADGroup -SearchBase "OU=SomeOU,dc=domain,dc=com" -Filter * -ResultSetSize 5000
$info = @()

foreach ($user in $users) {

    $info += Get-ADGroup $user.distinguishedName -Properties Name

}

$info

$info | export-csv "C:\groups.csv"
