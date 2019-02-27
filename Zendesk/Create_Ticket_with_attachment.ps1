Import-Module ActiveDirectory

$upload = "C:\scheduled-tasks\ActiveDirectory\Exports\Empty-Attributes.csv"
$global:uploadToken = $null

function uploadExcel {

    [Net.ServicePointManager]::SecurityProtocol = 'TLS11','TLS12','ssl3'

    # Zendesk login variables
    $tenant = "domain"
    $Username = "servicedesk@domain.com/token"
    $Token = "jibberish_token"
    $base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $Username,$Token)))

    # Upload variables
    $uri = "https://$tenant.zendesk.com/api/v2/uploads.json?filename=Empty-Attributes.csv"

    try {
   
        $results = @()
        $results = Invoke-RestMethod -Uri $uri -Method Post -Headers @{Authorization=("Basic {0}" -f $base64AuthInfo)} -ContentType "application/binary" -InFile $upload
        echo "Token: $($results.upload.token)"
        $global:uploadToken = $results.Upload.token

    } catch {
        
        $ErrorMessage = $_.Exception.Message
        echo $ErrorMessage
        
    }
}

function submitTicket {

[Net.ServicePointManager]::SecurityProtocol = 'TLS11','TLS12','ssl3'

# Zendesk login variables
$tenant = "domain"
$Username = "servicedesk@domain.com/token"
$Token = "jibberish_token"
$base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $Username,$Token)))

# Ticket variables
$uri = "https://$tenant.zendesk.com/api/v2/tickets.json"
$requesterEmail = "some.dude@domain.com"
$subject = "Weekly AD empty attribute report"
$body = "Compile a report containing empty AD Attributes save the report as CSV and attach to this ticket."
$assignee = "some.dude@domain.com"
$backupAssignee = ""

# Lookup agents/admins
$agents = ""
$search = "https://$tenant.zendesk.com/api/v2/users.json?role[]=agent&role[]=admin"
$agents = Invoke-RestMethod -Uri $search -Method Get -Headers @{Authorization=("Basic {0}" -f $base64AuthInfo)}

$assigneeID = ""
foreach ($i in $agents.users) {

    $currentID = $i.id
    $currentEmail = $i.email
    
    if ($currentEmail -ilike $assignee) {

        $assigneeID = $currentID

     } else {

        # Do nothing

     }

}

if (!$assigneeID) {

    echo "No ID found, not creating ticket."

} else {

    $due_at = (Get-Date).AddDays(1).tostring("yyyy-MM-dd")
    try {
    
        $json = @"
        {
            "ticket": {
                "subject": "$subject",
                "ticket_form_id": "360000304531",
                "due_at": "$due_at",
                "type": "task",
                "comment": {
                    "body": "$body",
                    "uploads": ["$global:uploadToken"]
                }, 
                "requester": {
                    "email": "$requesterEmail"
                },
                "custom_fields": [{
                    "id": "22514274",
                    "value": "infrastructure_services"
                }],
                "priority": "normal",
                "assignee_id": "$assigneeID"
            }
        }
"@
            
        echo "ID found: $assigneeID"
        $results = @()
        $results = Invoke-RestMethod -Uri $uri -Method Post -Headers @{Authorization=("Basic {0}" -f $base64AuthInfo)} -ContentType "application/json" -Body $json
        echo "Ticket #: $($results.ticket.id)"
        echo "Creation Time: $($results.ticket.created_at)"

    } catch {
        
        $ErrorMessage = $_.Exception.Message
        echo $ErrorMessage
        
    }
}

}

# OUs to include in search
$includedOUs = @(
    "OU=Users,OU=City1,OU=Locations,DC=domain,DC=com",
    "OU=Users,OU=City2,OU=Locations,DC=domain,DC=com"
)

$users = Get-ADUSer -filter * -Properties manager,payCostCenter,expCostCenter,employeeID,department | Where {$_.Enabled -eq $true -and $_.DistinguishedName -match ($includedOUs -join '|') -and ($_.manager -eq $null -or $_.department -eq $null -or $_.employeeID -eq $null -or $_.expCostCenter -eq $null -or $_.payCostCenter -eq $null)}

if ($users.Count -ne 0) {

    $users | Export-Csv $upload -NoTypeInformation

    uploadExcel
    submitTicket

}
