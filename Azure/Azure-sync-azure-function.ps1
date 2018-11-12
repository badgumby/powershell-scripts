# To have this file load by default, name it as "Microsoft.PowerShell_profile.ps1"
# Place it in the following directory: C:\Windows\System32\WindowsPowerShell\v1.0\

function SyncAzureEO {
    $status = Get-ADSyncConnectorRunStatus
    if ($status.RunState -eq "Busy") {
        write-host "A sync is already running. Please try again in a few moments."
        Write-Host "To see the current status: Get-ADSyncConnectorRunStatus"
    } else {
        Start-ADSyncSyncCycle -PolicyType Initial
    }

}
Set-Alias SyncEO SyncAzureEO
