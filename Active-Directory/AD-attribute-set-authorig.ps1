import-module activedirectory

#Group to apply authOrig attribute
$group2 = "InternationalEmployees"

#Array of users that should be assigned to authOrig
$users = @(
"user1",
"user2"
)

#Get DN of users from $users array, add to new array $userDNs
$userDNs = @()
ForEach ($user in $users) {

    $userDNs+= (Get-ADUser $user).distinguishedName

}

#Array of groups that should be assigned to authOrig
$groups = @(
"group1"
)

#Get DN of groups from $groups array, add to new array $groupDNs
$groupDNs = @()
ForEach ($group in $groups) {

    $groupDNs+= (Get-ADGroup -identity $group).distinguishedName

}

#Set users, if array is not empty
if ($userDNs.Count -gt 0) {
Set-ADGroup -identity $group2 -add @{authOrig=$userDNs}
}

#Set groups, if array is not empty
if ($groupDNs.Count -gt 0) {
Set-ADGroup -identity $group2 -add @{authOrig=$groupDNs}
}
