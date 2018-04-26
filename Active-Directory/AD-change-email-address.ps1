$Users = @()
$Users = Get-ADUser -Properties mail,mailnickname,emailaddress,userprincipalname -Filter * -SearchBase "OU=Locations,DC=domain,DC=com"

foreach ($user in $users) {
    $oldemail = $user.mailnickname + "@original-name.com"
    $newemail = $user.mailnickname + "@new-name.com"
    $thirdemail = $user.mailnickname + "@additional-proxy.onmicrosoft.com"
    $SecondarySMTP = "smtp:" + $oldemail + ",smtp:" + $thirdemail
    $PrimarySMTP = "SMTP:" + $newemail

    Set-ADUser $user -EmailAddress $newemail -Replace @{proxyAddresses = ($PrimarySMTP) -split "," }
    Set-ADUser $user -Replace @{targetaddress = ($PrimarySMTP)}
    Set-ADUser $user -Add @{proxyAddresses = ($SecondarySMTP) -split ","}
 }
