@echo off
setlocal enabledelayedexpansion
chcp 65001 >nul 2>&1

NET FILE >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo == Requesting administrative privileges...
    powershell -NoProfile -Command ^
        "if (Get-Command wt.exe -ErrorAction SilentlyContinue) { Start-Process wt.exe -ArgumentList 'cmd /c \"%~f0\"' -Verb RunAs } else { Start-Process cmd.exe -ArgumentList '/c \"%~f0\"' -Verb RunAs }" >nul 2>&1
    exit
)

title DNSConfig v26 by Sabourifar

set "LINE_SEP========================================================================================================================="
set "DOUBLE_EQ= == "
set "QUAD_EQ= ==== "
set "GENERAL_ERROR=Please enter a valid option."

set "APPLYING_MSG=Updating DNS configuration"
set "CLEARING_MSG=Flushing DNS resolver cache"
set "CLEARED_MSG=Successfully flushed the DNS resolver cache"

set "dns_providers[1]=Cloudflare=1.1.1.1=1.0.0.1"
set "dns_providers[2]=Google=8.8.8.8=8.8.4.4"
set "dns_providers[3]=Quad9=9.9.9.9=149.112.112.112"
set "dns_providers[4]=OpenDNS=208.67.222.222=208.67.220.220"
set "dns_providers[5]=UltraDNS=64.6.64.6=64.6.65.6"
set "dns_providers[6]=NTT=129.250.35.250=129.250.35.251"
set "dns_providers[7]=Shecan=178.22.122.100=185.51.200.2"
set "dns_providers[8]=Electro=78.157.42.100=78.157.42.101"
set "dns_providers[9]=DNSCrypt=127.0.0.1="
set "DNS_COUNT=9"

set "CACHED_INTERFACE="
set "CACHED_LOCAL_IP="
set "CACHED_GATEWAY_IP="
set "CACHED_DNS_INFO="
set "pings_completed="
set "PING_TIME="

echo ============================================= DNSConfig v26 by Sabourifar ==============================================
echo.
call :detect_and_show_network_info
if not defined interface goto no_interface_menu

:main_menu
set "CHOICE="
if defined SKIP_LEADING_SEP (
    set "SKIP_LEADING_SEP="
    echo.
) else (
    echo %LINE_SEP%
    echo.
)
echo 1. Preconfigured DNS
echo 2. Configure DNS manually
echo 3. Automatic DNS (DHCP)
echo 4. Clear DNS cache
echo 5. View network information
echo 6. Reset network settings
echo.
echo 00. Exit completely
echo.
if not defined pings_completed (
    call :ping_all_dns_background
    set "pings_completed=1"
)
set /p "CHOICE=Enter your choice: "
for /f "tokens=* delims= " %%x in ("!CHOICE!") do set "CHOICE=%%x"
echo.
if "%CHOICE%"=="1" goto choice_1
if "%CHOICE%"=="2" goto choice_2
if "%CHOICE%"=="3" goto choice_3
if "%CHOICE%"=="4" goto choice_4
if "%CHOICE%"=="5" goto choice_5
if "%CHOICE%"=="6" goto choice_6
if "%CHOICE%"=="00" goto exit_program
call :show_error
goto main_menu

:no_interface_menu
set "CHOICE="
if defined SKIP_LEADING_SEP (
    set "SKIP_LEADING_SEP="
    echo.
) else (
    echo %LINE_SEP%
    echo.
)
echo 1. Clear DNS cache
echo 2. Reset network settings
echo.
echo 00. Exit completely
echo.
set /p "CHOICE=Enter your choice: "
for /f "tokens=* delims= " %%x in ("!CHOICE!") do set "CHOICE=%%x"
echo.
if "%CHOICE%"=="1" goto flush_dns
if "%CHOICE%"=="2" call :network_reset & goto exit_menu
if "%CHOICE%"=="00" goto exit_program
call :show_error
goto no_interface_menu

:choice_1
call :choose_dns
goto exit_menu

:choice_2
call :advanced_dns
goto exit_menu

:choice_3
call :set_dhcp
goto exit_menu

:choice_4
call :flush_dns
goto exit_menu

:choice_5
echo %LINE_SEP%
echo.
call :detect_and_show_network_info
echo %LINE_SEP%
set "SKIP_LEADING_SEP=1"
goto exit_menu

