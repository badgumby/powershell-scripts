$kblist = @()
Get-WmiObject -query 'select * from win32_quickfixengineering' -ComputerName comp1 -Credential domain\administrator | foreach {$kblist+= $_.hotfixid}
$kblist | export-csv c:\users\user\desktop\kblist2.csv
