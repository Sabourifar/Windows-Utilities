@echo off
setlocal enabledelayedexpansion

NET FILE >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo == Requesting administrative privileges...
    powershell -NoProfile -Command ^
        "if (Get-Command wt.exe -ErrorAction SilentlyContinue) { Start-Process wt.exe -ArgumentList 'cmd /c \"%~f0\"' -Verb RunAs } else { Start-Process cmd.exe -ArgumentList '/c \"%~f0\"' -Verb RunAs }" >nul 2>&1
    exit
)

title DFStartup v26 by Sabourifar

echo ============================================= DFStartup v26 by Sabourifar ==============================================
echo.

reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Power" /v HiberbootEnabled /t REG_DWORD /d 0 /f >nul 2>&1

echo Fast Startup has been DISABLED.
echo Restart your PC for the change to take effect.
echo.
echo Press any key to close this window . . .
pause >nul