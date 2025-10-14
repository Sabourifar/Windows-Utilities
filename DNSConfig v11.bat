@echo off
setlocal enabledelayedexpansion

:: Check for administrator privileges and request elevation if needed
NET FILE >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo  == Requesting administrative privileges...
    powershell -noprofile -command "Start-Process '%~f0' -Verb RunAs" >nul
    exit /b
)

:: Set the window title
title DNSConfig v11 by Sabourifar

:: Define constants for UI elements and PowerShell command prefix
set "line_sep========================================================================================================================="
set "double_eq=  == "
set "quad_eq=  ==== "
set "pscmd=powershell -noprofile -command"
set "invalid_msg=Invalid selection. Please try again."

:: Define message variables for consistency
set "applying_msg=Applying DNS settings"
set "clearing_msg=Clearing DNS cache"
set "cleared_msg=DNS cache flushed successfully."

:: Define DNS provider database (Name=Primary=Secondary)
set "dns_providers[1]=Cloudflare=1.1.1.1=1.0.0.1"
set "dns_providers[2]=Google=8.8.8.8=8.8.4.4"
set "dns_providers[3]=Quad9=9.9.9.9=149.112.112.112"
set "dns_providers[4]=OpenDNS=208.67.222.222=208.67.220.220"
set "dns_providers[5]=UltraDNS=64.6.64.6=64.6.65.6"
set "dns_providers[6]=NTT=129.250.35.250=129.250.35.251"
set "dns_providers[7]=Shecan=178.22.122.100=185.51.200.2"
set "dns_providers[8]=Begzar=185.55.226.26=185.55.225.25"
set "dns_providers[9]=Radar=10.202.10.10=10.202.10.11"
set "dns_providers[10]=Electro=78.157.42.100=78.157.42.101"
set "dns_providers[11]=DNSCrypt=127.0.0.1="
set "dns_count=11"

:: Display the initial title
echo ============================================= DNSConfig v11 by Sabourifar ==============================================
echo.

:: Detect and display DNS configuration
call :detect_and_show_dns
if not defined interface goto no_interface_menu

:main_menu
:: Display main menu and get user input
set "choice="
echo %line_sep%
echo.
echo  # Select DNS configuration method
echo.
echo  1. Select preconfigured DNS
echo  2. Configure DNS manually
echo  3. Use automatic DNS (DHCP)
echo  4. DNS server ping test
echo  5. Clear DNS cache
echo  6. Reset network settings
echo  7. View current DNS settings
echo  0. Exit
echo.
set /p "choice=Enter your choice: "
echo.

:: Process main menu selection
if "%choice%"=="" goto invalid_main
if "%choice%"=="1" goto :choice_1
if "%choice%"=="2" goto :choice_2
if "%choice%"=="3" goto :choice_3
if "%choice%"=="4" goto :choice_4
if "%choice%"=="5" goto :choice_5
if "%choice%"=="6" goto :choice_6
if "%choice%"=="7" goto :choice_7
if "%choice%"=="0" exit

:invalid_main
echo %line_sep%
echo.
echo  %invalid_msg%
echo.
goto main_menu

:no_interface_menu
:: Display limited menu when no interface is detected
set "choice="
echo %line_sep%
echo.
echo  # Only DNS cache clearing and network reset are available - connect to a network to configure DNS
echo.
echo  1. Clear DNS cache
echo  2. Reset network settings
echo  0. Exit
echo.
set /p "choice=Enter your choice: "
echo.

:: Process no-interface menu selection
if "%choice%"=="" goto invalid_no_interface
if "%choice%"=="1" goto :flush_dns
if "%choice%"=="2" call :network_reset & goto :exit_menu
if "%choice%"=="0" exit

:invalid_no_interface
echo %line_sep%
echo.
echo  %invalid_msg%
echo.
goto no_interface_menu

:choice_1
call :choose_dns
goto :exit_menu

:choice_2
call :advanced_dns
goto :exit_menu

:choice_3
call :set_dhcp
goto :exit_menu

:choice_4
call :check_dns_ping_test
goto :exit_menu

:choice_5
call :flush_dns
goto :exit_menu

:choice_6
call :network_reset
goto :exit_menu

