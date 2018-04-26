Get-ADUser -SearchBase "OU=Locations,dc=domain,dc=com" -Filter * -ResultSetSize 5000 | Select SamAccountName,surname,givenName | export-csv c:\Temp\users-from-ou.csv -NoTypeInformation
