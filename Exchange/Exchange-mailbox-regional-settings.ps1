#List Regional Settings for Shared Mailbox (example: it-inf.shared@domain.com)
get-mailboxregionalconfiguration it-inf.shared

#Set Regional Settings for Shared Mailbox (example: it-inf.shared@domain.com)
set-mailboxregionalconfiguration it-inf.shared -dateformat 'M/d/yyyy' -timeformat 'h:mm tt' -language 'en-US' -timezone 'Central Standard Time'

#Set Regional Settings for ALL Shared Mailboxes
Get-Mailbox –RecipientTypeDetails SharedMailbox | Set-MailboxRegionalConfiguration –Language “en-US” –TimeZone “Central Standard Time” –DateFormat “M/d/yyyy” –TimeFormat “h:mm tt”
