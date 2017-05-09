#  Windows 10 Workstation Runup Script
# Run Powershell as Administrator and copy code into PS window
# Copy all files in NewPcRunup to c:\Support on local machine


function Use-RunAs
{   
    # Check if script is running as Adminstrator and if not use RunAs
    # Use Check Switch to check if admin
    
    param([Switch]$Check)
    
    $IsAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()`
        ).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
        
    if ($Check) { return $IsAdmin }    

    if ($MyInvocation.ScriptName -ne "")
    { 
        if (-not $IsAdmin) 
        { 
            try
            { 
                $arg = "-file `"$($MyInvocation.ScriptName)`""
                Start-Process "$psHome\powershell.exe" -Verb Runas -ArgumentList $arg -ErrorAction 'stop' 
            }
            catch
            {
                Write-Warning "Error - Failed to restart script with runas" 
                break              
            }
            exit # Quit this session of powershell
        } 
    } 
    else 
    { 
        Write-Warning "Error - Script must be saved as a .ps1 file first" 
        break 
    } 
}

# Example

Use-RunAs

"Script Running As Administrator"

#----------------------------------------------------------------------------------
Set-ExecutionPolicy bypass

# Path for the workdir
$SupportDir = "c:\support\"


#---------------------------------------------------------------------------------------
#   Description:
# This script will use Windows package manager to bootstrap Chocolatey and
# into your default drive's root directory.


Write-Host "Installing Adobe Reader & Java"
$packages = @(
    #"7zip.install"
    #"firefox"
    #"google-chrome-x64"
    "AdobeReader"
    "Java"
    #"Teamviewer.host"
)

Write-Host "Setting up Chocolatey software package manager"
Get-PackageProvider -Name chocolatey -Force

