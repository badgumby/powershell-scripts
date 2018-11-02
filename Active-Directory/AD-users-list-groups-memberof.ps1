$dude = "SamAccountName"
﻿$user = Get-ADUser $dude -Properties PrimaryGroupId,MemberOf,DistinguishedName
$groups = Get-ADPrincipalGroupMembership -Identity $user | Where-Object { $account.Name -ne 'Domain Users' }
$groupArray = @()

foreach ($group in $groups) {

    $groupArray+= $group.name

}

$groupArray
