# Variables
$DomainName = "nat.net"
$NetBIOSName = "NAT"
$SafeModeAdminPassword = ConvertTo-SecureString "AdminP@ssw0rd" -AsPlainText -Force
$LogFile = "C:\ADSetup\ad_setup.log"
$CheckpointFile = "C:\ADSetup\checkpoint.txt"

# Ensure Setup Directory Exists
if (!(Test-Path -Path "C:\ADSetup")) {
    New-Item -Path "C:\ADSetup" -ItemType Directory
}

# Logging Function
function Log {
    param ([string]$message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "$timestamp : $message"
    Add-Content -Path $LogFile -Value $logMessage
}

# Record Setup Stage
function Set-Checkpoint {
    param ([string]$stage)
    Set-Content -Path $CheckpointFile -Value $stage
    Log "Checkpoint set to $stage"
}

# Get Current Setup Stage
function Get-Checkpoint {
    if (Test-Path -Path $CheckpointFile) {
        Get-Content -Path $CheckpointFile
    } else {
        return "Start"
    }
}

# Install AD DS Role and Setup DNS
function Install-ADDS {
    Log "Installing AD DS and DNS roles..."
    Install-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools
    Set-Checkpoint "RoleInstalled"
}

# Configure Active Directory
function Configure-ADDS {
    Log "Configuring AD DS and setting up new forest..."
    Install-ADDSForest `
        -DomainName $DomainName `
        -DomainNetbiosName $NetBIOSName `
        -SafeModeAdministratorPassword $SafeModeAdminPassword `
        -InstallDNS `
        -Force
    Set-Checkpoint "ADConfigured"
}

# Create Scheduled Task to Rerun Script After Reboot
function Setup-ScheduledTask {
    Log "Setting up scheduled task for reboot continuation..."
    $TaskAction = New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument "-File `"$($MyInvocation.MyCommand.Path)`""
    $TaskTrigger = New-ScheduledTaskTrigger -AtStartup
    $TaskSettings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable
    Register-ScheduledTask -TaskName "ContinueADSetup" -Action $TaskAction -Trigger $TaskTrigger -Settings $TaskSettings -RunLevel Highest -Force
}

# Remove Scheduled Task
function Remove-ScheduledTask {
    Log "Removing scheduled task..."
    Unregister-ScheduledTask -TaskName "ContinueADSetup" -Confirm:$false
}

# Main Setup Process
Log "Starting AD setup script..."
$checkpoint = Get-Checkpoint

# Checkpoints for Resumable Setup
switch ($checkpoint) {
    "Start" {
        Install-ADDS
        Restart-Computer -Force
    }
    "RoleInstalled" {
        Configure-ADDS
        Restart-Computer -Force
    }
    "ADConfigured" {
        Log "Active Directory and DNS setup completed successfully."
        Remove-ScheduledTask
    }
    default {
        Log "Unknown checkpoint encountered. Exiting script."
        Exit
    }
}

