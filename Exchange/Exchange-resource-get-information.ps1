Set-MailboxFolderPermission -AccessRights LimitedDetails somemailbox@domain.com:\Calendar -User default
Set-CalendarProcessing somemailbox@domain.com -AddOrganizerToSubject $true -DeleteSubject $true

$mailboxlist = Get-Mailbox -RecipientTypeDetails RoomMailbox | Get-CalendarProcessing | Select Identity,AddOrganizerToSubject,DeleteSubject
$mailboxlist2 = get-mailbox -RecipientTypeDetails RoomMailbox | Get-MailboxFolderPermission | Select AccessRights

Get-MailboxFolderPermission somemailbox@domain.com | select * | format-list
Get-CalendarProcessing somemailbox@domain.com | FL
