# Disable Microsoft Account login reminders for all users on a local Windows 10 machine

# Check if running as administrator
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "Please run the script as an administrator."
    exit
}

# Disable Microsoft Account login reminders for each user profile
$allUserProfiles = Get-WmiObject Win32_UserProfile | Where-Object { $_.Special -eq $false }

foreach ($userProfile in $allUserProfiles) {
    $userSID = $userProfile.LocalPath.Split('\')[-1]

    $registryPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\SystemProtectedUserData\$userSID"
    $registryKey = "DisableSignInReminders"

    try {
        New-Item -Path $registryPath -Force -ErrorAction Stop
        Set-ItemProperty -Path $registryPath -Name $registryKey -Value 1
        Write-Host "Disabled Microsoft Account login reminders for user SID: $userSID"
    } catch {
        Write-Host "Error creating or updating registry key for user SID: $userSID"
        Write-Host $_.Exception.Message
    }
}

Write-Host "Script execution completed."