:choice_7
echo %line_sep%
echo.
call :detect_and_show_dns
echo %line_sep%
echo.
goto :exit_menu

:check_dns_ping_test
echo %line_sep%
echo.
echo %double_eq%Performing DNS server ping test...
echo.

for /l %%i in (1,1,10) do (
    for /f "tokens=1-3 delims==" %%a in ("!dns_providers[%%i]!") do (
        echo %quad_eq%%%i. %%a
        call :ping_server "%%b" status1
        echo %quad_eq%Primary: %%b - !status1!
        if "%%c" NEQ "" (
            call :ping_server "%%c" status2
            echo %quad_eq%Secondary: %%c - !status2!
        )
        echo.
    )
)

echo %line_sep%
echo.

:: Clear input buffer after ping test
call :clear_input_buffer

exit /b

:ping_server
set "ip=%~1"
set "result=Unreachable"

:: Use 2 pings with low timeout for faster unreachable detection
for /f "tokens=9 delims= " %%r in ('ping -n 2 -w 10 %ip% 2^>nul ^| findstr "Average"') do set "result=%%r"
set "%~2=!result!"
exit /b

:clear_input_buffer
:: More reliable method to clear input buffer using PowerShell
>nul powershell -noprofile -command "if($Host.UI.RawUI.KeyAvailable){$Host.UI.RawUI.FlushInputBuffer()}"
exit /b

:detect_and_show_dns
echo %double_eq%Detecting active network interface...
echo.

:: Detect the active network interface using netsh
set "interface="
for /f "tokens=3,*" %%a in ('netsh interface show interface ^| findstr /C:"Connected"') do (
    set "interface=%%b"
    goto :break_interface
)
:break_interface

if not defined interface (
    echo %quad_eq%No active network interface found
    echo.
    exit /b
)

echo %quad_eq%Active network interface: %interface%
echo.

:: Check if DNS is set to DHCP
set "is_dhcp=0"
for /f "tokens=*" %%a in ('netsh interface ipv4 show dnsservers "%interface%" ^| findstr /i "dhcp"') do set "is_dhcp=1"

:: Retrieve current DNS settings for the interface
set "primary_dns=" & set "secondary_dns="
for /f "tokens=1,2" %%a in ('!pscmd! "@(Get-DnsClientServerAddress -InterfaceAlias '%interface%' -AddressFamily IPv4 | %%{ $_.ServerAddresses }) -join ' '"') do (
    set "primary_dns=%%a"
    set "secondary_dns=%%b"
)

if !is_dhcp! EQU 1 (
    echo %quad_eq%DNS name: DHCP
    echo %quad_eq%Primary DNS: %primary_dns%
    if defined secondary_dns (
        echo %quad_eq%Secondary DNS: %secondary_dns%
    ) else (
        echo %quad_eq%Secondary DNS: Not configured
    )
    echo.
    exit /b
)

:: Look up DNS provider names in a single loop
set "primary_name=Unknown"
set "secondary_name=Unknown"
set "both_same_provider=0"
for /l %%i in (1,1,%dns_count%) do (
    for /f "tokens=1-3 delims==" %%a in ("!dns_providers[%%i]!") do (
        if "!primary_dns!"=="%%b" if "!secondary_dns!"=="%%c" (
            set "primary_name=%%a"
            set "secondary_name=%%a"
            set "both_same_provider=1"
        )
        if "!primary_dns!"=="%%b" set "primary_name=%%a"
        if "!primary_dns!"=="%%c" set "primary_name=%%a"
        if "!secondary_dns!"=="%%b" set "secondary_name=%%a"
        if "!secondary_dns!"=="%%c" set "secondary_name=%%a"
    )
)

:: Display DNS configuration
if !both_same_provider! EQU 1 (
    echo %quad_eq%DNS name: !primary_name!
    echo %quad_eq%Primary DNS: !primary_dns!
    if defined secondary_dns (
        echo %quad_eq%Secondary DNS: !secondary_dns!
    ) else (
        echo %quad_eq%Secondary DNS: Not configured
    )
) else (
    if defined primary_dns (
        if "!primary_name!" NEQ "Unknown" echo %quad_eq%Primary DNS name: !primary_name!
        echo %quad_eq%Primary DNS: !primary_dns!
    ) else (
        echo %quad_eq%Primary DNS: Not configured
    )
    echo.
    if defined secondary_dns (
        if "!secondary_name!" NEQ "Unknown" echo %quad_eq%Secondary DNS name: !secondary_name!
        echo %quad_eq%Secondary DNS: !secondary_dns!
    ) else (
        echo %quad_eq%Secondary DNS: Not configured
    )
)
echo.
exit /b

