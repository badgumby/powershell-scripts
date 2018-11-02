# Just set these variables
$mailboxName = "New.mailbox"
$owner = "Just Some Guy"
$members = (
    "SamAccountName1",
    "SamAccountName2",
    "SamAccountName3",
    "SamAccountName4",
    "SamAccountName5",
    "SamAccountName6"
)

### DO NOT TOUCH BELOW HERE
# Set additional variables
$mailboxAccess = -join($mailboxName, "1")
$mailboxOU = "OU=Shared-Mailbox,OU=Non-Users,OU=Locations,DC=domain,DC=com"
$groupOU = "OU=Groups,OU=Shared-Mailbox,OU=Non-Users,OU=Locations,DC=domain,DC=com"

# Generate password (x = length of characters, y = minimum number of non-alphanumeric characters)
$Password = [system.web.security.membership]::GeneratePassword(14,2)

# Create access group
New-ADGroup -name $mailboxAccess -SamAccountName $mailboxAccess -DisplayName $mailboxAccess -Path $groupOU -Description "Used for the $mailboxName shared mailbox" -GroupScope Universal -GroupCategory Security
$group = Get-ADGroup -Identity "CN=$mailboxAccess,$groupOU"
Set-ADgroup -Identity $group -Add @{proxyAddresses="SMTP:$mailboxAccess@domain.com"}
Set-ADgroup -Identity $group -Add @{proxyAddresses="smtp:$mailboxAccess@domain.onmicrosoft.com"}
Set-ADgroup -Identity $group -Add @{targetAddress="SMTP:$mailboxAccess@domain.com"}
Set-ADgroup -Identity $group -Add @{mail="$mailboxAccess@domain.com"}
Set-ADgroup -Identity $group -Add @{mailNickname="$mailboxAccess"}
Set-ADgroup -Identity $group -Add @{msExchHideFromAddressLists=$TRUE}
Set-ADgroup -Identity $group -Add @{info="Owner: $owner"}

# Add members to the newly created group
foreach ($member in $members) {

    $user = Get-ADUser -Identity $member
    Add-ADGroupMember -Identity $group -Members $user

}

# Create shared mailbox user
New-ADUser -Name $mailboxName -SamAccountName $mailboxName -DisplayName $mailboxName -Path $mailboxOU -Description "Used for the $mailboxName shared mailbox" -Surname $mailboxName
$mailbox = Get-ADUser -Identity "CN=$mailboxName,$mailboxOU"
Set-ADuser -Identity $mailbox -Add @{proxyAddresses="SMTP:$mailboxName@domain.com"}
Set-ADuser -Identity $mailbox -Add @{proxyAddresses="smtp:$mailboxName@domain.onmicrosoft.com"}
Set-ADuser -Identity $mailbox -Add @{targetAddress="SMTP:$mailboxName@domain.com"}
Set-ADuser -Identity $mailbox -Add @{mail="$mailboxName@domain.com"}
Set-ADuser -Identity $mailbox -Add @{mailNickname="$mailboxName"}
Set-ADuser -Identity $mailbox -Add @{info="Owner: $owner"}

# Set password and enable account
Set-ADAccountPassword -Identity $mailbox -Reset -NewPassword (convertTo-SecureString -AsPlainText $Password -force)
Enable-ADAccount -Identity $mailbox
