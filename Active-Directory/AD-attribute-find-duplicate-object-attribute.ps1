$fromAddr = "User Reports <User.Reports@domain.com>" # Enter the FROM address for the e-mail alert
$toAddr = "user1@domain.com" # Enter the TO address for the e-mail alert
$toZendesk = "support@site.zendesk.com"
$ccAddr = "user2@domain.com","user3@domain.com" # Enter the CC addresses separated by a comma "test@test.com","test2@test.com"
$smtpsrv = "smtp-relay.domain.com" # Enter the FQDN or IP of a SMTP relay
$date = Get-Date -format "MM-dd-yyy_hh.mm.ss"
$header = "<html><head></head><body><br>Duplicate AD accounts have been found for the users below.<br>Please determine which account(s) are active.<br>Note: There could be two users with the same name.<br><br>"
$headerZendesk = "<br>Duplicate AD accounts have been found for the users below.<br>Please determine which account(s) are active.<br>Note: There could be two users with the same name.<br><br>"

#Display names to exclude from search (intentional duplicate accounts)
$excludeDisplayName = @("Fake User|Another User")
$excludeObjectSID = @("S-1-5-21-restofsid1|S-1-5-21-restofsid2")
$excludeOU = @("OU=Disabled,OU=Locations,DC=DOMAIN,DC=com")

#Array for count
$duplicateCount = @()

#Create file with top line
New-Item -path C:\PS_Scripts\duplicate-users-log -Name $date-html-log.txt -Value $header
New-Item -path C:\PS_Scripts\duplicate-users-log -Name $date-html-log2.txt -Value $headerZendesk

#Create table and header row
Add-Content C:\PS_Scripts\duplicate-users-log\$date-html-log.txt "<table style=`"border:1px solid black;border-collapse: collapse;`"><tr><th style=`"text-align:left;border:1px solid black;padding:5px;`">displayName</th><th style=`"text-align:left;border:1px solid black;padding:5px;`"> samAccountName </th><th style=`"text-align:left;border:1px solid black;padding:5px;`">Enabled</th><th style=`"text-align:left;border:1px solid black;padding:5px;`">ObjectSID</th><th style=`"text-align:left;border:1px solid black;padding:5px;`">OU</th></tr>"

#Generate duplicate user list
$duplicateList = Get-ADUser -Filter {(displayName -like "*")} -property displayName | Where-Object{$_.displayName -notmatch $excludeDisplayName -and $_.SID -notmatch $excludeObjectSID -and $_.distinguishedName -notlike "*,$excludeOU"} |Group displayName | ? {$_.Count -ge 2} | select -ExpandProperty group | Select-Object Name, SamAccountName, displayName, UserPrincipalName, Enabled, ObjectClass, SID, distinguishedName

#List used for email
$duplicateList | ForEach-Object {
    $duplicateCount+=$_.displayName
    Add-Content C:\PS_Scripts\duplicate-users-log\$date-html-log.txt -value ("<tr><td style=`"border:1px solid black;padding:5px;`">" + $_.displayName + "</td> <td style=`"border:1px solid black;padding:5px;`">" + $_.samAccountName + "</td><td style=`"border:1px solid black;padding:5px;`">" + $_.enabled + "</td><td style=`"border:1px solid black;padding:5px;`">" + $_.SID + "</td><td style=`"border:1px solid black;padding:5px;`">" + $_.distinguishedName + "</td></tr>")
    Add-Content C:\PS_Scripts\duplicate-users-log\$date-html-log2.txt -value ($_.displayName + " / " + $_.samAccountName + " / " + $_.SID + " / " + $_.distinguishedName + " <br>")
    }

#Close table
Add-Content C:\PS_Scripts\duplicate-users-log\$date-html-log.txt "</table>"

#Send email with html body -Cc $ccAddr
if ($duplicateCount.Count -gt 0) {
    $body = (Get-content -Path C:\PS_Scripts\duplicate-users-log\$date-html-log.txt)
    $body2 = (Get-content -Path C:\PS_Scripts\duplicate-users-log\$date-html-log2.txt)
    Send-MailMessage -To "$toAddr" -Cc $ccAddr -From "$fromAddr" -Subject "Duplicate AD Accounts - $date" -Body "$body" -SmtpServer "$smtpsrv" -BodyAsHtml
    Send-MailMessage -To "$toZendesk" -From "$fromAddr" -Subject "Duplicate AD Accounts - $date" -Body "$body2" -SmtpServer "$smtpsrv" -BodyAsHtml
    }
