# Get all computers that match criteria
$computers = Get-ADComputer -Filter {(OperatingSystem -like "*windows*server*") -and (Enabled -eq "True")} -Properties OperatingSystem | Where {$_.OperatingSystem -notlike "*windows*server*2003*" -and $_.OperatingSystem -notlike "*windows*2000*server*"} | Sort Name

# Path to installer (should be accessible from the client computer)
$nxlog = "\\some_public_share\nxlog\nxlog-ce-2.9.1716.msi"
$config = "\\some_public_share\nxlog\conf\nxlog.conf"

# Loop thru computers
$computers | where{test-connection $_.DNSHostName -quiet -count 1} | ForEach-Object {

    $service = ""

    # Display computer name
    $computer = $_.DNSHostName
    $computer

    # Check for nxlog
    Write-Host "Checking if nxlog is installed..."
    $service = Get-Service -ComputerName $computer -Name nxlog

    if ($service -eq $null) {

        Write-Host "Not installed."
        # Copy nxlog to server
        Write-Host "Copying nxlog.msi..."
        Copy-Item $nxlog -recurse "\\$computer\c$\nxlog.msi"

        # Start installer process
        Write-Host "Starting install..."
        $newProc=([WMICLASS]"\\$computer\root\cimv2:win32_Process").Create("msiexec /i C:\nxlog.msi ALLUSERS=1 /quiet")

        # Return if it started or failed
        If ($newProc.ReturnValue -eq 0) {
            Write-Host "$computer - PID $($newProc.ProcessId)"
            Start-Sleep -Seconds 6
            # Copy config to server
            Write-Host "Copying nxlog.conf..."
            Copy-Item $config -recurse "\\$computer\c$\Program Files (x86)\nxlog\conf\nxlog.conf"

            # Restart nxlog service
            $service = Get-Service -ComputerName $computer -Name nxlog
            Restart-Service -InputObject $service -verbose
            $service.Refresh()
            $service.Status
        } else {
            write-host "$computer - Process create failed with $($newProc.ReturnValue)"
        }

    } else {

        # Copy config to server
        Write-Host "Copying nxlog.conf..."
        Copy-Item $config -recurse "\\$computer\c$\Program Files (x86)\nxlog\conf\nxlog.conf"

        # Restart nxlog service
        $service = Get-Service -ComputerName $computer -Name nxlog
        Restart-Service -InputObject $service -verbose
        $service.Refresh()
        $service.Status

    }

}
