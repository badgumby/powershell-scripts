$domains = "domain.com","sub1.domain.com","sub2.domain.com","sub3.domain.com"
$group = Get-ADGroupMember -identity "group-name"
$userList = @()

#foreach ($domain in $domains) {

    foreach ($member in $group) {
        $userinfo = ""
        #$userinfo = Get-ADUser $member.name -Server $domain -Properties *
        #$userinfo = Get-ADUser $member.name -Properties *
        #$userList+= $userinfo.UserPrincipalName
        $userList+= $member
    }

#}

$userList
