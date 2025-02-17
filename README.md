# TFAR (Task Force Arma 3 Radio) Comprehensive Installer

## One-Click Installation
Run `TFAR_Installer.bat` - that's it. This automatically installs everything needed for TFAR:
- Arma 3 mod
- TeamSpeak plugin
- Correct configuration

If the installer fails, try running as administrator or follow the manual steps below.

## Version Selection (Optional)
Edit `tfar_mod_version.txt` to change TFAR version (Default: 1.0.334)

---

## Manual Installation Guide
Only needed if the installer fails:

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
