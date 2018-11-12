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
