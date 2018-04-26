Get-CalendarProcessing user.name@domain.com | select RemoveForwardedMeetingNotifications
Set-CalendarProcessing user.name@domain.com -RemoveForwardedMeetingNotifications $true

#Get-CalendarProcessing user.name@domain.com | select * | fl
#Get-MailboxCalendarConfiguration user.name@domain.com | select RemindersEnabled
