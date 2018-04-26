# Retrieve secured credentials
$credentials = Get-StoredCredential -Target outlook.office365.com

#Connect to EO
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $credentials -Authentication Basic -AllowRedirection
Import-PSSession -Session $Session

#Get-MailboxFolderStatistics user.name@domain.com | Where {$_.Name -match “Inbox”}



Get-Mailbox user.name@domain.com | Get-MailboxFolderStatistics | Where {$_.Name -match “Inbox”} | Select Identity, Name, ItemsInFolder | Export-csv c:\users\username\desktop\All-MailboxItemCountInbox2.csv

# Get-Mailbox -resultsize 10 | Get-MailboxFolderStatistics | Where {$_.Name -match “Inbox”} | Select Identity, Name, ItemsInFolder

# Disconnect from EO
Remove-PSSession $Session
