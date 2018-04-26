#Add the conference rooms to your mailbox

$startTime = (Get-Date -Hour 00 -Minute 00 -Second 00 -Day 01 -Month 01 -Year 2017)
$endTime = (Get-Date -Hour 00 -Minute 00 -Second 00 -Day 31 -Month 12 -Year 2017)
$exportFile = "C:\users\username\desktop\calendar-export.csv"
$outlook = new-object -com outlook.application;
$mapi = $outlook.GetNameSpace("MAPI");
$mailboxlist = $mapi.Folders
foreach ($mailbox in $mailboxlist) {
    $MailboxName = $mailbox.Name
        if ($mailboxname -notlike 'Mailbox -*' -and $mailboxname -notlike 'Personal*') {
        write-host $MailboxName -ForegroundColor Red
        if ($mailbox.Folders.Item("Calendar").Items) {
            write-host "Found calendar - exporting items..."
            $calitems = $mailbox.Folders.Item("Calendar").Items
            $calItems.Sort("[Start]")
            $calItems.IncludeRecurrences = $true
            $dateRange = "[End] >= '{0}' AND [Start] <= '{1}'" -f $startTime.ToString("g"), $endTime.ToString("g")
            $calExport = $calItems.Restrict($dateRange)
            $calCombined += $calExport | select @{Name='MeetingRoom';Expression={$mailboxname}}, Subject, StartUTC, EndUTC, Duration, Organizer, RequiredAttendees, IsRecurring
        }
    }
}
$calCombined | select MeetingRoom, Subject, StartUTC, EndUTC, Duration, Organizer, RequiredAttendees, IsRecurring | sort MeetingRoom,StartUTC -Descending | Export-Csv $exportFile -NoType

# Open in Excel
# Remove uneeded rows of data from sheet
# Create new sheet called Report
# Insert a pivot table containing all the data from the raw data sheet
# Drag "MeetingRoom" to Rows
# Drag "Duration"� to Values. Edit the field settings to be "Count"� and rename to "Number of Meetings"�
# Drag "Duration"� to Values. Edit the field settings to be "Sum"� and rename to "Total Duration"�
# Create two new fields "� one with the amount of work weeks per year (48.775 for mine) and the amount of hours per week (40 for mine).
# Create a new table for utilization percentages. Put the formula as =C5/($E$5*$E$9*60)
