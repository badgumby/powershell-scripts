Set-MailboxRegionalConfiguration room1@domain.com -timezone "Central Standard Time"
Get-MailboxRegionalConfiguration room1@domain.com | Select Timezone
