$Username=user1
# Connect to remote machine
enter-pssession -computername $ServerName -Credential $Username

# List current protocol status
Get-SmbServerConfiguration | Select EnableSMB1Protocol

# Disable SMB v1
Set-SmbServerConfiguration -EnableSMB1Protocol $false
