# Create new dynamic distribution group - directreports not equal to null
New-DynamicDistributionGroup -name "Managers.All" -alias "Managers.All" -RecipientFilter {(RecipientType -eq 'UserMailbox') -and (UserPrincipalName -ne 'user.name@domain.com') -and (DirectReports -ne $null)}

# Create new dynamic distribution group - location
New-DynamicDistributionGroup -name "Some Location" -alias "Some.Location" -RecipientFilter {(RecipientType -eq 'UserMailbox') -and (UserPrincipalName -ne 'user.name@domain.com') -and (Office -like 'Some Location*')}

#Get current senders list
Get-DynamicDistributionGroup "DynGrpName" -ResultSize Unlimited | select AcceptMessagesOnlyFrom,AcceptMessagesOnlyFromSendersOrMembers | fl
Get-DistributionGroup "StaticGrpName" -ResultSize Unlimited | select AcceptMessagesOnlyFrom,AcceptMessagesOnlyFromSendersOrMembers | fl

#Dynamic - get group members
$members = Get-DynamicDistributionGroup "DynGrpName"
Get-Recipient -RecipientPreviewFilter $members.RecipientFilter -ResultSize Unlimited | export-csv c:\Temp\all.csv -NoTypeInformation

#Static - get group members
$members = Get-DistributionGroup "StaticGrpName"
Get-Recipient -RecipientPreviewFilter $members.RecipientFilter | Export-csv c:\Temp\static.csv

#Add another member to current group
Set-DynamicDistributionGroup "DynGrpName" -AcceptMessagesOnlyFrom @{Add="user.name@domain.com"}

#Add members (this will replace existing list)
Set-DynamicDistributionGroup "DynGrpName" -AcceptMessagesOnlyFrom "user.name@domain.com", "user.name2@domain.com", "user.name3@domain.com"


#To add or remove senders without affecting other existing entries, use the following syntax:
# @{Add="<sender1>","<sender2>"...; Remove="<sender1>","<sender2>"...}.

#Update Static Distribution group users
Set-DistributionGroup "StaticGrpName" -AcceptMessagesOnlyFrom @{Add="user.name@domain.com", "user.name2@domain.com", "user.name3@domain.com"}
Get-DistributionGroup "StaticGrpName" -ResultSize Unlimited | select AcceptMessagesOnlyFrom,AcceptMessagesOnlyFromSendersOrMembers | fl


#Change dynamic distribution group membership
Set-DynamicDistributionGroup -identity "DynGrpName" -RecipientFilter {(RecipientType -eq 'UserMailbox') -and (UserPrincipalName -ne 'user.name@domain.com') -and (CustomAttribute5 -ne 'ExcludeFromDynamic') -and (RecipientTypeDetailsValue -ne 'SharedMailbox')}

#Hide from DynGroup
Set-Mailbox -identity user.name@domain.com -CustomAttribute5 "ExcludeFromDynamic"
