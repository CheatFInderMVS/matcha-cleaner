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

:: 8. ROOT DISK SCAN: Search and delete folders containing "matcha" at the root of every drive
echo Searching for folders containing "matcha" at disk roots...
for %%d in (A B C D E F G H I J K L M N O P Q R S T U V W X Y Z) do (
    if exist %%d:\ (
        for /f "delims=" %%f in ('dir /b/a:d "%%d:\" ^| findstr /i "matcha"') do (
            echo [FOUND] Folder detected at %%d:\%%f
            rmdir /s /q "%%d:\%%f" >nul 2>&1
        )
    )
)

:: 9. Restarting Explorer
echo Restarting Explorer...
start explorer.exe

echo --- CLEANUP COMPLETE ---
pause
