Get-ADOrganizationalUnit -LDAPFilter '(gPLink=*<GPO GUID>*)'

Get-GPO -All | select DisplayName, ID, Owner, GPOStatus, Description, CreationTime, ModificationTime | Export-Csv c:\temp\GPOs.csv -NoTypeInformation