# TFAR (Task Force Arma 3 Radio) Installation Guide

## Quick Install
Run `TFAR_Installer.bat` to automatically complete all installation steps. While administrator rights shouldn't be necessary, try running as administrator if the installer fails.

## Version Selection
Before installing, specify your desired TFAR version:
1. Open `tfar_mod_version.txt` in a text editor
2. Set your preferred version number
   - Default: 1.0.334
   - Available versions: [TFAR Releases](https://github.com/michail-nikolaev/task-force-arma-3-radio/releases/download/1.0-PreRelease/1.-1.0.334.zip)

If the automatic installer fails, follow the manual installation steps below.

## Manual Installation Steps

### A. Arma 3 Mod Installation
1. Download the mod:
   ```
   https://github.com/michail-nikolaev/task-force-arma-3-radio/releases/download/1.0-PreRelease/1.-1.0.334.zip
   ```
   Browse all versions: https://github.com/michail-nikolaev/task-force-arma-3-radio/releases/tag/1.0-PreRelease

2. Extract to Arma 3 Workshop directory:
   ```
   E:\SteamLibrary\steamapps\common\Arma 3\!Workshop\
   ```
   You should see: `E:\SteamLibrary\steamapps\common\Arma 3\!Workshop\@TFAR\`

### B. TeamSpeak Plugin Installation
1. Download the plugin:
   ```
   https://github.com/michail-nikolaev/task-force-arma-3-radio/releases/download/1.0-PreRelease/TeamspeakPlugins.zip
   ```
   Note: This plugin is compatible with all TFAR mod versions

2. Extract to TeamSpeak plugins directory:
   ```
   %APPDATA%\TS3Client\plugins
   ```
   Note: `%APPDATA%` typically resolves to `C:\Users\<windows-username>\AppData`

### C. Mod Configuration
1. Launch Arma 3 through Steam
2. Navigate to the MODS tab in the launcher
3. Search for and enable "Task Force Radio"
