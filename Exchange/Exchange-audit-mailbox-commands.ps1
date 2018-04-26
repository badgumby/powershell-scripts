$allOwner = "Create,HardDelete,MailboxLogin,Move,MoveToDeletedItems,SoftDelete,Update"
$allDelegate = "Create,FolderBind,HardDelete,Move,MoveToDeletedItems,SendAs,SendOnBehalf,SoftDelete,Update"
$allAdmin = "Copy,Create,FolderBind,HardDelete,MessageBind,Move,MoveToDeletedItems,SendAs,SendOnBehalf,SoftDelete,Update"

$identity = "user.name@domain.com"

set-mailbox $identity -AuditDelegate $allDelegate -AuditOwner $allOwner -AuditAdmin $allAdmin -AuditLogAgeLimit 180 -AuditEnabled $true
get-mailbox $identity | select Name,Audit* | FL
