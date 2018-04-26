$credential = Get-Credential
Import-Module MsOnline
Connect-MsolService -Credential $credential
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri "https://outlook.office365.com/powershell-liveid/" -Credential $credential -Authentication "Basic" -AllowRedirection
Import-PSSession $Session -DisableNameChecking -AllowClobber


#DON'T FORGET TO DISCONNECT WHEN FINISHED WORKING!!!!!!
Remove-PSSession $Session