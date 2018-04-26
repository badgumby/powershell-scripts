Connect-AzureAD
$upn = "user.name@domain.onmicrosoft.com"

#Exchange Online only account set to never expire (used for email service accounts)
Set-MsolUser -UserPrincipalName $upn -PasswordNeverExpires $true
Get-MsolUser -UserPrincipalName $upn | select PasswordNeverExpires


Set-AzureADUser -ObjectId $upn -PasswordPolicies DisablePasswordExpiration
Get-AzureADUser -ObjectId $upn | select PasswordPolicies