Write-Host "Setting up Full Chocolatey Install"
Install-Package -Name Chocolatey -Force -ProviderName chocolatey
$chocopath = (Get-Package chocolatey | ?{$_.Name -eq "chocolatey"} | Select @{N="Source";E={((($a=($_.Source -split "\\"))[0..($a.length - 2)]) -join "\"),"Tools\chocolateyInstall" -join "\"}} | Select -ExpandProperty Source)
& $chocopath "upgrade all -y"
choco install chocolatey-core.extension --force

<#Write-Host "Installing $Packages"
$packages | %{choco install $_ --force -y} #>


foreach ($packages in $packages) {
    Write-Host "Installing $Packages"

    %{choco install $_ --force -y}
}


#---------------------------------------------------------------------------------------

Write-Host "Installing the Integrate-IT Teamviewer Host"
$ErrorActionPreference = 'Stop'

$packageName = 'teamviewer.host'
$url32       = 'C:\Support\IITA_Host_Setup.exe'
#$checksum32  = '1ab3204fecd93329008276043b83c84d6b806a3c1e55a701e30295aed27ea1ae'

$toolsPath   = Split-Path $MyInvocation.MyCommand.Definition

$packageArgs = @{
  packageName            = $packageName
  fileType               = 'EXE'
  url                    = $url32
  #checksum               = $checksum32
  #checksumType           = 'sha256'
  silentArgs             = '/S'
  validExitCodes         = @(0)
  registryUninstallerKey = $packageName
}
Install-ChocolateyPackage @packageArgs

#---------------------------------------------------------------------------------------

#Change Power settings to High and disable HDD sleep
Write-Host "Changing Power settings to High and disable HDD sleep" -ForegroundColor Magenta

$powerPlan = gwmi -NS root\cimv2\power -Class win32_PowerPlan -Filter "ElementName ='High Performance'"

$powerPlan.Activate()

start-sleep -s 2

powercfg /change disk-timeout-ac 0
powercfg /change disk-timeout-dc 0

start-sleep -s 1

#---------------------------------------------------------------------------------------


#https://github.com/W4RH4WK/Debloat-Windows-10/blob/master/scripts/remove-default-apps.ps1
Write-Host "Uninstalling default Windows 10 apps"  -ForegroundColor Magenta
$apps = @(
    # default Windows 10 apps
    "Microsoft.3DBuilder"
    #"Microsoft.Appconnector"
    "Microsoft.BingFinance"
    "Microsoft.BingNews"
    "Microsoft.BingSports"
    "Microsoft.BingWeather"
    "Microsoft.FreshPaint"
    "Microsoft.Getstarted"
    "Microsoft.MicrosoftOfficeHub"
    "Microsoft.MicrosoftSolitaireCollection"
    #"Microsoft.MicrosoftStickyNotes"
    "Microsoft.Office.OneNote"
    #"Microsoft.OneConnect"
    "Microsoft.People"
    "Microsoft.SkypeApp"
    #"Microsoft.Windows.Photos"
    #"Microsoft.WindowsAlarms"
    #"Microsoft.WindowsCalculator"
    #"Microsoft.WindowsCamera"
    "Microsoft.WindowsMaps"
    "Microsoft.WindowsPhone"
    #"Microsoft.WindowsSoundRecorder"
    #"Microsoft.WindowsStore"
    "Microsoft.XboxApp"
    "Microsoft.ZuneMusic"
    "Microsoft.ZuneVideo"
    "microsoft.windowscommunicationsapps"
    "Microsoft.MinecraftUWP"

    # Threshold 2 apps
    "Microsoft.CommsPhone"
    "Microsoft.ConnectivityStore"
    "Microsoft.Messaging"
    "Microsoft.Office.Sway"
    "Microsoft.OneConnect"
    "Microsoft.WindowsFeedbackHub"


    #Redstone apps
    "Microsoft.BingFoodAndDrink"
    "Microsoft.BingTravel"
    "Microsoft.BingHealthAndFitness"
    "Microsoft.WindowsReadingList"

    # non-Microsoft
    "9E2F88E3.Twitter"
    "PandoraMediaInc.29680B314EFC2"
    "Flipboard.Flipboard"
    "ShazamEntertainmentLtd.Shazam"
    "king.com.*"
    "4DF9E0F8.Netflix"
    "6Wunderkinder.Wunderlist"
    "Drawboard.DrawboardPDF"
    "2FE3CB00.PicsArt-PhotoStudio"
    "D52A8D61.FarmVille2CountryEscape"
    "GAMELOFTSA.Asphalt8Airborne"
    "Facebook.Facebook"
    "flaregamesGmbH.RoyalRevolt2"
    "Playtika.CaesarsSlotsFreeCasino"

)

foreach ($app in $apps) {
    echo "Trying to remove $app"

    Get-AppxPackage -Name $app -AllUsers | Remove-AppxPackage

    Get-AppXProvisionedPackage -Online |
        where DisplayName -EQ $app |
        Remove-AppxProvisionedPackage -Online
}

# Uninstall Work Folders Client
Write-Host "Uninstalling Work Folders Client..."
dism /online /Disable-Feature /FeatureName:WorkFolders-Client /Quiet /NoRestart

# Uninstall Windows Media Player
Write-Host "Uninstalling Windows Media Player..."
dism /online /Disable-Feature /FeatureName:MediaPlayback /Quiet /NoRestart


# Disable Wi-Fi Sense
Write-Host "Disabling Wi-Fi Sense..."
If (!(Test-Path "HKLM:\Software\Microsoft\PolicyManager\default\WiFi\AllowWiFiHotSpotReporting")) {
    New-Item -Path "HKLM:\Software\Microsoft\PolicyManager\default\WiFi\AllowWiFiHotSpotReporting" -Force | Out-Null
}
Set-ItemProperty -Path "HKLM:\Software\Microsoft\PolicyManager\default\WiFi\AllowWiFiHotSpotReporting" -Name "Value" -Type DWord -Value 0
Set-ItemProperty -Path "HKLM:\Software\Microsoft\PolicyManager\default\WiFi\AllowAutoConnectToWiFiSenseHotspots" -Name "Value" -Type DWord -Value 0
 
# Disable Bing Search in Start Menu
Write-Host "Disabling Bing Search in Start Menu..."
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" -Name "BingSearchEnabled" -Type DWord -Value 0
 
 # Disable Feedback
Write-Host "Disabling Feedback..."
If (!(Test-Path "HKCU:\Software\Microsoft\Siuf\Rules")) {
    New-Item -Path "HKCU:\Software\Microsoft\Siuf\Rules" -Force | Out-Null
}
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Siuf\Rules" -Name "NumberOfSIUFInPeriod" -Type DWord -Value 0
 

# Restrict Windows Update P2P only to local network
Write-Host "Restricting Windows Update P2P only to local network..."
Set-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Config" -Name "DODownloadMode" -Type DWord -Value 1
If (!(Test-Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\DeliveryOptimization")) {
    New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\DeliveryOptimization" | Out-Null
}
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\DeliveryOptimization" -Name "SystemSettingsDownloadMode" -Type DWord -Value 3


# Disable Firewall
 Write-Host "Disabling Firewall..."
 Set-NetFirewallProfile -Profile * -Enabled False

# Enable Remote Assistance
Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Remote Assistance" -Name "fAllowToGetHelp" -Type DWord -Value 1
 
# Enable Remote Desktop w/o Network Level Authentication
Write-Host "Enabling Remote Desktop w/o Network Level Authentication..."
Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Terminal Server" -Name "fDenyTSConnections" -Type DWord -Value 0
Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" -Name "UserAuthentication" -Type DWord -Value 0
 
Disable Action Center
Write-Host "Disabling Action Center..."
If (!(Test-Path "HKCU:\Software\Policies\Microsoft\Windows\Explorer")) {
New-Item -Path "HKCU:\Software\Policies\Microsoft\Windows\Explorer" | Out-Null
}
Set-ItemProperty -Path "HKCU:\Software\Policies\Microsoft\Windows\Explorer" -Name "DisableNotificationCenter" -Type DWord -Value 1
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\PushNotifications" -Name "ToastEnabled" -Type DWord -Value 0
 
# Hide Search button / box
Write-Host "Hiding Search Box / Button..."
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" -Name "SearchboxTaskbarMode" -Type DWord -Value 0
 
# Show Search button / box
Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" -Name "SearchboxTaskbarMode"
 
# Hide Task View button
Write-Host "Hiding Task View button..."
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowTaskViewButton" -Type DWord -Value 0

# Show known file extensions
Write-Host "Showing known file extensions..."
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "HideFileExt" -Type DWord -Value 0
 
# Change default Explorer view to "Computer"
Write-Host "Changing default Explorer view to `"Computer`"..."
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "LaunchTo" -Type DWord -Value 1

# Set Photo Viewer as default for bmp, gif, jpg and png
Write-Host "Setting Photo Viewer as default for bmp, gif, jpg, png and tif..."
If (!(Test-Path "HKCR:")) {
    New-PSDrive -Name HKCR -PSProvider Registry -Root HKEY_CLASSES_ROOT | Out-Null
}
ForEach ($type in @("Paint.Picture", "giffile", "jpegfile", "pngfile")) {
    New-Item -Path $("HKCR:\$type\shell\open") -Force | Out-Null
    New-Item -Path $("HKCR:\$type\shell\open\command") | Out-Null
    Set-ItemProperty -Path $("HKCR:\$type\shell\open") -Name "MuiVerb" -Type ExpandString -Value "@%ProgramFiles%\Windows Photo Viewer\photoviewer.dll,-3043"
    Set-ItemProperty -Path $("HKCR:\$type\shell\open\command") -Name "(Default)" -Type ExpandString -Value "%SystemRoot%\System32\rundll32.exe `"%ProgramFiles%\Windows Photo Viewer\PhotoViewer.dll`", ImageView_Fullscreen %1"
}

# Show Photo Viewer in "Open with..."
Write-Host "Showing Photo Viewer in `"Open with...`""
If (!(Test-Path "HKCR:")) {
    New-PSDrive -Name HKCR -PSProvider Registry -Root HKEY_CLASSES_ROOT | Out-Null
}
New-Item -Path "HKCR:\Applications\photoviewer.dll\shell\open\command" -Force | Out-Null
New-Item -Path "HKCR:\Applications\photoviewer.dll\shell\open\DropTarget" -Force | Out-Null
Set-ItemProperty -Path "HKCR:\Applications\photoviewer.dll\shell\open" -Name "MuiVerb" -Type String -Value "@photoviewer.dll,-3043"
Set-ItemProperty -Path "HKCR:\Applications\photoviewer.dll\shell\open\command" -Name "(Default)" -Type ExpandString -Value "%SystemRoot%\System32\rundll32.exe `"%ProgramFiles%\Windows Photo Viewer\PhotoViewer.dll`", ImageView_Fullscreen %1"
Set-ItemProperty -Path "HKCR:\Applications\photoviewer.dll\shell\open\DropTarget" -Name "Clsid" -Type String -Value "{FFE2A43C-56B9-4bf5-9A79-CC6D4285608A}"
 

      
#---------------------------------------------------------------------------------------

Write-Host "Customising start menu for all new users." -ForegroundColor Magenta
Copy-Item -Path $SupportDir'\Internet Explorer.lnk' -Destination $env:SystemDrive'\ProgramData\Microsoft\Windows\Start Menu\Programs\Accessories'
Import-StartLayout -LayoutPath $SupportDir\StartLayout.xml -MountPath $env:SystemDrive\

#Set Default App associations for Adobe & IE
#dism.exe /online /Import-DefaultAppAssociations:$PSScriptRoot\AppAssociations.xml

#---------------------------------------------------------------------------------------

#Disable Firewall and BCD

Write-Host "Deleting public desktop shortcuts, disabling Windows Firewall and disabling DEP using BCDEdit." -ForegroundColor Magenta
Remove-Item "C:\Users\Public\Desktop\*"

#---------------------------------------------------------------------------------------

#Rename Computer
$name = Read-Host -Prompt "Please Enter the ComputerName you want to use."
Rename-Computer -ComputerName (hostname) -NewName $Name

#Set Timezone to AEST
Write-Host "Setting time Timezone to AEST"
Set-TimeZone -Id "E. Australia Standard Time"

#---------------------------------------------------------------------------------------


#Open Add/Remove program console, System Properties, Date/Time, Region and Power configuration
Write-Host "The Windows 10 Runup Script has finished. Applications Installed: Adobe Reader, Java, Teamviewer. Windows firewall is disabled, Start menu customised for new users, Power settings set to high Performance and HDD sleep disabled. Run CSMRemoval.bat if you need to remove HP Bloatware." -ForegroundColor Magenta


start-sleep 0.5

Write-Host "Press any key to restart your system..." -ForegroundColor Black -BackgroundColor White
$key = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
Write-Host "Restarting..."
Restart-Computer

