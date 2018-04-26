Get-Mailbox -ResultSize Unlimited | select UserPrincipalName,ForwardingSmtpAddress | Export-csv c:\users\username\desktop\forwarding3.csv -NoTypeInformation
