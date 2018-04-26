#Get current mailbox copy settings
Get-Mailbox MailboxName | Select MessageCopyForSentAsEnabled,MessageCopyForSendOnBehalfEnabled


#Set sent copy settings
Set-Mailbox MailboxName -MessageCopyForSentAsEnabled $true -MessageCopyForSendOnBehalfEnabled $true
