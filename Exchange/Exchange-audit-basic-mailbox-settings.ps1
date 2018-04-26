# Technet article: https://technet.microsoft.com/en-us/library/dn879651.aspx#step2

# List current audited properties of mailbox
get-mailbox user.name@domain.com | select Audit* | FL

# List additional details of specific audit type
get-mailbox user.name@domain.com | select-object -ExpandProperty AuditOwner

# Audit Admin - All possible options
set-mailbox user.name@domain.com -AuditAdmin Copy,Create,FolderBind,HardDelete,MessageBind,Move,MoveToDeletedItems,SendAs,SendOnBehalf,SoftDelete,Update

# Audit Delegate - All possible options
set-mailbox user.name@domain.com -AuditDelegate Create,FolderBind,HardDelete,Move,MoveToDeletedItems,SendAs,SendOnBehalf,SoftDelete,Update

#Audit Owner - All possible options
set-mailbox user.name@domain.com -AuditOwner Create,HardDelete,MailboxLogin,Move,MoveToDeletedItems,SoftDelete,Update

# Configure Auditing on mailbox
Set-Mailbox -Identity "User Name" -AuditEnabled $true -AuditLogAgeLimit 180

# Configure Auditing on all mailboxes
Get-Mailbox -ResultSize Unlimited -Filter {RecipientTypeDetails -eq "UserMailbox"} | Set-Mailbox -AuditEnabled $true -AuditLogAgeLimit 90


# My normal user config
$allOwner = "Create,HardDelete,MailboxLogin,Move,MoveToDeletedItems,SoftDelete,Update"
$allDelegate = "Create,FolderBind,HardDelete,Move,MoveToDeletedItems,SendAs,SendOnBehalf,SoftDelete,Update"
$allAdmin = "Copy,Create,FolderBind,HardDelete,MessageBind,Move,MoveToDeletedItems,SendAs,SendOnBehalf,SoftDelete,Update"
set-mailbox User.Name@domain.com -AuditDelegate $allDelegate -AuditOwner $allOwner -AuditAdmin $allAdmin -AuditLogAgeLimit 180
