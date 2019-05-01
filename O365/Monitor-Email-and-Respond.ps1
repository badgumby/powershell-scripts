# Create a scheduled task in Windows to run this script every 10 minutes
# It will open the mailbox using the credentials in Credential Manager specified below
# You can create additional functions and subjects to monitor

$moduleStatus = Get-InstalledModule | Where-Object {$_.Name -eq "PSWinDocumentation.O365HealthService"}
if ($moduleStatus -eq $null) {
    Install-Module -Name PSWinDocumentation.O365HealthService
} else {
    Import-Module PSWinDocumentation.O365HealthService -Force
}

# SMTP variables
$fromAddr = "Office 365 Health <IT.Reports@domain.com>" # Enter the FROM address for the e-mail alert
$smtpsrv = "smtp-relay.domain.com" # Enter the FQDN or IP of a SMTP relay

# Start logging
Start-Transcript -Path C:\Health-Service.log

# Load mailbox credentials (You need the CredentialManager module {Install-Module -Name CredentialManager})
$credentials = Get-StoredCredential -Target CredentialName -AsCredentialObject
$mail = $credentials.UserName
$password = $credentials.Password

# Email subjects for different tasks
$healthstatus = "#healthstatus"
$assignO365 = "#assigno365"

# Office365 key info
$ApplicationID = 'AppID-goes-here'
$ApplicationKey = 'AppKey-goes-here'
$TenantDomain = 'Tenant-ID-or-Name-goes-here' # Can be name or ID from Azure (ID seems to work better)
$O365 = Get-Office365Health -ApplicationID $ApplicationID -ApplicationKey $ApplicationKey -TenantDomain $TenantDomain

