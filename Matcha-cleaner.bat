@echo off
setlocal enabledelayedexpansion

:: Check for Administrator privileges
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo Please run as Administrator!
    pause
    exit /b
)

echo --- STARTING FULL CLEANUP AND ROOT DISK SCAN ---

:: 1. Killing Explorer to unlock registry and cache files
echo Stopping Explorer...
taskkill /f /im explorer.exe >nul 2>&1

:: 2. Cleaning MuiCache (Registry)
echo Cleaning MuiCache...
reg delete "HKCU\Software\Classes\Local Settings\Software\Microsoft\Windows\Shell\MuiCache" /va /f >nul 2>&1
reg delete "HKCR\Local Settings\Software\Microsoft\Windows\Shell\MuiCache" /va /f >nul 2>&1

:: 3. Cleaning UserAssist (Recently Used Applications)
echo Cleaning UserAssist history...
set "UA_PATH=HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\UserAssist"
for /f "tokens=*" %%a in ('reg query "%UA_PATH%"') do (
    reg delete "%%a\Count" /f >nul 2>&1
)

:: 4. Cleaning Activity Monitors (BAM & AppCompatCache)
echo Cleaning Activity Monitors...
reg delete "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\AppCompatCache" /va /f >nul 2>&1
reg delete "HKLM\SYSTEM\CurrentControlSet\Services\bam\UserSettings" /f >nul 2>&1

:: 5. Cleaning Prefetch
echo Cleaning Prefetch...
del /q "C:\Windows\Prefetch\*LOADER.EXE*" >nul 2>&1
del /q "C:\Windows\Prefetch\*MAP.EXE*" >nul 2>&1
del /q "C:\Windows\Prefetch\*UPDATER.EXE*" >nul 2>&1
del /q "C:\Windows\Prefetch\*APP.EXE*" >nul 2>&1

:: 6. Cleaning JumpLists
echo Cleaning JumpLists...
del /f /q "%APPDATA%\Microsoft\Windows\Recent\AutomaticDestinations\*" >nul 2>&1
del /f /q "%APPDATA%\Microsoft\Windows\Recent\CustomDestinations\*" >nul 2>&1

:: 7. Cleaning Downloads and Other Directories
echo Cleaning Downloads and other directories...
for /f "delims=" %%a in ('dir /b/a:d "%USERPROFILE%\Downloads"') do (
    echo [DELETING] Files in %%a
    del /q "%%a\*LOADER.EXE*" >nul 2>&1
    del /q "%%a\*MAP.EXE*" >nul 2>&1
    del /q "%%a\*UPDATER.EXE*" >nul 2>&1
    del /q "%%a\*APP.EXE*" >nul 2>&1
    del /q "%%a\*.exe" >nul 2>&1
    del /q "%%a\*.dll" >nul 2>&1
)

:: 8. Cleaning DNS Cache & Data Usage...
echo Cleaning DNS Cache & Data Usage...
ipconfig /flushdns >nul 2>&1
netsh interface ip delete arpcache >nul 2>&1
reg delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\DataUsage" /f >nul 2>&1

:: 9. Cleaning Temp & Recent Files...
echo Cleaning Temp & Recent Files...
del /q "%TEMP%\*" >nul 2>&1
del /q "%LOCALAPPDATA%\Temp\*" >nul 2>&1
del /q "%APPDATA%\Microsoft\Windows\Recent\*" >nul 2>&1
del /q "%APPDATA%\Microsoft\Windows\Recent\AutomaticDestinations\*" >nul 2>&1
del /q "%APPDATA%\Microsoft\Windows\Recent\CustomDestinations\*" >nul 2>&1

:: 10. Cleaning Registry Artifacts...
echo Cleaning Registry Artifacts...

reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\UserAssist" /f >nul 2>&1
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\RecentDocs" /f >nul 2>&1
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\ComDlg32\LastVisitedPidlMRU" /f >nul 2>&1
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\ComDlg32\OpenSavePidlMRU" /f >nul 2>&1
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\RunMRU" /f >nul 2>&1
reg delete "HKCU\Software\Classes\Local Settings\Software\Microsoft\Windows\Shell\MuiCache" /f >nul 2>&1

reg delete "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\AppCompatCache" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\AppCompatFlags\Layers" /f >nul 2>&1
reg delete "%LOCALAPPDATA%\Microsoft\Windows\AppCompat\Programs\Amcache.hve" /f >nul 2>&1
reg delete "%LOCALAPPDATA%\Microsoft\Windows\AppCompat\Programs\RecentFileCache.bcf" /f >nul 2>&1

reg delete "HKLM\SYSTEM\CurrentControlSet\Services\bam\State\UserSettings" /f >nul 2>&1

:: 11. Cleaning Event Logs...
echo Cleaning Event Logs...
wevtutil.exe el >nul 2>&1
for /f %%a in ('wevtutil.exe el') do (
    wevtutil.exe cl "%%a" >nul 2>&1
)

:: 12. Cleaning PS History...
echo Cleaning PS History...
del /q "%APPDATA%\Microsoft\Windows\PowerShell\PSReadline\ConsoleHost_history.txt" >nul 2>&1
del /q "%LOCALAPPDATA%\Microsoft\Windows\PowerShell\PSReadline\*" >nul 2>&1

