Get-Mailbox user.name@domain.com | select-object CalendarRepairDisabled
Get-Mailbox user.name@domain.com | Set-Mailbox -CalendarRepairDisabled $true -Verbose
