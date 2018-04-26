$dateEnd = get-date
$dateStart = $dateEnd.AddDays(-7)

$content = Get-MessageTrace -RecipientAddress User.Name@domain.com -StartDate $dateStart -EndDate $dateEnd | Select @{N='Received';E={[datetime]::SpecifyKind($_.Received,'Utc').ToLocalTime()}},SenderAddress,RecipientAddress,Subject,MessageID,MessageTraceID,Status,Size

$content | out-gridview
$content | export-csv c:\TEMP\received-messages.csv
