# Set Execution Policy for All Users
Set-ExecutionPolicy Unrestricted -Scope LocalMachine -Force

# Check if OneDrive is running
$onedriveProcess = Get-Process -Name OneDrive -ErrorAction SilentlyContinue

if ($onedriveProcess -ne $null) {
    # Stop OneDrive processes if running
    Stop-Process -Name OneDrive -Force -ErrorAction SilentlyContinue
}

# Uninstall OneDrive
$setupPath = if (Test-Path "C:\Windows\SysWOW64\OneDriveSetup.exe") {
    "C:\Windows\SysWOW64\OneDriveSetup.exe"  # 64-bit system
} else {
    "C:\Windows\System32\OneDriveSetup.exe"  # 32-bit system
}

Start-Process -FilePath $setupPath -ArgumentList "/uninstall" -Wait -PassThru

# Verify Uninstallation
$onedriveFolder = Get-Item -Path "$env:USERPROFILE\OneDrive" -ErrorAction SilentlyContinue
$registryEntry = Get-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run" -Name "OneDrive" -ErrorAction SilentlyContinue

if ($onedriveFolder -eq $null) {
    Write-Host "OneDrive folder removed successfully."
} else {
    Write-Host "Failed to remove OneDrive folder."
}

if ($registryEntry -eq $null) {
    Write-Host "OneDrive registry entry removed successfully."
} else {
    Write-Host "Failed to remove OneDrive registry entry."
}
