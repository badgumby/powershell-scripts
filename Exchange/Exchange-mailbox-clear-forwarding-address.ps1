'Connecting to Exchange Online'
$credential = Get-Credential
Import-Module MsOnline
Connect-MsolService -Credential $credential
$exchangeSession = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri "https://outlook.office365.com/powershell-liveid/" -Credential $credential -Authentication "Basic" -AllowRedirection
Import-PSSession $exchangeSession -DisableNameChecking -AllowClobber

"`n`n"
Start-Transcript -Path "C:\users\username\desktop\transcript3.txt" -NoClobber
$mailboxes = Get-Mailbox -ResultSize unlimited | Sort-Object WindowsEmailAddress

$excludeUsers = @(
    'user.name@domain.com',
    'user.name2@domain.com',
    'user.name3@domain.onmicrosoft.com'
)

For ($i = 0; $i -lt $excludeUsers.Count; $i += 1) {
    $excludeUsers[$i] = $excludeUsers[$i].ToLower()
}

ForEach ($mailbox in $mailboxes) {
    if (!$excludeUsers.Contains($mailbox.WindowsEmailAddress.ToLower()) -and ($mailbox.ForwardingAddress -or $mailbox.ForwardingSmtpAddress)) {
        $mailbox.WindowsEmailAddress

            Set-Mailbox -Identity $mailbox.Identity -ForwardingAddress $null -ForwardingSmtpAddress $null

    }
}
stop-transcript

#Remove-PSSession $exchangeSession