# Table style
$digestHeader = @"
<style>
TABLE {border-width: 1px; border-style: solid; border-color: black; border-collapse: collapse;}
TH {border-width: 1px; padding: 3px; border-style: solid; border-color: black; background-color: #6495ED;}
TD {border-width: 1px; padding: 3px; border-style: solid; border-color: black; min-width: 70px; max-width: 350px;}
</style>
"@

# Microsoft Exchange Web Services Managed API 2.2
# https://www.microsoft.com/en-us/download/confirmation.aspx?id=42951
# Set the path to your copy of EWS Managed API
$dllpath = "C:\Program Files\Microsoft\Exchange\Web Services\2.2\Microsoft.Exchange.WebServices.dll"

# Load the Assemply
[void][Reflection.Assembly]::LoadFile($dllpath)

# Create a new Exchange service object
$service = new-object Microsoft.Exchange.WebServices.Data.ExchangeService

#These are your O365 credentials
$Service.Credentials = New-Object Microsoft.Exchange.WebServices.Data.WebCredentials($mail,$password)

# this TestUrlCallback is purely a security check
$TestUrlCallback = {
    param ([string] $url)
    if ($url -eq "https://autodiscover-s.outlook.com/autodiscover/autodiscover.xml") {$true} else {$false}
}
# Autodiscover using the mail address set above
$service.AutodiscoverUrl($mail,$TestUrlCallback)

# create Property Set to include body and header of email
$PropertySet = New-Object Microsoft.Exchange.WebServices.Data.PropertySet([Microsoft.Exchange.WebServices.Data.BasePropertySet]::FirstClassProperties)

# set email body to text
$PropertySet.RequestedBodyType = [Microsoft.Exchange.WebServices.Data.BodyType]::Text;

# Set how many emails we want to read at a time
$numOfEmailsToRead = 100

# Index to keep track of where we are up to. Set to 0 initially.
$index = 0

##################################################################################################
# Function to check Office365 health status
##################################################################################################
function HealthStatus {

    Write-Output "Found health status email."
    $O365.CurrentStatus
    $incidentIDs = @()
    foreach ($status in $O365.CurrentStatus) {
        if ($status.IncidentIds -ne $null -or $status.IncidentIds -ne "") {
            $incidentIDs += $status.IncidentIds.Split(", ")
        }
    }
    $incidentIDs = $incidentIDs | Where-Object {$_}
    $incidents = $O365.Incidents
    $activeIncidents = @()
    foreach ($incident in $incidents) {
        if ($incidentIDs -contains $incident.ID) {
            $activeIncidents += $incident
        } else {
                    # Do nothing
        }
    }

    $digestHTML = $O365.CurrentStatus | Sort-Object -Property @{Expression = {$_.ServiceStatus}; Ascending = $false}, Service | ConvertTo-Html -Head $digestHeader
    if ($activeIncidents.Count -gt 0) {
        $secondHeader = "<h3>Incident Details</h3>"
    } else {
        $secondHeader = ""
    }

    $activeHTML = $activeIncidents | Select ID,Feature,Title,ImpactDescription,LastUpdatedTime,EndTime,AffectedTenantCount | ConvertTo-Html

    # Build HTML body
    $digestBody = @"
    To receive a status report at any time, please email IT.Reports@domain.com with only <b>#healthstatus</b> in the subject line. <br>
    Please allow up to 10 minutes after emailing to receive your fresh status report. <br><br>
    <h3>Office 365 Health Status ($($activeIncidents.Count))</h3>
    $digestHTML
    <br>
    $secondHeader
    $activeHTML
"@

    # Send email to requester
    $toAddr = $item.From.Address
    Send-MailMessage -To $toAddr -From "$fromAddr" -Subject "Office 365 Health Status" -Body $digestBody -SmtpServer "$smtpsrv" -BodyAsHtml

    # Output the results
    "Name: $($item.From.Name)"
    "Address: $($item.From.Address)"
    "Subject: $($item.Subject)"
    "Received Date: $($item.DateTimeReceived)"
    "Read?: $($item.IsRead)"
    ""
}
##################################################################################################
# End function
##################################################################################################

##################################################################################################
# Function for move and mark as read
##################################################################################################
function CompleteTask {
    Write-Output "Starting mark as read/move."
    # Try to mark as read
    try {
        $item.IsRead = $true
        $item.Update([Microsoft.Exchange.WebServices.Data.ConflictResolutionMode]::AutoResolve)

        # Find folder named 'Processed' and move message to that folder
        $processedfolder = "Processed"
        $tfTargetFolder = [Microsoft.Exchange.WebServices.Data.Folder]::Bind($service,[Microsoft.Exchange.WebServices.Data.WellKnownFolderName]::Inbox)
        $fvFolderView = new-object Microsoft.Exchange.WebServices.Data.FolderView(1)
        $SfSearchFilter = new-object Microsoft.Exchange.WebServices.Data.SearchFilter+IsEqualTo([Microsoft.Exchange.WebServices.Data.FolderSchema]::DisplayName,$processedfolder)
        $findFolderResults = $service.FindFolders($tfTargetFolder.Id,$SfSearchFilter,$fvFolderView)
        #$item.Move($findFolderResults.Folders.Item(0).ID.UniqueId)
        $item.Move($findFolderResults[0].ID)

        echo "Message updated."
    } catch {
        $ErrorMessage = $_.Exception.Message
        echo $ErrorMessage
    }
}
##################################################################################################
# End function
##################################################################################################

$i = 1
# Do/while loop for paging through the folder
do
{
    # Set what we want to retrieve from the folder. This will grab the first $pagesize emails
    $view = New-Object Microsoft.Exchange.WebServices.Data.ItemView($numOfEmailsToRead,$index)
    # Retrieve the data from the folder
    $findResults = $service.FindItems([Microsoft.Exchange.WebServices.Data.WellKnownFolderName]::Inbox,$view)
    foreach ($item in $findResults.Items)
    {
        # load the additional properties for the item
        $item.Load($propertySet)
        Write-Output "Subject is: $($item.Subject)"
        Write-Output "Read status is: $($item.IsRead)"

        ##################################################################################################
        # Assign Office 365 Licenses
        ##################################################################################################
        if ($item.Subject -like $assignO365 -and $item.IsRead -eq $false) {

            Write-Output "Found office assignment email."
            Get-ScheduledTask -TaskName "Assign Office365 Licenses" | Start-ScheduledTask -AsJob
            CompleteTask

        }
        ##################################################################################################
        # End Assign Office 365 Licenses
        ##################################################################################################

        ##################################################################################################
        # Office 365 Service Health Status
        ##################################################################################################
        elseif ($item.Subject -eq $healthstatus -and $item.IsRead -eq $false) {

            Write-Output "Found health status email."
            HealthStatus
            CompleteTask

        }
        ##################################################################################################
        # End Office 365 Service Health Status
        ##################################################################################################

        Write-Output "Message found. ($i)"
        $i++
    }
    # Increment $index to next block of emails
    $index += $numOfEmailsToRead
} while ($findResults.MoreAvailable) # Do/While there are more emails to retrieve

if ($i -eq 1) {
    Write-Output "No emails found."
}

# End log
Stop-Transcript
