# Function to lookup certificate template names
function Get-CertificateTemplate {
    [OutputType([string])]
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [Security.Cryptography.X509Certificates.X509Certificate2]$Certificate
 )
    Process {
        $temp = $Certificate.Extensions | ?{$_.Oid.Value -eq "1.3.6.1.4.1.311.20.2"}
        if (!$temp) {
            $temp = $Certificate.Extensions | ?{$_.Oid.Value -eq "1.3.6.1.4.1.311.21.7"}
        }
        #Sometimes $temp is null
        if($temp){
            $temp.Format(0)
        }
        else
        {
            Write-Warning "Cannot evaluate certificate template"
            "Unknown"
        }
    }
}

# Find certificate and get thumbprint
$thumbprint = (Get-ChildItem "Cert:\LocalMachine\My" | Where-Object {(Get-CertificateTemplate $_) -like "*GPO-Computer*" } | select subject,thumbprint)
if ($thumbprint) {
    write-host "Cerificate found!"
    if ($thumbprint -isnot [array]) {
        write-host $thumbprint.Thumbprint
        $thumb = $thumbprint.Thumbprint
        msiexec /i WindowsAdminCenter1809.msi /qn /L*v log.txt SME_PORT=9001 SME_THUMBPRINT=$thumb SSL_CERTIFICATE_OPTION=installed
    } else {
        write-host "Multiple matching certificates found."
        Write-Host $thumbprint
        $thumb = Read-Host -Prompt "Enter the certificate thumbprint you wish to use: "
        msiexec /i WindowsAdminCenter1809.msi /qn /L*v log.txt SME_PORT=9001 SME_THUMBPRINT=$thumb SSL_CERTIFICATE_OPTION=installed
      }
    
} else {
    write-host "No certificates found. Make sure this system is joined to the domain."
}

