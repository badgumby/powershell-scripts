#Get-Mailbox -ResultSize unlimited | Select WindowsEmailAddress | export-csv c:\users\username\desktop\users.csv -NoTypeInformation
$users = import-csv c:\users\username\desktop\users.csv
$users2 = @()
$i = 4
for ($j = $i * 200; $j -lt $i * 200 + 200; $j += 1) {
$users2+=$users[$j].WindowsEmailAddress
}

$csvdata = @()

foreach ($user in $users2){
echo $user
Set-MailboxJunkEmailConfiguration $user -TrustedSendersAndDomains @{Add="trusted@somedomain.com"}
}
