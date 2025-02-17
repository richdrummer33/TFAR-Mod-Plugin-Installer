# Prevent window from closing on error
$ErrorActionPreference = "Continue"

Write-Host "`n=== Steam Game Location Finder ===`n" -ForegroundColor Cyan

# Define the Steam App ID
$appId = "107410"  # Example: Arma 3's App ID
Write-Host "Searching for App ID: $appId`n" -ForegroundColor Yellow

Write-Host "Press any key to begin registry search..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

# Try to get Steam path from registry first
try {
    $steamPath = Get-ItemProperty -Path "HKLM:\SOFTWARE\WOW6432Node\Valve\Steam" -Name "InstallPath" -ErrorAction Stop
    $steamPath = $steamPath.InstallPath
    Write-Host "Found Steam path in registry: $steamPath" -ForegroundColor Green
} catch {
    Write-Host "Could not find Steam path in registry. Falling back to common locations..." -ForegroundColor Yellow
    
    # Common Steam installation paths to check
    $possiblePaths = @(
        "${env:ProgramFiles(x86)}\Steam",
        "${env:ProgramFiles}\Steam",
        "$env:ProgramFiles\Steam"
    )

    # Find first valid path
    $steamPath = $null
    foreach ($path in $possiblePaths) {
        if (Test-Path $path) {
            $steamPath = $path
            Write-Host "Found Steam path in common location: $steamPath" -ForegroundColor Green
            break
        }
    }
}

if (-not $steamPath) {
    Write-Host "ERROR: Could not find Steam installation!" -ForegroundColor Red
    Write-Host "`nPress any key to exit..."
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit
}

Write-Host "`nPress any key to search library folders..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

# Check library folders file
$libraryFoldersFile = "$steamPath\steamapps\libraryfolders.vdf"
$libraryPaths = @($steamPath)

if (Test-Path $libraryFoldersFile) {
    try {
        $content = Get-Content $libraryFoldersFile -Raw -ErrorAction Stop
        Write-Host "Successfully read libraryfolders.vdf" -ForegroundColor Green
        
        # Get all Steam library paths
        $additionalPaths = [regex]::Matches($content, '"path"\s+"([^"]+)"') | 
            ForEach-Object { $_.Groups[1].Value.Replace("\\", "\") }
        
        if ($additionalPaths) {
            $libraryPaths += $additionalPaths
            Write-Host "Found additional library paths:" -ForegroundColor Green
            $additionalPaths | ForEach-Object { Write-Host "- $_" }
        }
    } catch {
        Write-Host "WARNING: Error reading libraryfolders.vdf: $_" -ForegroundColor Yellow
    }
} else {
    Write-Host "WARNING: libraryfolders.vdf not found at: $libraryFoldersFile" -ForegroundColor Yellow
}

Write-Host "`nPress any key to begin searching libraries..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

# Search for the game in each library
$gameFound = $false
foreach ($libraryPath in $libraryPaths) {
    Write-Host "`nSearching library: $libraryPath" -ForegroundColor Cyan
    
    $manifestPath = "$libraryPath\steamapps\appmanifest_$appId.acf"
    $gamePath = "$libraryPath\steamapps\common"
    
    if (Test-Path $manifestPath) {
        try {
            $manifestContent = Get-Content $manifestPath -Raw -ErrorAction Stop
            $installDir = [regex]::Match($manifestContent, '"installdir"\s+"([^"]+)"').Groups[1].Value
            
            Write-Host "`nGame found!" -ForegroundColor Green
            Write-Host "Manifest: $manifestPath" -ForegroundColor Green
            Write-Host "Full path: $gamePath\$installDir" -ForegroundColor Green
            
            # Verify the actual game directory exists
            if (Test-Path "$gamePath\$installDir") {
                Write-Host "Directory verified to exist" -ForegroundColor Green
            } else {
                Write-Host "WARNING: Directory does not exist (game might be uninstalled)" -ForegroundColor Yellow
            }
            
            $gameFound = $true
            break
        } catch {
            Write-Host "ERROR reading manifest: $_" -ForegroundColor Red
        }
    }
}

if (-not $gameFound) {
    Write-Host "`nGame not found in any library!" -ForegroundColor Red
}

Write-Host "`nPress any key to exit..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")