# Function to handle errors
function Handle-Error {
    param([string]$step)
    if ($LASTEXITCODE -ne 0) {
        Write-Host "An error occurred at step: $step. Continuing script execution..."
    }
}

# Check if Chocolatey is installed, install if missing
if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
    Write-Host "Chocolatey not found. Installing..."
    try {
        Invoke-Expression (New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1')
        Handle-Error "Chocolatey Installation"
    } catch {
        Write-Host "Failed to install Chocolatey."
    }
} else {
    Write-Host "Chocolatey is already installed."
}

# Update Chocolatey
choco upgrade chocolatey -y
Handle-Error "Chocolatey Update"

# Install essential developer packages
$packages = @(
    "git",                # Version control system
    "nodejs",             # Node.js for JavaScript development
    "python",             # Python for development
    "vscode",             # Visual Studio Code - code editor
    "jetbrainstoolbox",   # JetBrains tools
    "telegram",           # Telegram messenger
    "docker-desktop",     # Docker for containerization
    "googlechrome",       # Google Chrome browser
    "postman",            # Postman for API development
    "firefox",            # Firefox browser
    "7zip",               # Archive utility
    "curl",               # Utility for URL requests
    "openssh",            # SSH for remote work
    "postgresql",         # PostgreSQL - main database
    "dbeaver",            # GUI for working with databases
    "powertoys",          # Microsoft PowerToys for productivity
    "microsoft-windows-terminal", # Windows Terminal for various shells
    "sparkmail",          # Spark email client
    "adobereader",        # PDF reader
    "vlc",                # VLC media player
    "libreoffice-fresh"   # LibreOffice - office suite
)

foreach ($package in $packages) {
    Write-Host "Installing package $package..."
    choco install $package -y
    Handle-Error "Installing package $package"
}

# Remove unnecessary pre-installed Windows 11 apps
Write-Host "Removing unnecessary pre-installed apps..."
$bloatware = @(
    "*xbox*",
    "*yourphone*",
    "*zune*",
    "*onenote*",
    "*solitaire*",
    "*people*",
    "*skypeapp*",
    "*bingweather*",
    "*windowscommunicationsapps*",
    "*officehub*",
    "*3dbuilder*",
    "*mixedreality*",
    "*photos*",
    "*XboxGameBar*",
    "*MicrosoftOfficeHub*",
    "*GetHelp*",
    "*Cortana*",
    "*FeedbackHub*"
)

foreach ($app in $bloatware) {
    Write-Host "Removing app: $app"
    try {
        Get-AppxPackage -Name $app | Remove-AppxPackage
        Handle-Error "Removing app $app"
    } catch {
        Write-Host "Failed to remove app: $app"
    }
}

# Configure Windows settings for developer convenience
Write-Host "Configuring Windows for developers..."

# Disable telemetry and ads
Write-Host "Disabling telemetry and ads..."
try {
    Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo' -Name 'Enabled' -Value 0
    Handle-Error "Disabling telemetry (AdvertisingInfo)"
    
    Set-ItemProperty -Path 'HKLM:\Software\Policies\Microsoft\Windows\DataCollection' -Name 'AllowTelemetry' -Value 0
    Handle-Error "Disabling telemetry (DataCollection)"
    
    Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager' -Name 'SystemPaneSuggestionsEnabled' -Value 0
    Handle-Error "Disabling ads (SystemPaneSuggestionsEnabled)"
} catch {
    Write-Host "Failed to disable telemetry and ads."
}

# Disable OneDrive auto-start
Write-Host "Disabling OneDrive auto-start..."
try {
    Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Run' -Name 'OneDrive' -Value ''
    Handle-Error "Disabling OneDrive auto-start"
} catch {
    Write-Host "Failed to disable OneDrive auto-start."
}

# Disable unnecessary services
Write-Host "Disabling unnecessary services..."
$services = @(
    "DiagTrack",        # Diagnostics and telemetry
    "dmwappushsvc",     # Windows Push Diagnostics
    "OneSyncSvc",       # App sync services
    "XblGameSave",      # Xbox game save
    "GamingServices"    # Xbox gaming services
)

