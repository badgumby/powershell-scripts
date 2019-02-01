# Required variables
$domain = "example.com"
$server = "server1.example.com"

# Get all static DNS A records from $server on $domain
$static = Get-DnsServerResourceRecord -ComputerName $server -ZoneName $domain -RRType A | where {-not $_.TimeStamp}

# Build base arrays
$responsive = @()
$nonresponsive = @()

# used to increment display number
$i = 0

foreach ($entry in $static) {
    $i++
    echo $entry
    echo "$i of $($static.Count)"

    # Create object to hold hostname and IP for arrays
    $values = New-Object -Typename PSObject
    $values | Add-Member -type NoteProperty -Name Hostname -Value $entry.HostName
    $values | Add-Member -type NoteProperty -Name IPAddress -Value $entry.RecordData.IPv4Address.IPAddressToString

    # Test ping each static entry
    if (Test-Connection $entry.RecordData.IPv4Address.IPAddressToString -Count 3 -Quiet) {

        # Add to list if ping is successful
        $responsive += $values

    } else {
        
        # Add to list if ping is unsuccessful
        $nonresponsive += $values

    }

    # Display blank space between reports in CLI
    echo ""
}

$responsive | Export-Csv C:\responsive.csv -NoTypeInformation
$nonresponsive | Export-Csv C:\nonresponsive.csv -NoTypeInformation
