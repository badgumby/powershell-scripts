# Create contact objects based on CSV import
﻿$Path = "C:\All-contacts.csv"

Import-Csv $Path | foreach{New-ADObject -Type Contact -Name $_.ExternalEmailAddress -OtherAttributes @{'displayName'=$_.ExternalEmailAddress;'mail'=$_.ExternalEmailAddress;'proxyAddresses'="smtp:" + $_.ExternalEmailAddress;'msExchHideFromAddressLists'=$true} -Path "OU=SomeOU,OU=Non-Users,OU=Locations,DC=domain,DC=com"}
