Connect-MsolService

$aduser = "username"
$clouduser = "user.name@domain.onmicrosoft.com"
$guid = (get-aduser $aduser).ObjectGUID
$immutableID = [System.Convert]::ToBase64String($guid.tobytearray())

Get-MSOLuser -UserPrincipalName $clouduser | select ImmutableID
Set-MSOLuser -UserPrincipalName $clouduser -ImmutableID $immutableID
Get-MSOLuser -UserPrincipalName $clouduser | select ImmutableID
