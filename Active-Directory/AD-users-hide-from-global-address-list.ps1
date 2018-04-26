$listgroups = @()
Get-ADGroup -filter * -SearchBase "OU=Groups,OU=Shared-Mailbox,OU=Non-Users,OU=Locations,DC=domain,DC=com" | ForEach-Object {
    $listgroups+= $_.SamAccountName
}

ForEach ($group in $listgroups) {
    Set-ADGroup $group -Replace @{msExchHideFromAddressLists=$true} -WhatIf
}
