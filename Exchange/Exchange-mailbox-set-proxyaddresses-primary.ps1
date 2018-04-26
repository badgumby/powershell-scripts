#Connect to Exchange Online via Powershell

Set-Mailbox grc@domain.onmicrosoft.com -WindowsEmailAddress infosec@domain.com

#Make user1@domain.onmicrosoft.com the primary (SMTP) proxy address and  user1@domain.com a secondary (smtp) proxy address on my AD user object.
#Perform an Azure AD Connect sync

Set-Mailbox user1@domain.onmicrosoft.com -WindowsEmailAddress user1@domain.com

#Make user1@domain.com the primary (SMTP) proxy address and user1@domain.onmicrosoft.com a secondary (smtp) proxy address on my AD user object
#Perform an Azure AD Connect sync

Set-Mailbox user1@domain.com -EmailAddresses @{remove="user1@domain.onmicrosoft.com"}


#Distribution group default email address
Set-DistributionGroup Group1@domain.onmicrosoft.com -WindowsEmailAddress Group1@domain.com
