$ou = "OU=Disabled,OU=Locations,DC=domain,DC=com"
$attributeName = "extensionAttribute10"
$attributeValue = "*"

$accounts = Get-ADUser -SearchBase $ou -filter {$attributeName -like $attributeValue}

foreach ($user in $accounts){

    get-aduser $user.name -filter {extensionAttribute10 -like "*"}

}
