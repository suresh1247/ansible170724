<#
.SYNOPSIS
  Joins a Windows Server to an Active Directory domain using credentials passed as parameters.
  
.DESCRIPTION
  - Checks if the machine is already joined to the target domain.
  - If not, joins the domain using provided credentials.
  - Optionally places the computer in a specified OU.
  - Returns a clear exit code and console messages.

.PARAMETER DomainName
  The FQDN of the domain to join (e.g., nat.net)

.PARAMETER DomainAdminUser
  Domain admin username in UPN format (e.g., adminuser@nat.net)

.PARAMETER DomainAdminPassword
  Domain admin password (SecureString)

.PARAMETER OUPath
  Optional DN of OU (e.g. "OU=Servers,DC=nat,DC=net")

.PARAMETER ForceReboot
  Reboot immediately after successful join

.REQUIREMENTS
  - Run in an elevated PowerShell session (Run as Administrator)
  - DNS must resolve domain controllers for the target domain
  - Time must be in sync with domain (±5 minutes is a safe guideline)
  - Network ports to DC should be open (LDAP/Kerberos/RPC, etc.)
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$DomainName,

    [Parameter(Mandatory = $true)]
    [string]$DomainAdminUser,

    [Parameter(Mandatory = $true)]
    [string]$DomainAdminPassword,

    [Parameter(Mandatory = $false)]
    [string]$OUPath = "",

    [switch]$ForceReboot
)

# --- Helper: return codes ---
# 0 = success/no change
# 1 = error
# 2 = already joined to a different domain (explicit halt)

function Write-Info($msg)  { Write-Host "[INFO]  $msg" -ForegroundColor Cyan }
function Write-Ok($msg)    { Write-Host "[OK]    $msg" -ForegroundColor Green }
function Write-Warn($msg)  { Write-Host "[WARN]  $msg" -ForegroundColor Yellow }
function Write-Err($msg)   { Write-Host "[ERROR] $msg" -ForegroundColor Red }

try {
    Write-Info "Starting domain join check for target domain '$DomainName'..."

    # Check current membership
    $cs = Get-CimInstance -ClassName Win32_ComputerSystem
    $isDomainJoined = [bool]$cs.PartOfDomain
    $currentDomain  = $cs.Domain

    if ($isDomainJoined -and ($currentDomain -ieq $DomainName)) {
        Write-Ok "This machine is already joined to '$DomainName'. No action required."
        exit 0
    }

    if ($isDomainJoined -and ($currentDomain -ine $DomainName)) {
        Write-Warn "This machine is joined to a different domain: '$currentDomain'."
        Write-Warn "Unjoin from the current domain and reboot before joining '$DomainName'."
        exit 2
    }

    # Convert the plaintext password to SecureString (required by Add-Computer)
    $secure = ConvertTo-SecureString $DomainAdminPassword -AsPlainText -Force
    $cred   = New-Object System.Management.Automation.PSCredential ($DomainAdminUser, $secure)

    # Build parameters for Add-Computer
    $params = @{
        DomainName  = $DomainName
        Credential  = $cred
        ErrorAction = 'Stop'
    }
    if ($OUPath -and $OUPath.Trim().Length -gt 0) {
        Write-Info "Requested OU placement: $OUPath"
        $params['OUPath'] = $OUPath
    }

    Write-Info "Attempting to join the domain '$DomainName'..."
    Add-Computer @params

    Write-Ok "Successfully joined '$DomainName'. A reboot is required to complete the operation."

    if ($ForceReboot) {
        Write-Info "Force reboot requested. Rebooting in 10 seconds..."
        Start-Sleep -Seconds 10
        Restart-Computer -Force
    }

    exit 0
}
catch {
    Write-Err "Domain join failed: $($_.Exception.Message)"
    # Helpful hints for common failures:
    Write-Host ""
    Write-Warn "Common causes:"
    Write-Warn " - DNS not resolving DCs for '$DomainName'"
    Write-Warn " - Time skew between this server and domain controllers"
    Write-Warn " - Firewall blocking LDAP/Kerberos/RPC"
    Write-Warn " - OU path invalid or insufficient permissions"
    Write-Warn " - Account lockout or wrong password"
    exit 1
}
