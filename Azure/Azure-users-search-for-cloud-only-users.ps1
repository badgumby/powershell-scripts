$cloudusers = Get-MsolUser -All | where immutableid -eq $null | Select DisplayName,SignInName,UserPrincipalName,isLicensed,UserType
$cloudusers | export-csv c:\TEMP\cloud-users.csv -NoTypeInformation
