$ouUsers = Get-ADUser -SearchBase "OU=Locations,DC=domain,DC=com" -Filter *

foreach ($user in $ouUsers) {

    Set-ADUser $user.SamAccountName -ChangePasswordAtLogon $true

}