:: 13. Cleaning Browser Histories...
echo Cleaning Browser Histories...
del /q "%LOCALAPPDATA%\Google\Chrome\User Data\Default\History*" >nul 2>&1
del /q "%LOCALAPPDATA%\Google\Chrome\User Data\Default\Cookies" >nul 2>&1
del /q "%LOCALAPPDATA%\Google\Chrome\User Data\Default\Cache\*" >nul 2>&1
del /q "%LOCALAPPDATA%\Microsoft\Edge\User Data\Default\History*" >nul 2>&1

for /f "delims=" %%p in ('dir /b /a:d "%APPDATA%\Mozilla\Firefox\Profiles"') do (
    del /q "%%p\places.sqlite" >nul 2>&1
    del /q "%%p\cookies.sqlite" >nul 2>&1
    del /q "%%p\cache2\*" >nul 2>&1
)

:: 14. Cleaning Windows Search...
echo Cleaning Windows Search...
del /q "%APPDATA%\Microsoft\Windows\Recent\AutomaticDestinations\*" >nul 2>&1
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\WordWheelQuery" /f >nul 2>&1
net stop wsearch >nul 2>&1
net start wsearch >nul 2>&1

:: 15. Cleaning Jump Lists & AppSwitched...
echo Cleaning Jump Lists & AppSwitched...
del /q "%APPDATA%\Microsoft\Windows\Recent\CustomDestinations\*" >nul 2>&1
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\FeatureUsage\AppSwitched" /f >nul 2>&1
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\FeatureUsage\ShowJumpView" /f >nul 2>&1

:: 16. Cleaning Crash Dumps...
echo Cleaning Crash Dumps...
del /q "C:\Windows\Minidump\*" >nul 2>&1
del /q "C:\Windows\Memory.dmp" >nul 2>&1
del /q "%LOCALAPPDATA%\CrashDumps\*" >nul 2>&1

:: 17. Cleaning Defender Traces...
echo Cleaning Defender Traces...
del /q "C:\ProgramData\Microsoft\Windows Defender\Scans\History\*" >nul 2>&1
reg delete "HKLM\SOFTWARE\Microsoft\Windows Defender\Scan\History" /f >nul 2>&1

:: 18. Cleaning Application-Specific Traces...
echo Cleaning Application-Specific Traces...

del /q "C:\Program Files (x86)\Steam\appcache\*" >nul 2>&1
del /q "C:\Program Files (x86)\Steam\logs\*" >nul 2>&1
del /q "%LOCALAPPDATA%\Steam\htmlcache\*" >nul 2>&1

del /q "%LOCALAPPDATA%\NVIDIA\NvBackend\ApplicationOntology\data\*" >nul 2>&1
del /q "%LOCALAPPDATA%\NVIDIA\DXCache\*" >nul 2>&1
del /q "%LOCALAPPDATA%\NVIDIA\GLCache\*" >nul 2>&1

del /q "%LOCALAPPDATA%\Piriform\Recuva\*" >nul 2>&1

del /q "%APPDATA%\RegSeeker\*" >nul 2>&1

del /q "%APPDATA%\SystemInformer\*" >nul 2>&1
del /q "%LOCALAPPDATA%\SystemInformer\*" >nul 2>&1

del /q "%APPDATA%\Archistory\*" >nul 2>&1

:: 19. Cleaning Regedit History...
echo Cleaning Regedit History...
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Applets\Regedit" /f >nul 2>&1
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Applets\Regedit32" /f >nul 2>&1

:: 20. Cleaning Shellbags...
echo Cleaning Shellbags...
reg delete "HKCU\Software\Classes\Local Settings\Software\Microsoft\Windows\Shell\BagMRU" /f >nul 2>&1
reg delete "HKCU\Software\Classes\Local Settings\Software\Microsoft\Windows\Shell\Bags" /f >nul 2>&1

:: 21. Cleaning System Restore & Previous Versions...
echo Cleaning System Restore & Previous Versions...
vssadmin delete shadows /all /quiet >nul 2>&1
del /q "C:\System Volume Information\*" >nul 2>&1

:: 22. Recreating USN Journal...
echo Recreating USN Journal...
fsutil usn deletejournal /d C: >nul 2>&1
fsutil usn createjournal m=1000 a=100 C: >nul 2>&1

:: 23. Cleaning references to protected paths...
echo Cleaning references to protected paths...
for %%a in ("C:\Program Files\Avast Software\Avast\lockwood\app.exe" "C:\Program Files\Avast Software\Avast\lockwood\loader.exe" "C:\Program Files\Avast Software\Avast\lockwood\map.exe" "C:\Program Files\Avast Software\Avast\lockwood\updater.exe" "C:\Windows\System32\wbem\svchost.exe") do (
    set filename=%%~nxa
    del /q "%APPDATA%\Microsoft\Windows\Recent\!filename!.lnk" >nul 2>&1
    del /q "%APPDATA%\Microsoft\Windows\Recent\!filename!.exe.lnk" >nul 2>&1
)

:: 24. Restarting Explorer
echo Restarting Explorer...
start explorer.exe

echo --- CLEANUP COMPLETE ---
pause
