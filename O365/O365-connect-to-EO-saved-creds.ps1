Import-Module MsOnline
# Retrieve secured credentials
$credentials = Get-StoredCredential -Target Office365
#Connect to EO
$PSSession = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $credentials -Authentication Basic -AllowRedirection
Import-PSSession -Session $PSSession -AllowClobber
#Connect-MsolService




#DON'T FORGET TO DISCONNECT WHEN FINISHED WORKING!!!!!!
Remove-PSSession $PSSession