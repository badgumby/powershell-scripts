Set-MailboxJunkEmailConfiguration user.name@domain.com -TrustedSendersAndDomains @{Add="allowed@somedomain.com"}

Get-MailboxJunkEmailConfiguration user.name@domain.com | select TrustedSendersAndDomains,BlockedSendersAndDomains,TrustedRecipientsAndDomains | FL


#Updating an existing list
$Temp = Get-MailboxJunkEmailConfiguration user.name@domain.com
$Temp.BlockedSendersAndDomains += "blocked@somedomain.com","blocked2@somedomain.com"
$Temp.TrustedSendersAndDomains += "trusted@domain.com","trusted@another.com"
Set-MailboxJunkEmailConfiguration user.name@domain.com -BlockedSendersAndDomains  $Temp.BlockedSendersAndDomains -TrustedSendersAndDomains $Temp.TrustedSendersAndDomains

Set-MailboxJunkEmailConfiguration user.name@domain.com -TrustedSendersAndDomains $Temp.TrustedSendersAndDomains
