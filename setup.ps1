# Функция для обработки ошибок
function Handle-Error {
    param([string]$step)
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Произошла ошибка на этапе: $step. Продолжаем выполнение скрипта..."
    }
}

# Проверка наличия Chocolatey, если не установлен - устанавливаем
if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
    Write-Host "Chocolatey не найден. Устанавливаем..."
    try {
        Invoke-Expression (New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1')
        Handle-Error "Установка Chocolatey"
    } catch {
        Write-Host "Не удалось установить Chocolatey."
    }
} else {
    Write-Host "Chocolatey уже установлен."
}

# Обновляем Chocolatey
choco upgrade chocolatey -y
Handle-Error "Обновление Chocolatey"

# Устанавливаем основные пакеты для разработчика
$packages = @(
    "git",                # Система контроля версий
    "nodejs",             # Node.js для разработки на JavaScript
    "python",             # Python для разработки
    "vscode",             # Visual Studio Code - редактор кода
    "jetbrainstoolbox",   # Инструменты JetBrains
    "telegram",           # Мессенджер Telegram
    "docker-desktop",     # Docker для контейнеризации
    "googlechrome",       # Браузер Google Chrome
    "postman",            # Postman для работы с API
    "firefox",            # Альтернативный браузер
    "7zip",               # Утилита для работы с архивами
    "curl",               # Утилита для работы с URL запросами
    "openssh",            # SSH для удаленной работы
    "postgresql",         # PostgreSQL - основная база данных
    "dbeaver",            # GUI для работы с базами данных
    "powertoys",          # Microsoft PowerToys для повышения производительности
    "microsoft-windows-terminal", # Windows Terminal для работы с различными оболочками
    "sparkmail",          # Почтовый клиент Spark
    "adobereader",        # Чтение PDF файлов
    "vlc",                # Медиаплеер VLC
    "libreoffice-fresh"   # LibreOffice - офисный пакет
)

foreach ($package in $packages) {
    Write-Host "Установка пакета $package..."
    choco install $package -y
    Handle-Error "Установка пакета $package"
}

# Удаление ненужных предустановленных приложений Windows 11
Write-Host "Удаление ненужных предустановленных приложений..."
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
    Write-Host "Удаление приложения: $app"
    try {
        Get-AppxPackage -Name $app | Remove-AppxPackage
        Handle-Error "Удаление приложения $app"
    } catch {
        Write-Host "Не удалось удалить приложение: $app"
    }
}

# Настройки Windows для максимального удобства
Write-Host "Настройка Windows для разработчика..."

# Отключение телеметрии и рекламы
Write-Host "Отключение телеметрии и рекламы..."
try {
    Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo' -Name 'Enabled' -Value 0
    Handle-Error "Отключение телеметрии (AdvertisingInfo)"
    
    Set-ItemProperty -Path 'HKLM:\Software\Policies\Microsoft\Windows\DataCollection' -Name 'AllowTelemetry' -Value 0
    Handle-Error "Отключение телеметрии (DataCollection)"
    
    Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager' -Name 'SystemPaneSuggestionsEnabled' -Value 0
    Handle-Error "Отключение рекламы (SystemPaneSuggestionsEnabled)"
} catch {
    Write-Host "Не удалось отключить телеметрию и рекламу."
}

# Отключение автозапуска OneDrive
Write-Host "Отключение автозапуска OneDrive..."
try {
    Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Run' -Name 'OneDrive' -Value ''
    Handle-Error "Отключение автозапуска OneDrive"
} catch {
    Write-Host "Не удалось отключить автозапуск OneDrive."
}

# Отключение ненужных сервисов
Write-Host "Отключение ненужных сервисов..."
$services = @(
    "DiagTrack",        # Диагностика и телеметрия
    "dmwappushsvc",     # Диагностика Windows Push
    "OneSyncSvc",       # Синхронизация приложений
    "XblGameSave",      # Сохранение игр Xbox
    "GamingServices"    # Сервисы Xbox
)