:choice_6
call :network_reset
goto exit_menu

:ping_all_dns_background
for /l %%i in (1,1,%DNS_COUNT%) do (
    for /f "tokens=1-3 delims==" %%a in ("!dns_providers[%%i]!") do (
        if %%i EQU 9 (
            set "dns_latency[%%i]=0ms"
        ) else (
            call :ping_server "%%b" dns_latency[%%i]
        )
    )
)
set "PING_TIME=%time:~0,8%"
exit /b

:ping_server
set "IP=%~1"
set "VAR=%~2"
set "RESULT=N/A"
set "ATTEMPTS=0"

:retry_ping
set /a ATTEMPTS+=1
if !ATTEMPTS! GTR 3 (
    set "!VAR!=N/A"
    exit /b
)
for /f "delims=" %%a in ('ping -n 1 -w 300 !IP! 2^>nul ^| findstr /i "TTL"') do (
    set "LINE=%%a"
    set "LINE=!LINE:*time=!"
    if "!LINE!" NEQ "%%a" (
        for /f "tokens=1 delims= " %%t in ("!LINE:~1!") do set "RESULT=%%t"
        goto set_latency
    )
)
goto retry_ping

:set_latency
set "!VAR!=!RESULT!"
exit /b

:choose_dns
:retry_dns
set "DNSCHOICE="
if defined SKIP_LEADING_SEP (
    set "SKIP_LEADING_SEP="
    echo.
) else (
    echo %LINE_SEP%
    echo.
)
for /l %%i in (1,1,%DNS_COUNT%) do (
    for /f "tokens=1-3 delims==" %%a in ("!dns_providers[%%i]!") do (
        if "!dns_latency[%%i]!" NEQ "N/A" (
            echo %%i. %%a ^(!dns_latency[%%i]!^)
        ) else (
            echo %%i. %%a ^(N/A^)
        )
    )
)
echo.
echo Ping time: !PING_TIME!
echo.
echo 10. Ping again
echo.
echo 0. Back to main menu
echo 00. Exit completely
echo.
set /p "DNSCHOICE=Enter your choice: "
for /f "tokens=* delims= " %%x in ("!DNSCHOICE!") do set "DNSCHOICE=%%x"
echo.
if "%DNSCHOICE%"=="0" goto main_menu
if "%DNSCHOICE%"=="00" goto exit_program
if "%DNSCHOICE%"=="10" goto reping_dns
for /l %%i in (1,1,%DNS_COUNT%) do (
    if "%DNSCHOICE%"=="%%i" (
        for /f "tokens=1-3 delims==" %%a in ("!dns_providers[%%i]!") do (
            set "NAME=%%a"
            set "DNS1=%%b"
            set "DNS2=%%c"
        )
        goto apply_dns
    )
)
call :show_error
goto retry_dns

:reping_dns
set "DNSCHOICE="
if defined SKIP_LEADING_SEP (
    set "SKIP_LEADING_SEP="
    echo.
) else (
    echo %LINE_SEP%
    echo.
)
for /l %%i in (1,1,%DNS_COUNT%) do (
    for /f "tokens=1-3 delims==" %%a in ("!dns_providers[%%i]!") do (
        if %%i EQU 9 (
            set "dns_latency[%%i]=0ms"
            echo %%i. %%a ^(!dns_latency[%%i]!^)
        ) else (
            call :ping_server "%%b" latency_temp
            set "dns_latency[%%i]=!latency_temp!"
            echo %%i. %%a ^(!dns_latency[%%i]!^)
        )
    )
)
echo.
echo Ping time: !time:~0,8!
set "PING_TIME=!time:~0,8!"
echo.
echo 10. Ping again
echo.
echo 0. Back to main menu
echo 00. Exit completely
echo.
set /p "DNSCHOICE=Enter your choice: "
for /f "tokens=* delims= " %%x in ("!DNSCHOICE!") do set "DNSCHOICE=%%x"
echo.
if "%DNSCHOICE%"=="0" goto main_menu
if "%DNSCHOICE%"=="00" goto exit_program
if "%DNSCHOICE%"=="10" goto reping_dns
for /l %%i in (1,1,%DNS_COUNT%) do (
    if "%DNSCHOICE%"=="%%i" (
        for /f "tokens=1-3 delims==" %%a in ("!dns_providers[%%i]!") do (
            set "NAME=%%a"
            set "DNS1=%%b"
            set "DNS2=%%c"
        )
        goto apply_dns
    )
)
call :show_error
goto retry_dns

