$count = Get-MessageTrace -MessageId "<MESSAGEIDSTRING@whatever.prod.outlook.com>" -PageSize 5000 | Where {$_.Status -eq "Delivered"}