:set_dhcp
echo %line_sep%
echo.
echo %double_eq%!applying_msg!...
echo.

netsh interface ipv4 set dns name="%interface%" source=dhcp >nul

call :detect_and_show_dns
echo %line_sep%
echo.
call :perform_dns_flush
goto :exit_menu

:choose_dns
:retry_dns
set "dnschoice="
echo %line_sep%
echo.
echo  # Select preconfigured DNS server
echo.
echo  1. Cloudflare
echo  2. Google
echo  3. Quad9
echo  4. OpenDNS
echo  5. UltraDNS
echo  6. NTT
echo  7. Shecan
echo  8. Begzar
echo  9. Radar
echo  10. Electro
echo  11. DNSCrypt
echo  0. Back to main menu
echo.
set /p "dnschoice=Enter your choice: "
echo.

if "%dnschoice%"=="0" goto main_menu

set "valid_choice=0"
for /l %%i in (1,1,%dns_count%) do if "%dnschoice%"=="%%i" set "valid_choice=1"

if !valid_choice! EQU 0 goto invalid_dns

set "NAME=" & set "DNS1=" & set "DNS2="
for /f "tokens=1-3 delims==" %%a in ("!dns_providers[%dnschoice%]!") do (
    set "NAME=%%a"
    set "DNS1=%%b"
    set "DNS2=%%c"
)

goto apply_dns

:invalid_dns
echo %line_sep%
echo.
echo  %invalid_msg%
echo.
goto retry_dns

:advanced_dns
echo %line_sep%
echo.
:get_primary
set "DNS1="
set /p "DNS1=Enter primary DNS server: "
echo.

if not defined DNS1 goto invalid_format_primary
call :validate_ip "!DNS1!"
if !ERRORLEVEL! NEQ 0 goto invalid_format_primary

:get_secondary
set "DNS2="
set /p "DNS2=Enter secondary DNS server (optional): "
echo.

if defined DNS2 if "!DNS2!" NEQ "" (
    call :validate_ip "!DNS2!"
    if !ERRORLEVEL! NEQ 0 goto invalid_format_secondary
)

:: Check if entered DNS matches known providers
set "custom_name="
set "found_provider=0"
for /l %%i in (1,1,%dns_count%) do (
    for /f "tokens=1-3 delims==" %%a in ("!dns_providers[%%i]!") do (
        if "!DNS1!"=="%%b" if "!DNS2!"=="%%c" (
            set "custom_name=%%a"
            set "found_provider=1"
        )
    )
)

if !found_provider! EQU 1 (
    set "NAME=!custom_name! (manual)"
) else (
    set "NAME=Custom"
)

goto apply_dns

:invalid_format_primary
echo %line_sep%
echo.
echo  Invalid DNS format. Please enter a valid IP address (format: X.X.X.X)
echo.
goto get_primary

:invalid_format_secondary
echo %line_sep%
echo.
echo  Invalid DNS format. Please enter a valid IP address (format: X.X.X.X)
echo.
goto get_secondary

:validate_ip
set "ip=%~1"
set "valid=1"

for /f "tokens=1-4 delims=." %%a in ("!ip!") do (
    set "oct1=%%a" & set "oct2=%%b" & set "oct3=%%c" & set "oct4=%%d"
)

if not defined oct4 set "valid=0"
if not defined oct3 set "valid=0"
if not defined oct2 set "valid=0"
if not defined oct1 set "valid=0"

if !valid! EQU 1 (
    for %%o in (!oct1! !oct2! !oct3! !oct4!) do (
        echo %%o| findstr /r "^[0-9]*$" >nul || set "valid=0"
        if %%o LSS 0 set "valid=0"
        if %%o GTR 255 set "valid=0"
        if "%%o" NEQ "0" if "%%o" GEQ "00" if "%%o" LEQ "09" set "valid=0"
    )
)

