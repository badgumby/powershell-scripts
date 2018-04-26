# Custom Variables
$fromAddr = "Message Trace <Message.Trace@domain.com>" # Enter the FROM address for the e-mail alert
$toAddr = "user.name@domain.com" # Enter the TO address for the e-mail alert
$ccAddr = "user2@domain.com","user3@domain.com" # Enter the CC addresses separated by a comma "test@test.com","test2@test.com"
$smtpsrv = "smtp-relay.domain.com" # Enter the FQDN or IP of a SMTP relay
$filename = Get-Date -format "MMddyyy.HH.mm"
$dateEnd = get-date
$dateStart = $dateEnd.AddHours(-8)
$targetAddress = "targetuser@domain.com"

# Retrieve secured credentials
$credentials = Get-StoredCredential -Target outlook.office365.com

#Connect to EO
$PSSession = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $credentials -Authentication Basic -AllowRedirection
Import-PSSession -AllowClobber -Session $PSSession

#Perform message trace for any message not equal to "Delivered"
$messageTrace = (Get-MessageTrace -SenderAddress $targetAddress -StartDate $dateStart -EndDate $dateEnd | Select Received,SenderAddress,RecipientAddress,Status,Size | Where {$_.Status -ne "Delivered"})

#If messageTrace isn't empty, create file.
if ($messageTrace.Count -gt 0) {
$messageTrace | Out-file C:\PS_Scripts\message-trace\$filename.txt
$report = (Get-content -Path C:\PS_Scripts\message-trace\$filename.txt) -join '<br>'
}

# Email file
#-Cc $ccAddr
if ($messageTrace.Count -gt 0) {
    Send-MailMessage -To "$toAddr" -From "$fromAddr" -Cc $ccAddr -Subject "Message Trace Failures - $filename" -Body "$report" -SmtpServer "$smtpsrv" -BodyAsHtml -Attachments C:\PS_Scripts\message-trace\$filename.txt
}

# Disconnect from EO
Remove-PSSession $PSSession
