if ($PSVersionTable.PSVersion.Major -lt 5) {
    $ver = $PSVersionTable.PSVersion
    Write-Host "Minimum Powershell version required is 5.1"
    Write-Host "You are running: $ver"
   
} else {
# Get the ID and security principal of the current user account
$myWindowsID=[System.Security.Principal.WindowsIdentity]::GetCurrent()
$myWindowsPrincipal=new-object System.Security.Principal.WindowsPrincipal($myWindowsID)
 
# Get the security principal for the Administrator role
$adminRole=[System.Security.Principal.WindowsBuiltInRole]::Administrator
 
# Check to see if we are currently running "as Administrator"
if ($myWindowsPrincipal.IsInRole($adminRole))
   {
   # We are running "as Administrator" - so change the title and background color to indicate this
   $Host.UI.RawUI.WindowTitle = $myInvocation.MyCommand.Definition + "(Elevated)"
   clear-host
   }
else
   {
   # We are not running "as Administrator" - so relaunch as administrator
   
   # Create a new process object that starts PowerShell
   $newProcess = new-object System.Diagnostics.ProcessStartInfo "PowerShell";
   
   # Specify the current script path and name as a parameter
   $newProcess.Arguments = $myInvocation.MyCommand.Definition;
   
   # Indicate that the process should be elevated
   $newProcess.Verb = "runas";
   
   # Start the new process
   [System.Diagnostics.Process]::Start($newProcess);
   
   # Exit from the current, unelevated, process
   exit
   }
 
# Run your code that needs to be elevated here
$version = "v7.7.2.0p1-Beta"
$url = "https://github.com/PowerShell/Win32-OpenSSH/releases/download/$version/OpenSSH-Win64.zip"
$folder = "OpenSSH-Win64"
$downloadOutput = "$PSScriptRoot\$folder.zip"
$file = "install-sshd.ps1"

# Download the installer
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Invoke-WebRequest -Uri $url -OutFile $downloadOutput
#(New-Object System.Net.WebClient).DownloadFile($url, $DownloadOutput)

# Unzip the file
Expand-Archive $downloadOutput -DestinationPath "C:\Program Files\"

# Execute installer script
& "C:\Program Files\$folder\$file"

# Create firewall rules
New-NetFirewallRule -Name sshd -DisplayName 'OpenSSH SSH Server' -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 22

# Configure OpenSSH services for automatic startup
Set-Service -Name ssh-agent -StartupType Automatic
Set-Service -Name sshd -StartupType Automatic

# Start OpenSSH services
Start-Service -Name ssh-agent
Start-Service -Name sshd

# Find host fingerprint
cd "C:\Program Files\$folder"
.\ssh-keygen.exe -A
.\ssh-keygen.exe -l -f "$env:ProgramData\ssh\ssh_host_ed25519_key" -E md5
}