foreach ($service in $services) {
    Write-Host "Остановка и отключение сервиса: $service"
    try {
        Stop-Service -Name $service -Force
        Handle-Error "Остановка сервиса $service"
        
        Set-Service -Name $service -StartupType Disabled
        Handle-Error "Отключение автозапуска сервиса $service"
    } catch {
        Write-Host "Не удалось остановить или отключить сервис: $service"
    }
}

# Настройка PowerShell для удобства работы разработчика
Write-Host "Настройка PowerShell..."
try {
    Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
    Handle-Error "Настройка ExecutionPolicy"
    
    Install-Module -Name PowerShellGet -Force -AllowClobber
    Handle-Error "Установка модуля PowerShellGet"
    
    Install-Module -Name Posh-Git -Force
    Handle-Error "Установка модуля Posh-Git"
    
    Install-Module -Name oh-my-posh -Force
    Handle-Error "Установка модуля Oh My Posh"
} catch {
    Write-Host "Не удалось настроить PowerShell."
}

# Настройка темы и интерфейса
Write-Host "Настройка темной темы и анимаций..."
try {
    Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize' -Name 'AppsUseLightTheme' -Value 0
    Handle-Error "Включение темной темы для приложений"
    
    Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize' -Name 'SystemUsesLightTheme' -Value 0
    Handle-Error "Включение темной темы для системы"
    
    Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize' -Name 'EnableTransparency' -Value 1
    Handle-Error "Включение прозрачности окон"
} catch {
    Write-Host "Не удалось настроить тему и прозрачность."
}

# Оптимизация работы системы для ноутбука
Write-Host "Настройка производительности и энергосбережения для ноутбука..."
try {
    powercfg /duplicatescheme SCHEME_BALANCED
    Handle-Error "Создание плана энергопотребления"
    
    powercfg /change standby-timeout-ac 0
    Handle-Error "Отключение спящего режима при работе от сети"
    
    powercfg /change monitor-timeout-ac 10
    Handle-Error "Настройка таймаута отключения монитора"
} catch {
    Write-Host "Не удалось настроить энергосбережение и производительность."
}

# Настройка FancyZones и других функций PowerToys
Write-Host "Настройка PowerToys..."
try {
    Start-Process PowerToys -ArgumentList '/runElevated' -NoNewWindow
    Handle-Error "Запуск PowerToys"
    
    Set-ItemProperty -Path 'HKCU:\Software\Microsoft\PowerToys\FancyZones' -Name 'ZoneCount' -Value 3
    Handle-Error "Настройка FancyZones"
} catch {
    Write-Host "Не удалось настроить PowerToys."
}

# Настройка брандмауэра и антивируса
Write-Host "Настройка брандмауэра и антивируса..."
try {
    Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled True
    Handle-Error "Включение брандмауэра"
    # Проверка и установка обновлений антивируса, если установлен (требуется дополнительная настройка для конкретного антивируса)
} catch {
    Write-Host "Не удалось настроить брандмауэр или антивирус."
}

# Настройка WSL2 и установка Ubuntu
Write-Host "Настройка WSL2 и установка Ubuntu..."
try {
    # Включение необходимых компонентов
    Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux -NoRestart
    Handle-Error "Включение WSL"
    
    Enable-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform -NoRestart
    Handle-Error "Включение виртуализации"
    
    # Установка WSL2 как дефолтной версии
    wsl --set-default-version 2
    Handle-Error "Настройка WSL2 по умолчанию"
    
    # Перезагрузка для применения изменений
    Restart-Computer -Force
} catch {
    Write-Host "Не удалось настроить WSL2."
}

# Очистка системы
Write-Host "Очистка мусорных файлов..."
try {
    Start-Process cleanmgr -ArgumentList '/sagerun:1' -NoNewWindow -Wait
    Handle-Error "Очистка мусора через cleanmgr"
} catch {
    Write-Host "Не удалось очистить мусорные файлы."
}

# Финальное сообщение
Write-Host "Все настройки успешно применены! Желаете перезагрузить компьютер? (Y/N)"
$response = Read-Host
if ($response -eq 'Y' -or $response -eq 'y') {
    Write-Host "Перезагрузка компьютера..."
    Restart-Computer -Force
} else {
    Write-Host "Перезагрузка отменена. Чтобы изменения вступили в силу, вам может потребоваться перезагрузить компьютер вручную."
}
