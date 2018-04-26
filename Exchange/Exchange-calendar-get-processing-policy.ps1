#$room = "room-name"
#Set-CalendarProcessing -identity $room -AllRequestOutOfPolicy $False
#Get-CalendarProcessing -identity $room | Select AllRequestOutOfPolicy

$rooms = @()
$status = Get-Mailbox -ResultSize unlimited -Filter {(RecipientTypeDetails -eq 'RoomMailbox')} | ForEach-Object {

   $rooms+= Get-CalendarProcessing -identity $_.Identity | Select Identity,AllRequestOutOfPolicy | Where {$_.AllRequestOutOfPolicy -eq "TRUE"}

   }


$rooms | export-csv c:\Temp\rooms.csv -NoTypeInformation
