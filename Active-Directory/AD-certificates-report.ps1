#Import the PS PKI Module - Can be installed with 'Install-Module PSPKI' from PowerShellGallery
Import-Module PSPKI

#Variables
$date = get-date
$next30days = [DateTime]::Today.AddDays(30)
$last90days = [DateTime]::Today.AddDays(-90)
$toAddr = "me@domain.com"
$ccAddr = "some.cc@domain.com"
$From = "Certificates@domain.com"
$SMTPServer = "smtp.domain.com"

# Here is how you can get your list of template OIDs
#$listoftemplates = Get-CATemplate -CertificationAuthority certsrv.domain.com
#$listoftemplates.Templates | Select DisplayName,OID

#Get the CA Name
$CAName = (Get-CA | select Computername).Computername

#Get Details on Issued Certs where they match OID and expired 90 days ago (or less)
# Some of this could be done with a -Join
$Output = Get-CA | Get-IssuedRequest | Where {
    $_.CertificateTemplate -eq "1.3.6.1.4.1.311.21.8.9517485.4177856.13714108.9618586.10519251.155.1353394.7737410" -or
    $_.CertificateTemplate -eq "1.3.6.1.4.1.311.21.8.9517485.4177856.13714108.9618586.10519251.155.5257479.14163444" -or
    $_.CertificateTemplate -eq "1.3.6.1.4.1.311.21.8.9517485.4177856.13714108.9618586.10519251.155.1.16" -or
    $_.CertificateTemplate -eq "1.3.6.1.4.1.311.21.8.9517485.4177856.13714108.9618586.10519251.155.11446470.3507279" -and
    $_.NotAfter -gt $last90days} | select RequestID, CommonName, NotAfter, CertificateTemplate | sort Notafter

$readable = @()


foreach ($cert in $Output) {

    # Swap OID with readable description for email
    if ($cert.CertificateTemplate -eq "1.3.6.1.4.1.311.21.8.9517485.4177856.13714108.9618586.10519251.155.1353394.7737410") {
        $cert.CertificateTemplate = "Web-General"
    }
    if ($cert.CertificateTemplate -eq "1.3.6.1.4.1.311.21.8.9517485.4177856.13714108.9618586.10519251.155.11446470.3507279") {
        $cert.CertificateTemplate = "User-Private"
    }
    if ($cert.CertificateTemplate -eq "1.3.6.1.4.1.311.21.8.9517485.4177856.13714108.9618586.10519251.155.5257479.14163444") {
        $cert.CertificateTemplate = "Internal Wildcard"
    }
    if ($cert.CertificateTemplate -eq "1.3.6.1.4.1.311.21.8.9517485.4177856.13714108.9618586.10519251.155.1.16") {
        $cert.CertificateTemplate = "Web Server (MS Default)"
    }

    $timespan = New-TimeSpan -Start $date -End $cert.NotAfter
    $expirationDays = $timespan.Days

    $object = New-Object -Typename PSObject
    $object | Add-member -Name 'RequestID' -MemberType NoteProperty -Value $cert.RequestID
    $object | Add-member -Name 'CommonName' -MemberType NoteProperty -Value $cert.CommonName
    $object | Add-member -Name 'NotAfter' -MemberType NoteProperty -Value $cert.NotAfter
    $object | Add-member -Name 'CertificateTemplate' -MemberType NoteProperty -Value $cert.CertificateTemplate
    $object | Add-member -Name 'DaysToExpiration' -MemberType NoteProperty -Value $expirationDays
    $readable += $object
}

$expired = $readable | Where {$_.NotAfter -lt $date}
$expiringSoon = $readable | Where {$_.NotAfter -ge $date -and $_.NotAfter -lt $next30days}
$expiringLater = $readable | Where {$_.NotAfter -gt $next30days}

if ($expiringSoon) {
    $futureExpiring = $expiringSoon[0].NotAfter
    $nextExpiringDate = New-TimeSpan -Start $date -End $futureExpiring
    $nextDay = $nextExpiringDate.Days
} else {
    $futureExpiring = $expiringLater[0].NotAfter
    $nextExpiringDate = New-TimeSpan -Start $date -End $futureExpiring
    $nextDay = $nextExpiringDate.Days
}

#Get Details on Pending Requests
$Pending = Get-CA | Get-PendingRequest

#Get number of pending requests - If pending requests is null, then PendingCount is left at zero
If ($Pending){$PendingCount = ($Pending | Measure-Object).count}
Else {
$PendingCount = 0
$Pending = "`r`nNone"
} #End Else
$PendingCountStr = $PendingCount.ToString()

 # Table style
$digestHeader = @"
<style>
TABLE {border-width: 1px; border-style: solid; border-color: black; border-collapse: collapse;}
TH {border-width: 1px; padding: 3px; border-style: solid; border-color: black; background-color: #6495ED;}
TD {border-width: 1px; padding: 3px; border-style: solid; border-color: black; min-width: 70px; max-width: 350px;}
</style>
"@

if ($expired) {
    $expiredHTML = $expired | Select RequestID, CommonName, NotAfter, CertificateTemplate, DaysToExpiration | ConvertTo-Html -Head $digestHeader
} else {
    $expiredHTML = "No certs have expired in the past 90 days. Something doesn't seem right with that..."
}
if ($expiringSoon) {
    $expiringSoonHTML = $expiringSoon | Select RequestID, CommonName, NotAfter, CertificateTemplate, DaysToExpiration | ConvertTo-Html -Head $digestHeader
} else {
    $expiringSoonHTML = "No certs expiring in the next 30 days."
}
if ($expiringLater) {
    $expiringLaterHTML = $expiringLater | Select RequestID, CommonName, NotAfter, CertificateTemplate, DaysToExpiration | ConvertTo-Html -Head $digestHeader
} else {
    $expiringLaterHTML = "No certs expiring in the future... Something is broken."
}

# Build HTML body
$digestBody = @"
<h3>Expired in the last 90 days</h3>
$expiredHTML
<br><br>
<h3>Expiring in next 30 days</h3>
$expiringSoonHTML
<br><br>
<h3>Expiring beyond 30 days</h3>
$expiringLaterHTML
<br>
"@

$Subject = "Certificate Report (Next expiration: $nextDay days - Pending Certs: $PendingCountStr)"

Send-mailmessage -To $toAddr -Cc $ccAddr -From $From -SmtpServer $SMTPServer -Subject $Subject -Body $digestBody -BodyAsHtml