:advanced_dns
echo %LINE_SEP%
echo.

:get_primary
set "DNS1="
set /p "DNS1=Enter primary DNS server: "
for /f "tokens=* delims= " %%x in ("!DNS1!") do set "DNS1=%%x"
echo.
if not defined DNS1 (
    call :show_error
    goto get_primary
)
call :validate_ip "!DNS1!"
if !ERRORLEVEL! NEQ 0 (
    call :show_error
    goto get_primary
)

:get_secondary
set "DNS2="
set /p "DNS2=Enter secondary DNS server (optional): "
for /f "tokens=* delims= " %%x in ("!DNS2!") do set "DNS2=%%x"
echo.
if defined DNS2 if "!DNS2!" NEQ "" (
    call :validate_ip "!DNS2!"
    if !ERRORLEVEL! NEQ 0 (
        call :show_error
        goto get_secondary
    )
)
set "NAME=Custom"
for /l %%i in (1,1,%DNS_COUNT%) do (
    for /f "tokens=1-3 delims==" %%a in ("!dns_providers[%%i]!") do (
        if "!DNS1!"=="%%b" if "!DNS2!"=="%%c" set "NAME=%%a (manual)"
    )
)
goto apply_dns

:validate_ip
set "IP=%~1"
set "VALID=1"
for /f "tokens=1-4 delims=." %%a in ("!IP!") do (
    if %%a GTR 255 set "VALID=0"
    if %%b GTR 255 set "VALID=0"
    if %%c GTR 255 set "VALID=0"
    if %%d GTR 255 set "VALID=0"
)
if !VALID! EQU 0 (exit /b 1) else (exit /b 0)

:apply_dns
echo %LINE_SEP%
echo.
echo %DOUBLE_EQ%!APPLYING_MSG!...
echo.
netsh interface ipv4 set dns name="%interface%" static %DNS1% primary >nul 2>&1
if defined DNS2 if "%DNS2%" NEQ "" netsh interface ipv4 add dns name="%interface%" %DNS2% index=2 >nul 2>&1
set "CACHED_DNS_INFO="
call :detect_and_show_network_info
echo %LINE_SEP%
echo.
set "SKIP_LEADING_SEP=1"
call :perform_dns_flush
goto exit_menu

:perform_dns_flush
echo %DOUBLE_EQ%!CLEARING_MSG!...
echo.
ipconfig /flushdns >nul 2>&1
if !ERRORLEVEL! EQU 0 (
    echo %QUAD_EQ%!CLEARED_MSG!
) else (
    echo %QUAD_EQ%Warning: DNS flush failed. Check if DNS Client service is running.
)
echo.
echo %LINE_SEP%
set "SKIP_LEADING_SEP=1"
exit /b

:flush_dns
echo %LINE_SEP%
echo.
call :perform_dns_flush
exit /b

