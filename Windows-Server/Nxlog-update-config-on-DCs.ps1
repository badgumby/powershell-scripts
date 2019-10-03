$nxlogLocal = "c:\users\badgumby\Desktop\nxlog.conf"
$nxlogRemote = "\C$\Program Files (x86)\nxlog\conf\nxlog.conf"

$forest = [System.DirectoryServices.ActiveDirectory.Forest]::GetCurrentForest()

foreach ($site in $forest.Sites) {

    foreach ($dc in $site.Servers) {
        Write-Host "Copying file to $($dc.Name)..."
        Copy-Item -Path $nxlogLocal -Destination "\\$($dc.Name)$nxlogRemote"

        Write-Host "Restarting nxlog..."
        Invoke-Command -ComputerName $dc.Name -ScriptBlock {
            Restart-Service -Name nxlog
        }
        Write-Host ""
    }

}
