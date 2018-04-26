Get-ADUser -Filter * -SearchBase “dc=sub1,dc=domain,dc=com” | Measure-Object

$bunn = ""
$bunn = Get-ADUser -Filter * -SearchBase “dc=sub1,dc=domain,dc=com” | Select Surname, GivenName, SamAccountName, name, distinguishedname, enabled

$bunn | Export-Csv c:\Temp\sub1.domain.com.csv





$bunn = ""
$bunn = Get-ADUser -Filter * -Server dc1.sub2.domain.com | Select Surname, GivenName, SamAccountName, name, distinguishedname, enabled

$bunn | Export-Csv c:\Temp\sub2.domain.com.csv -NoTypeInformation
