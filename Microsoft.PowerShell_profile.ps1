# Import Terminal Icons
Import-Module -Name Terminal-Icons

# Find out if the current user identity is elevated (has admin rights)
# If so and the current host is a command line, then change to red color 
# as warning to user that they are operating in an elevated context
$identity = [Security.Principal.WindowsIdentity]::GetCurrent()
$principal = New-Object Security.Principal.WindowsPrincipal $identity
$isAdmin = $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

# Compute file hashes - useful for checking successful downloads 
function md5 { Get-FileHash -Algorithm MD5 $args }
function sha1 { Get-FileHash -Algorithm SHA1 $args }
function sha256 { Get-FileHash -Algorithm SHA256 $args }

# QUICK LAUNCH
# - NOTEPAD
# - VSCODE
function n { notepad $args }
function c { code $args }

# DRIVE SHORTCUTS
function HKLM: { Set-Location HKLM: }
function HKCU: { Set-Location HKCU: }
function Env: { Set-Location Env: }

# POWERSHELL TAB NAMING
function prompt { 
    if ($isAdmin) {
        "[" + (Get-Location) + "] # " 
    } else {
        "[" + (Get-Location) + "] $ "
    }
}

$Host.UI.RawUI.WindowTitle = "PowerShell"
if ($isAdmin) {
    $Host.UI.RawUI.WindowTitle += " [Admin]"
}

# EASILY EDIT POWERSHELL $PROFILE
function editprof {
    if ($host.Name -match "ise") {
        $psISE.CurrentPowerShellTab.Files.Add($profile.CurrentUserAllHosts)
    } else {
        notepad $profile.CurrentUserAllHosts
    }
}

# RELOAD POWERSHELL $PROFILE
function reloadprof {
    & $profile
}

# SHORTCUT (GO BACK <--)
function cd... { Set-Location ..\.. }
function cd.... { Set-Location ..\..\.. }

# LIST DIRECTORY (EXCEPT FOLDERS)
function ll { Get-ChildItem -Path $pwd -File }

# GET PUBLIC IP ADDRESS
function getpubip {
    (Invoke-WebRequest http://ifconfig.me/ip ).Content
}

# SHOW PC UPTIME
function uptime {
    #Windows Powershell    
    Get-WmiObject win32_operatingsystem | Select-Object csname, @{
        LABEL      = 'LastBootUpTime';
        EXPRESSION = { $_.ConverttoDateTime($_.lastbootuptime) }
    }

}

# FIND FILE(S) CONTAINING KEYWORD
function findfile($name) {
    Get-ChildItem -recurse -filter "*${name}*" -ErrorAction SilentlyContinue | ForEach-Object {
        $place_path = $_.directory
        Write-Output "${place_path}\${_}"
    }
}

# DISPLAY ALL DRIVES (DISK-FREE)
function df {
    get-volume
}

# KILL PROCESSES (TASK MANAGER)
function pkill($name) {
    Get-Process $name -ErrorAction SilentlyContinue | Stop-Process
}

# CONFIRM PROCESS IS RUNNING
function pgrep($name) {
    Get-Process $name
}

# POWERSHELL THEME
oh-my-posh init pwsh --config "V:\Powershell\Themes\jblab_2021.omp.json" | Invoke-Expression

# CHOCOLATEY PROFILE FOR "CHOCO" TAB COMPLETION
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
    Import-Module "$ChocolateyProfile"
}
