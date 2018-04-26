$users = @()

$users += Get-ADUser -Filter * -SearchBase "OU=Users,OU=Locations,DC=domain,DC=com" | Select UserPrincipalName

ForEach ($user in $users | Sort-Object) {
    $user.UserPrincipalName
    (Get-MsolUser -UserPrincipalName $user.UserPrincipalName).Licenses.AccountSkuId
    echo ""
}