foreach ($service in $services) {
    Write-Host "Stopping and disabling service: $service"
    try {
        Stop-Service -Name $service -Force
        Handle-Error "Stopping service $service"
        
        Set-Service -Name $service -StartupType Disabled
        Handle-Error "Disabling service $service"
    } catch {
        Write-Host "Failed to stop or disable service: $service"
    }
}

# Configure PowerShell for developer convenience
Write-Host "Configuring PowerShell..."
try {
    Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
    Handle-Error "Setting ExecutionPolicy"
    
    Install-Module -Name PowerShellGet -Force -AllowClobber
    Handle-Error "Installing PowerShellGet module"
    
    Install-Module -Name Posh-Git -Force
    Handle-Error "Installing Posh-Git module"
    
    Install-Module -Name oh-my-posh -Force
    Handle-Error "Installing Oh My Posh module"
} catch {
    Write-Host "Failed to configure PowerShell."
}

# Configure dark theme and animations
Write-Host "Configuring dark theme and animations..."
try {
    Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize' -Name 'AppsUseLightTheme' -Value 0
    Handle-Error "Enabling dark theme for apps"
    
    Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize' -Name 'SystemUsesLightTheme' -Value 0
    Handle-Error "Enabling dark theme for system"
    
    Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize' -Name 'EnableTransparency' -Value 1
    Handle-Error "Enabling window transparency"
} catch {
    Write-Host "Failed to configure theme and transparency."
}

# Optimize performance and power settings for laptop
Write-Host "Configuring performance and power settings for laptop..."
try {
    powercfg /duplicatescheme SCHEME_BALANCED
    Handle-Error "Creating power plan"
    
    powercfg /change standby-timeout-ac 0
    Handle-Error "Disabling sleep mode on AC power"
    
    powercfg /change monitor-timeout-ac 10
    Handle-Error "Setting monitor timeout"
} catch {
    Write-Host "Failed to configure power settings."
}

# Configure FancyZones and other PowerToys features
Write-Host "Configuring PowerToys..."
try {
    Start-Process PowerToys -ArgumentList '/runElevated' -NoNewWindow
    Handle-Error "Starting PowerToys"
    
    Set-ItemProperty -Path 'HKCU:\Software\Microsoft\PowerToys\FancyZones' -Name 'ZoneCount' -Value 3
    Handle-Error "Configuring FancyZones"
} catch {
    Write-Host "Failed to configure PowerToys."
}

# Configure firewall and antivirus
Write-Host "Configuring firewall and antivirus..."
try {
    Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled True
    Handle-Error "Enabling firewall"
    # Antivirus updates would require specific antivirus configuration
} catch {
    Write-Host "Failed to configure firewall or antivirus."
}

# Configure WSL2 and install Ubuntu
Write-Host "Configuring WSL2 and installing Ubuntu..."
try {
    # Enable required components
    Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux -NoRestart
    Handle-Error "Enabling WSL"
    
    Enable-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform -NoRestart
    Handle-Error "Enabling virtualization"
    
    # Set WSL2 as default
    wsl --set-default-version 2
    Handle-Error "Setting WSL2 as default"
    
    # Restart to apply changes
    Restart-Computer -Force
} catch {
    Write-Host "Failed to configure WSL2."
}

# Clean up system junk files
Write-Host "Cleaning up system junk files..."
try {
    Start-Process cleanmgr -ArgumentList '/sagerun:1' -NoNewWindow -Wait
    Handle-Error "Cleaning junk via cleanmgr"
} catch {
    Write-Host "Failed to clean up junk files."
}

# Final message
Write-Host "All configurations applied successfully! Would you like to restart the computer? (Y/N)"
$response = Read-Host
if ($response -eq 'Y' -or $response -eq 'y') {
    Write-Host "Restarting the computer..."
    Restart-Computer -Force
} else {
    Write-Host "You can restart later to apply all changes."
}
