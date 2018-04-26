$creds = Get-Credential -Credential domain\administrator # Do not use the account you are looking for

$compArray = @()
Get-ADComputer -Filter * -SearchBase "OU=Servers,DC=domain,DC=com" | Select DNSHostname | ForEach-Object {
$compArray+= $_
}

$loggedin = @()
foreach ($comp in $compArray) {
    Write-Host $comp.DNSHostname
    Get-WmiObject -Namespace "root\cimv2" -Class Win32_LoggedOnUser -Impersonation 3 -Credential $creds -ComputerName $comp.DNSHostname | ForEach-Object {
        if ($_ -like '*user1*') {
            $loggedin+= $_
            #Write-Host -Object (($_.Antecedent.ToString() -split '[\=\"]')[2] + "\" +  ($_.Antecedent.ToString() -split '[\=\"]')[5]) | export-csv C:\Temp\logged-in-users.csv
        }
    }
}

$loggedin | Select PSComputerName,PATH | export-csv c:\Temp\export-user1.csv -NoTypeInformation