:detect_and_show_network_info
echo %DOUBLE_EQ%Detecting active network interface...
echo.
if defined CACHED_INTERFACE (
    set "interface=!CACHED_INTERFACE!"
) else (
    for /f "tokens=3,*" %%a in ('netsh interface show interface 2^>nul ^| findstr /C:"Connected"') do (
        set "interface=%%b"
        set "CACHED_INTERFACE=%%b"
        goto break_interface
    )
    :break_interface
    if not defined interface (
        echo %QUAD_EQ%No active network interface found
        echo.
        exit /b
    )
)
echo %QUAD_EQ%Active network interface: %interface%
echo.
if not defined CACHED_LOCAL_IP call :get_local_ip
if not defined CACHED_GATEWAY_IP call :get_gateway_ip
call :get_public_ip
echo %QUAD_EQ%Public IP: !public_ip!
echo %QUAD_EQ%Local IP: !CACHED_LOCAL_IP!
echo %QUAD_EQ%Gateway IP: !CACHED_GATEWAY_IP!
echo.
if not defined CACHED_DNS_INFO call :get_dns_servers
if !is_dhcp! EQU 1 (
    echo %QUAD_EQ%DNS name: DHCP
    echo %QUAD_EQ%Primary DNS: !primary_dns!
    if defined secondary_dns (echo %QUAD_EQ%Secondary DNS: !secondary_dns!) else (echo %QUAD_EQ%Secondary DNS: Not configured)
) else (
    call :identify_current_dns_provider
    if !both_same_provider! EQU 1 (
        echo %QUAD_EQ%DNS name: !primary_name!
        echo %QUAD_EQ%Primary DNS: !primary_dns!
        if defined secondary_dns (echo %QUAD_EQ%Secondary DNS: !secondary_dns!) else (echo %QUAD_EQ%Secondary DNS: Not configured)
    ) else (
        if defined primary_dns (
            if "!primary_name!" NEQ "Unknown" echo %QUAD_EQ%Primary DNS name: !primary_name!
            echo %QUAD_EQ%Primary DNS: !primary_dns!
        ) else (
            echo %QUAD_EQ%Primary DNS: Not configured
        )
        echo.
        if defined secondary_dns (
            if "!secondary_name!" NEQ "Unknown" echo %QUAD_EQ%Secondary DNS name: !secondary_name!
            echo %QUAD_EQ%Secondary DNS: !secondary_dns!
        ) else (
            echo %QUAD_EQ%Secondary DNS: Not configured
        )
    )
)
echo.
exit /b

:get_local_ip
set "CACHED_LOCAL_IP=Not available"
for /f "tokens=2 delims=:" %%a in ('ipconfig 2^>nul ^| findstr /c:"IPv4 Address"') do (
    set "CACHED_LOCAL_IP=%%a"
    set "CACHED_LOCAL_IP=!CACHED_LOCAL_IP:~1!"
    exit /b
)
exit /b

:get_gateway_ip
set "CACHED_GATEWAY_IP=Not available"
for /f "tokens=2 delims=:" %%a in ('ipconfig 2^>nul ^| findstr /c:"Default Gateway"') do (
    set "CACHED_GATEWAY_IP=%%a"
    set "CACHED_GATEWAY_IP=!CACHED_GATEWAY_IP:~1!"
    if "!CACHED_GATEWAY_IP!" NEQ "" exit /b
)
exit /b

:get_public_ip
set "public_ip=Not available"
for /f "delims=" %%a in ('curl -s --max-time 1 https://api.seeip.org 2^>nul') do set "public_ip=%%a"
if "!public_ip!"=="Not available" (
    for /f "delims=" %%a in ('curl -s --max-time 1 https://icanhazip.com 2^>nul') do set "public_ip=%%a"
)
exit /b

:get_dns_servers
set "is_dhcp=0"
set "primary_dns="
set "secondary_dns="
set "dns_index=0"
for /f "tokens=*" %%a in ('netsh interface ipv4 show dnsservers "%interface%" 2^>nul') do (
    echo %%a | findstr /i "dhcp" >nul && set "is_dhcp=1"
    echo %%a | findstr /r "[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*" >nul && (
        set /a dns_index+=1
        set "line=%%a"
        set "line=!line:Statically Configured DNS Servers: =!"
        set "line=!line:DNS servers configured through DHCP: =!"
        for /f %%b in ("!line!") do (
            if !dns_index! EQU 1 set "primary_dns=%%b"
            if !dns_index! EQU 2 set "secondary_dns=%%b"
        )
    )
)
set "CACHED_DNS_INFO=1"
exit /b

:identify_current_dns_provider
set "primary_name=Unknown"
set "secondary_name=Unknown"
set "both_same_provider=0"
for /l %%i in (1,1,%DNS_COUNT%) do (
    for /f "tokens=1-3 delims==" %%a in ("!dns_providers[%%i]!") do (
        if "!primary_dns!"=="%%b" if "!secondary_dns!"=="%%c" (
            set "primary_name=%%a"
            set "secondary_name=%%a"
            set "both_same_provider=1"
        )
        if "!primary_dns!"=="%%b" set "primary_name=%%a"
        if "!secondary_dns!"=="%%b" set "secondary_name=%%a"
    )
)
exit /b

