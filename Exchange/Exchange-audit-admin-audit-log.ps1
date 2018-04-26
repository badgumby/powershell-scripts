# Retrieve secured credentials
$credentials = Get-StoredCredential -Target outlook.office365.com

#Connect to EO
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $credentials -Authentication Basic -AllowRedirection
Import-PSSession -Session $Session

Search-AdminAuditLog  -UserIds "User Name" | export-csv H:\logs.csv
Search-AdminAuditLog -Cmdlets Set-Mailbox -Parameters AuditEnabled |

Get-AdminAuditLogConfig | FL


# Disconnect from EO
Remove-PSSession $Session
