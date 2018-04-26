Import-Module ActiveDirectory

$computers = @()

$domains = @(
    @{
        SearchBase = 'ou=Servers,dc=domain,dc=com'
        Server = 'server4.domain.com'
    }#,
    #@{
    #    SearchBase = 'ou=Servers,dc=canada,dc=domain,dc=com'
    #    Server = 'server3.sub3.domain.com'
    #},
    #@{
    #    SearchBase = 'ou=Servers,dc=sub1,dc=domain,dc=com'
    #    Server = 'server1.sub1.domain.com'
    #},
    #@{
    #    SearchBase = 'ou=Servers,dc=sub2,dc=domain,dc=com'
    #    Server = 'server2.sub2.domain.com'
    #}
)

$domainIndex = 0;

ForEach ($domain in $domains) {
    if (!$domainIndex) { Write-Progress -Activity 'Finding servers' -Status "0% complete" -PercentComplete 0 }
    $domainIndex += 1
    $percentComplete = $domainIndex / $domains.Count * 100

    $domainComputers = Get-ADComputer -Filter {operatingsystem -like "*server 2008*"} -Server $domain.Server -Properties OperatingSystem
    $domainComputers += Get-ADComputer -Filter {operatingsystem -like "*server 2008*"} -Server $domain.Server -Properties OperatingSystem
    $computers += $domainComputers
    $status = 'Domain ' + $domainIndex.ToString() + ' / ' + $domains.Count.ToString() + ' - ' + $percentComplete + '%'
    Write-Progress -Activity 'Finding servers' -Status $status -PercentComplete $percentComplete
}

Foreach ($computer in $computers | Sort-Object Name) {
    Try {
        $ip = [System.Net.Dns]::GetHostAddresses($computer.DNSHostName).IPAddressToString
        $hostname = [System.Net.Dns]::GetHostByAddress($ip).HostName
        $session = New-PSSession -ComputerName $hostname

        if ($session) {
            if ($computer.OperatingSystem -like "*server 2012*") {
                $smb1 = Invoke-Command -Session $session -ScriptBlock { (Get-SmbServerConfiguration | Select EnableSMB1Protocol).EnableSMB1Protocol }
            } elseif ($computer.OperatingSystem -like "*server 2008*") {
                $smb1 = Invoke-Command -Session $session -ScriptBlock { [bool]((Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters\").SMB1) }
            }

            $hostname + "`t" + $smb1
            Remove-PSSession $session
        }
    } Catch {
        'ERROR: ' + $computer.DNSHostName
    }
}