:set_dhcp
echo %LINE_SEP%
echo.
echo %DOUBLE_EQ%!APPLYING_MSG!...
echo.
netsh interface ipv4 set dns name="%interface%" source=dhcp >nul 2>&1
set "CACHED_DNS_INFO="
call :detect_and_show_network_info
echo %LINE_SEP%
echo.
set "SKIP_LEADING_SEP=1"
call :perform_dns_flush
goto exit_menu

:network_reset
echo %LINE_SEP%
echo.
echo %DOUBLE_EQ%Network reset warning
echo.
echo %QUAD_EQ%This will perform a comprehensive network reset, including:
echo %QUAD_EQ%- Reset Winsock catalog
echo %QUAD_EQ%- Reset TCP/IP stack
echo %QUAD_EQ%- Reset Windows Firewall
echo %QUAD_EQ%- Flush DNS cache
echo %QUAD_EQ%- Release and renew IP configuration
echo.
echo %QUAD_EQ%Warning: Network connection will be temporarily interrupted!
echo %QUAD_EQ%Some changes may require a system reboot to take full effect.
echo.
set "CONFIRM="
set /p "CONFIRM=Continue with network reset? (Y/y or N/n): "
for /f "tokens=* delims= " %%x in ("!CONFIRM!") do set "CONFIRM=%%x"
echo.
if /i "!CONFIRM!"=="Y" goto confirm_reset
if /i "!CONFIRM!"=="YES" goto confirm_reset
call :show_error
goto exit_menu

:confirm_reset
echo %LINE_SEP%
echo.
echo %DOUBLE_EQ%Performing network reset...
echo.
echo %QUAD_EQ%Resetting Winsock catalog...
netsh winsock reset >nul 2>&1
if !ERRORLEVEL! EQU 0 (echo %QUAD_EQ%Success) else (echo %QUAD_EQ%Warning: Failed)
echo.
echo %QUAD_EQ%Resetting TCP/IP stack...
netsh int ip reset >nul 2>&1
echo %QUAD_EQ%Success
echo.
echo %QUAD_EQ%Resetting Windows Firewall...
netsh advfirewall reset >nul 2>&1
if !ERRORLEVEL! EQU 0 (echo %QUAD_EQ%Success) else (echo %QUAD_EQ%Warning: Failed)
echo.
echo %QUAD_EQ%Flushing DNS cache...
ipconfig /flushdns >nul 2>&1
if !ERRORLEVEL! EQU 0 (echo %QUAD_EQ%Success) else (echo %QUAD_EQ%Warning: Failed - Check DNS Client service)
echo.
echo %QUAD_EQ%Releasing IP configuration...
ipconfig /release >nul 2>&1
if !ERRORLEVEL! EQU 0 (echo %QUAD_EQ%Success) else (echo %QUAD_EQ%Warning: Failed or no DHCP lease)
echo.
echo %QUAD_EQ%Renewing IP configuration...
ipconfig /renew >nul 2>&1
if !ERRORLEVEL! EQU 0 (echo %QUAD_EQ%Success) else (echo %QUAD_EQ%Warning: Failed - Check network connection)
echo.
echo %DOUBLE_EQ%Network reset completed!
echo.
echo %QUAD_EQ%Recommendation: Restart your computer for all changes to take full effect.
echo %LINE_SEP%
set "CACHED_LOCAL_IP="
set "CACHED_GATEWAY_IP="
set "CACHED_DNS_INFO="
set "SKIP_LEADING_SEP=1"
goto exit_menu

:exit_menu
set "USERCHOICE="
if defined SKIP_LEADING_SEP (
    set "SKIP_LEADING_SEP="
    echo.
) else (
    echo %LINE_SEP%
    echo.
)
echo 0. Back to main menu
echo 00. Exit completely
echo.
set /p "USERCHOICE=Enter your choice: "
for /f "tokens=* delims= " %%x in ("!USERCHOICE!") do set "USERCHOICE=%%x"
echo.
if "%USERCHOICE%"=="0" (
    if not defined interface (goto no_interface_menu) else (goto main_menu)
)
if "%USERCHOICE%"=="00" goto exit_program
call :show_error
goto exit_menu

:show_error
echo %LINE_SEP%
echo.
echo %GENERAL_ERROR%
echo.
echo %LINE_SEP%
set "SKIP_LEADING_SEP=1"
exit /b

:exit_program
endlocal
exit 0