# TFAR (Task Force Arma Radio) Automated Installer
# Enhanced with better Steam library detection

param(
    [string]$TeamspeakPath = ""
)

# Prevent window from closing on error
$ErrorActionPreference = "Continue"
$Host.UI.RawUI.WindowTitle = "TFAR Installer"

function Write-Status($message, $color = "Green") {
    Write-Host "`n[STATUS] $message" -ForegroundColor $color -NoNewline
    if ($color -eq "Yellow") { # ... animate
        for ($i = 0; $i -lt 3; $i++) {  
            Start-Sleep -Milliseconds 750
            Write-Host "." -NoNewline -ForegroundColor $color
        }
    }
}

function Write-Error($message) {
    Write-Host "`n[ERROR] $message" -ForegroundColor Red
}

function Write-Section($title) {
    Write-Host "`n========================================" -ForegroundColor Cyan
    Write-Host $title -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
}

function Wait-KeyPress($message = "Press any key to continue...") {
    Write-Host "`n$message" -ForegroundColor Gray
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}

function Find-SteamAndArma {
    # section
    # Write-Section "Arma 3 Mod Installation"

    $arma3AppId = "107410"
    Write-Status "Searching for Arma 3 (App ID: $arma3AppId)." -color "Yellow"
    
    # Get Steam path from registry
    try {
        $steamPath = Get-ItemProperty -Path "HKLM:\SOFTWARE\WOW6432Node\Valve\Steam" -Name "InstallPath" -ErrorAction Stop
        $steamPath = $steamPath.InstallPath
        Write-Status "Found Steam path in registry: $steamPath"
    } catch {
        Write-Status "Registry search failed, checking common locations." -color "Yellow"
        
        $possiblePaths = @(
            "${env:ProgramFiles(x86)}\Steam",
            "${env:ProgramFiles}\Steam",
            "$env:ProgramFiles\Steam"
        )

        foreach ($path in $possiblePaths) {
            if (Test-Path $path) {
                $steamPath = $path
                Write-Status "Found Steam at: $steamPath"
                break
            }
        }
    }

    if (-not $steamPath) {
        throw "Could not find Steam installation!"
    }

    # Get all library folders
    $libraryFoldersFile = "$steamPath\steamapps\libraryfolders.vdf"
    $libraryPaths = @($steamPath)

    if (Test-Path $libraryFoldersFile) {
        try {
            $content = Get-Content $libraryFoldersFile -Raw
            Write-Status "Successfully read libraryfolders.vdf"
            
            # Extract all library paths
            $additionalPaths = [regex]::Matches($content, '"path"\s+"([^"]+)"') | 
                ForEach-Object { $_.Groups[1].Value.Replace("\\", "\") }
            
            if ($additionalPaths) {
                $libraryPaths += $additionalPaths
                Write-Status "Found additional library paths:"
                $additionalPaths | ForEach-Object { Write-Host "- $_" }
            }
        } catch {
            Write-Error "Error reading libraryfolders.vdf: $_" -color "Red"
        }
    }

    # Search for Arma 3 in each library
    foreach ($libraryPath in $libraryPaths) {
        Write-Status "Searching library: $libraryPath" -color "Cyan"
        
        $manifestPath = "$libraryPath\steamapps\appmanifest_$arma3AppId.acf"
        $commonPath = "$libraryPath\steamapps\common"
        
        if (Test-Path $manifestPath) {
            try {
                $manifestContent = Get-Content $manifestPath -Raw
                $installDir = [regex]::Match($manifestContent, '"installdir"\s+"([^"]+)"').Groups[1].Value
                $fullPath = "$commonPath\$installDir"
                
                if (Test-Path $fullPath) {
                    Write-Status "Found Arma 3 installation!"
                    Write-Status "Location: $fullPath"
                    return $fullPath
                }
            } catch {
                Write-Error "Error reading manifest: $_"
            }
        }
    }
    
    throw "Arma 3 not found in any Steam library!"
}

function Get-TeamspeakPluginsPath {
    Write-Status "Locating TeamSpeak plugins folder." -color "Yellow"
    
    if ($TeamspeakPath -eq "") {
        $username = $env:USERNAME
        $defaultPath = "C:\Users\$username\AppData\Roaming\TS3Client"
        
        if (Test-Path $defaultPath) {
            Write-Status "Found TeamSpeak plugins at: $defaultPath"
            return $defaultPath
        }
        
        Write-Status "Default TeamSpeak plugins path not found." -color "Yellow"
        $TeamspeakPath = Read-Host "Enter your TeamSpeak plugins path (default: $defaultPath)"
        if (!(Test-Path $TeamspeakPath)) {
            throw "Invalid TeamSpeak plugins path provided"
        }
    }
    return $TeamspeakPath
}

function Get-AndExtract {
    param(
        [string]$url,
        [string]$destination,
        [string]$description
    )
    
    Write-Status "Downloading $description." -color "Yellow"
    $tempFile = [System.IO.Path]::GetTempFileName() + ".zip"
    
    try {
        Invoke-WebRequest -Uri $url -OutFile $tempFile
        if (!(Test-Path $tempFile)) { throw "Download failed" }

        # Check for locked files
        $testFile = Join-Path $destination "TFAR_win64.dll"
        if (Test-Path $testFile) {
            try {
                $stream = [System.IO.File]::Open($testFile, 'Open', 'Write')
                $stream.Close()
            }
            catch {
                Write-Error "TeamSpeak files are locked. Please close TeamSpeak before continuing."
                Write-Host "1. Close TeamSpeak completely" -ForegroundColor Yellow
                Write-Host "2. Press any key to retry..." -ForegroundColor Yellow
                Wait-KeyPress
                try {
                    Expand-Archive -Path $tempFile -DestinationPath $destination -Force
                }
                catch {
                    throw "Files still locked. Please ensure TeamSpeak is fully closed and try again."
                }
                return
            }
        }
        
        Write-Status "Extracting $description to $destination..."
        Expand-Archive -Path $tempFile -DestinationPath $destination -Force
        
        Write-Status "$description installed successfully!"
        return $true
    }
    catch {
        Write-Error "Failed to process ${description}: $_"
        Wait-KeyPress
        return $false
    }
    finally {
        if (Test-Path $tempFile) {
            Remove-Item $tempFile -Force -ErrorAction SilentlyContinue
        }
    }
}

# Main installation script
try {
    Write-Section "TFAR INSTALLER"
    
    # Find Arma 3 installation
    $armaPath = Find-SteamAndArma
    Wait-KeyPress
    
    # Get TeamSpeak path
    $tsPath = Get-TeamspeakPluginsPath
    Wait-KeyPress
    
    Write-Section "Installing TFAR Mod V1.0.334"
    
    # Create Workshop folder
    $workshopPath = Join-Path $armaPath "!Workshop"
    if (!(Test-Path $workshopPath)) {
        New-Item -ItemType Directory -Path $workshopPath | Out-Null
    }
    
    # ======= Install ARMA mod =======
    # Version # found in txt file, in the same directory as this script. Edit the txt to set the desired version number to download and install.
    $version = Get-Content "tfar_mod_version.txt" 
    $modUrl = "https://github.com/michail-nikolaev/task-force-arma-3-radio/releases/download/1.0-PreRelease/1.-$version.zip"
    $modSuccess = Get-AndExtract -url $modUrl -destination $workshopPath -description "TFAR ARMA Mod"
    Wait-KeyPress
    
    Write-Section "Installing TeamSpeak Plugin"
    
    # =======  Install TeamSpeak plugin ======= 
    $pluginUrl = "https://github.com/michail-nikolaev/task-force-arma-3-radio/releases/download/1.0-PreRelease/TeamspeakPlugins.zip"
    $pluginSuccess = Get-AndExtract -url $pluginUrl -destination $tsPath -description "TFAR TeamSpeak Plugin"
    Wait-KeyPress
    
    if ($modSuccess -and $pluginSuccess) {
        Write-Section "Installation Complete!"
        Write-Host "`nNext steps:" -ForegroundColor Yellow
        Write-Host "1. Open the ARMA 3 launcher"
        Write-Host "2. Go to the MODS tab"
        Write-Host "3. Enable 'Task Force Radio' in the mod list"
        Write-Host "4. Launch TeamSpeak and enable the 'Task Force (arrowhead) Radio' plugin via the Tools > Options > Addons"
        Write-Host "5. Connect to a server and bask in glory!"
        Write-Host "`nEnjoy TFAR!" -ForegroundColor Green -BackgroundColor Blue
    }
    else {
        Write-Section "Installation Incomplete (sad face)"
        Write-Error "Some components failed to install. Please check the messages above."
        Write-Error "See __MANUAL INSTALLATION README__ for help."
    }
}
catch {
    Write-Section "Installation Failed"
    Write-Error $_.Exception.Message
    Write-Host "`nPlease try again or install manually.`n" -ForegroundColor Yellow
}
finally {
    Wait-KeyPress "Press any key to exit..."
}