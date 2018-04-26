$users = import-csv c:\users\username\desktop\list.csv
$users2 = @()
$i = 6
for ($j = $i * 200; $j -lt $i * 200 + 200; $j += 1) {
$users2+=$users[$j].WindowsEmailAddress
}

$csvdata = @()

foreach ($user in $users2){
echo $user
$csvdata+=Get-MailboxFolderStatistics $user | Where {$_.Name -match “Inbox”} | Select Identity, Name, ItemsInFolder
}

$csvdata | Export-csv c:\users\username\desktop\6.csv -NoTypeInformation
