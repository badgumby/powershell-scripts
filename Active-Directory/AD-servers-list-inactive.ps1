#Find the inactive computers
$inactiveComputers = Search-ADAccount -ComputersOnly -AccountInactive -TimeSpan "61" -SearchBase "OU=Servers,dc=domain,dc=com"


#Loop through computers
$servers = @()
ForEach ($computer in $inactiveComputers | Sort-Object) {
    $servers+= [pscustomobject]@{
        Name=$computer.Name
        LastLogonTimestamp=$computer.lastLogonDate
        DN=$computer.DistinguishedName
        }
}

$servers | export-csv c:\Temp\Inactive-Servers.csv -NoTypeInformation
