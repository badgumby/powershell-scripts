function Get-ADUserLastLogon([string]$userName)
{
  $dcs = Get-ADDomainController -Filter {Name -like "*"}
  $time = 0
  foreach($dc in $dcs)
  {
    $hostname = $dc.HostName
    $user = Get-ADUser $userName | Get-ADObject -Server $hostname -Properties lastLogontimeStamp
    if($user.lastLogontimeStamp -gt $time)
    {
      $time = $user.lastLogontimeStamp
    }
    $dt = [DateTime]::FromFileTime($time)
    Write-Host $username "last logged on at:" $dt $dc
  }
}
Get-ADUserLastLogon -UserName username