if !valid! EQU 0 (exit /b 1) else (exit /b 0)

:apply_dns
echo %line_sep%
echo.
echo %double_eq%!applying_msg!...
echo.

netsh interface ipv4 set dns name="%interface%" static %DNS1% primary >nul
if defined DNS2 if "%DNS2%" NEQ "" netsh interface ipv4 add dns name="%interface%" %DNS2% index=2 >nul

call :detect_and_show_dns
echo %line_sep%
echo.
call :perform_dns_flush
goto :exit_menu

:perform_dns_flush
echo %double_eq%!clearing_msg!...
echo.
ipconfig /flushdns >nul 2>&1
if !ERRORLEVEL! EQU 0 (
    echo %quad_eq%!cleared_msg!
) else (
    echo %quad_eq%Warning: DNS flush failed. Check if DNS Client service is running.
)
echo.
echo %line_sep%
echo.
exit /b

:flush_dns
echo %line_sep%
echo.
call :perform_dns_flush
goto :exit_menu

:network_reset
echo %line_sep%
echo.
echo %double_eq%Network reset warning
echo.
echo %quad_eq%This will perform a comprehensive network reset, including:
echo %quad_eq%- Reset Winsock catalog
echo %quad_eq%- Reset TCP/IP stack
echo %quad_eq%- Reset Windows Firewall
echo %quad_eq%- Flush DNS cache
echo %quad_eq%- Release and renew IP configuration
echo.
echo %quad_eq%Warning: Network connection will be temporarily interrupted!
echo %quad_eq%Some changes may require a system reboot to take full effect.
echo.

set "confirm="
set /p "confirm=Continue with network reset? (Y/N): "
echo.

if /i "!confirm!" NEQ "Y" if /i "!confirm!" NEQ "YES" (
    echo %line_sep%
    echo.
    echo %quad_eq%Network reset cancelled.
    echo.
    echo %line_sep%
    echo.
    goto :exit_menu
)

echo %line_sep%
echo.
echo %double_eq%Performing network reset...
echo.

echo %quad_eq%Resetting Winsock catalog...
netsh winsock reset >nul 2>&1
if !ERRORLEVEL! EQU 0 (echo %quad_eq%Success) else (echo %quad_eq%Warning: Failed)
echo.

echo %quad_eq%Resetting TCP/IP stack...
netsh int ip reset >nul 2>&1
echo %quad_eq%Success
echo.

echo %quad_eq%Resetting Windows Firewall...
netsh advfirewall reset >nul 2>&1
if !ERRORLEVEL! EQU 0 (echo %quad_eq%Success) else (echo %quad_eq%Warning: Failed)
echo.

echo %quad_eq%Flushing DNS cache...
ipconfig /flushdns >nul 2>&1
if !ERRORLEVEL! EQU 0 (echo %quad_eq%Success) else (echo %quad_eq%Warning: Failed - Check DNS Client service)
echo.

echo %quad_eq%Releasing IP configuration...
ipconfig /release >nul 2>&1
if !ERRORLEVEL! EQU 0 (echo %quad_eq%Success) else (echo %quad_eq%Warning: Failed or no DHCP lease)
echo.

echo %quad_eq%Renewing IP configuration...
ipconfig /renew >nul 2>&1
if !ERRORLEVEL! EQU 0 (echo %quad_eq%Success) else (echo %quad_eq%Warning: Failed - Check network connection)
echo.

echo %double_eq%Network reset completed!
echo.
echo %quad_eq%Recommendation: Restart your computer for all changes to take effect.
echo.
echo %line_sep%
echo.
goto :exit_menu

:exit_menu
set "userchoice="
echo  1. Back to main menu
echo  0. Exit
echo.

:: Clear input buffer after operations that take time
call :clear_input_buffer

set /p "userchoice=Enter your choice: "
echo.

if "%userchoice%"=="1" (
    if not defined interface (goto no_interface_menu) else (goto main_menu)
)
if "%userchoice%"=="0" exit

echo %line_sep%
echo.
echo  %invalid_msg%
echo.
echo %line_sep%
echo.
goto exit_menu
