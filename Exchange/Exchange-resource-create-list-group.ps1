$RoomAlias = Get-Mailbox -RecipientTypeDetails RoomMailbox -Filter {Office -eq 'SomeOffice'} | select -ExpandProperty Alias
New-DistributionGroup -RoomList -Name 'SomeOffice Rooms' -Members $RoomAlias

#List info
Get-DistributionGroup 'SomeOffice Rooms' | Select-Object *
Get-DistributionGroupMember 'SomeOffice Rooms'

#Rename group: Example from "SomeOffice" to "SomeOffice Rooms"
Set-DistributionGroup -identity 'SomeOffice' -Name 'SomeOffice Rooms'
Set-DistributionGroup -identity 'SomeOffice Rooms' -DisplayName 'SomeOffice Rooms'

#Add member to distributiongroup
Add-DistributionGroupMember 'SomeOffice Rooms' -member user.name@domain.com

#Remove member of distributiongroup
Remove-DistributionGroupMember 'SomeOffice Rooms' -member 'IT Test Room'
