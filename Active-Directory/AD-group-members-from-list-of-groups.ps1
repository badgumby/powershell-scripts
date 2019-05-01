# Variables
$path = "\\ServerA.domain.com\Analytics\Admin\"
$groupsFile = $path + "groups.txt"
$domain = "domain.com"
$dateTime = Get-Date -Format "yyy.MM.dd"

if ($groupsFile) {
    
    # Read each group line
    foreach ($line in [System.IO.File]::ReadLines($groupsFile)) {

        # Get group info
        $group = Get-ADGroup -Identity $line -Server $domain | Get-ADGroupMember -server $domain
        
        # Create user list and loop thru array
        $userList = @()
        foreach ($member in $group) { 
            $userinfo = ""
            $userList+= $member
        }
        
        # Get user info from userList and to new array
        $names = @()
        foreach ($user in $userList) {
            $person = New-Object -TypeName PSObject
            $name = Get-ADobject $user -Properties DisplayName,physicalDeliveryOfficeName,Manager,sn,givenName -Server $domain
            $person | Add-Member -Name 'Last Name' -MemberType NoteProperty -Value $name.sn
            $person | Add-Member -Name 'Given Name' -MemberType NoteProperty -Value $name.givenName
            $person | Add-Member -Name 'Display Name' -MemberType NoteProperty -Value $name.DisplayName
            $person | Add-Member -Name 'Location' -MemberType NoteProperty -Value $name.physicalDeliveryOfficeName
            $person | Add-Member -Name 'Manager' -MemberType NoteProperty -Value $name.Manager
            $names += $person
        }

        try {
            $filePath = $path + "Groups\" + $line + ".csv"
            $names | Export-Csv $filePath -NoTypeInformation
        } catch {
            $filePath = $path + "filePath\" + $line + ".$datetime.csv"
            $names | Export-Csv $csvPath2 -NoTypeInformation
        }
    }
}
