$mailbox = "somemailbox@domain.com"
echo "Before"
get-mailboxpermission $mailbox
echo " "
echo "Add resourceadmin"
add-mailboxpermission $mailbox -AccessRights FullAccess -User ResourceAdmin
echo ""
echo "After"
get-mailboxpermission $mailbox
