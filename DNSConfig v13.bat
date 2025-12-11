@echo off
setlocal enabledelayedexpansion

:: Administrator Privilege Check
NET FILE >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo  == Requesting administrative privileges...
    powershell -noprofile -command "Start-Process '%~f0' -Verb RunAs" >nul
    exit /b
)

:: Initialization
title DNSConfig v13 by Sabourifar

:: Define constants for consistent UI formatting
set "line_sep========================================================================================================================="
set "double_eq=  == "
set "quad_eq=  ==== "
set "pscmd=powershell -noprofile -command"
set "invalid_msg=Invalid input. Please check your selection and try again."

:: Define message variables for consistent messaging
set "applying_msg=Updating DNS configuration"
set "clearing_msg=Flushing DNS resolver cache"
set "cleared_msg=Successfully flushed the DNS resolver cache"

:: DNS Provider Database - Name=PrimaryDNS=SecondaryDNS
set "dns_providers[1]=Cloudflare=1.1.1.1=1.0.0.1"
set "dns_providers[2]=Google=8.8.8.8=8.8.4.4"
set "dns_providers[3]=Quad9=9.9.9.9=149.112.112.112"
set "dns_providers[4]=OpenDNS=208.67.222.222=208.67.220.220"
set "dns_providers[5]=UltraDNS=64.6.64.6=64.6.65.6"
set "dns_providers[6]=NTT=129.250.35.250=129.250.35.251"
set "dns_providers[7]=Shecan=178.22.122.100=185.51.200.2"
set "dns_providers[8]=Electro=78.157.42.100=78.157.42.101"
set "dns_providers[9]=DNSCrypt=127.0.0.1="
set "dns_count=9"

:: Display application header
echo ============================================= DNSConfig v13 by Sabourifar ==============================================
echo.

:: Detect current DNS configuration and display it
call :detect_and_show_network_info

:: If no active network interface detected, show limited menu options
if not defined interface goto no_interface_menu

:main_menu
:: Display main menu options
set "choice="
echo %line_sep%
echo.
echo  1. Preconfigured DNS
echo  2. Configure DNS manually
echo  3. Automatic DNS (DHCP)
echo  4. Clear DNS cache
echo  5. View network information
echo  6. Reset network settings
echo.
echo  00. Exit completely
echo.

:: Ping all DNS servers in background ONLY on first time (before first prompt)
if not defined pings_completed (
    call :ping_all_dns_background
    set "pings_completed=1"
)

call :clear_input_buffer
set /p "choice=Enter your choice: "
echo.

:: Process user selection
if "%choice%"=="" goto invalid_main
if "%choice%"=="1" goto :choice_1
if "%choice%"=="2" goto :choice_2
if "%choice%"=="3" goto :choice_3
if "%choice%"=="4" goto :choice_4
if "%choice%"=="5" goto :choice_5
if "%choice%"=="6" goto :choice_6
if "%choice%"=="00" exit

:invalid_main
call :show_invalid_message
goto main_menu

:no_interface_menu
:: Show limited menu when no network interface is available
set "choice="
echo %line_sep%
echo.
echo  1. Clear DNS cache
echo  2. Reset network settings
echo.
echo  00. Exit completely
echo.
call :clear_input_buffer
set /p "choice=Enter your choice: "
echo.

:: Process limited menu selections
if "%choice%"=="" goto invalid_no_interface
if "%choice%"=="1" goto :flush_dns
if "%choice%"=="2" call :network_reset & goto :exit_menu
if "%choice%"=="00" exit

:invalid_no_interface
call :show_invalid_message
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
call :flush_dns
goto :exit_menu

:choice_5
echo %line_sep%
echo.
call :detect_and_show_network_info
echo %line_sep%
echo.
goto :exit_menu

:choice_6
call :network_reset
goto :exit_menu

:show_invalid_message
echo %line_sep%
echo.
echo  %invalid_msg%
echo.
exit /b

:ping_all_dns_background
:: Background ping function - runs all pings and saves results
for /l %%i in (1,1,%dns_count%) do (
    call :ping_dns_provider %%i
)
set "ping_time=%time:~0,8%"
exit /b

:ping_all_dns_visible
:: Visible ping function - shows results one by one as they complete
for /l %%i in (1,1,%dns_count%) do (
    for /f "tokens=1-3 delims==" %%a in ("!dns_providers[%%i]!") do (
        call :ping_dns_provider %%i
        if "!dns_latency[%%i]!" NEQ "N/A" (
            echo  %%i. %%a ^(!dns_latency[%%i]!^)
        ) else (
            echo  %%i. %%a ^(N/A^)
        )
    )
)
echo.
set "ping_time=%time:~0,8%"
exit /b

:ping_dns_provider
:: Ping a single DNS provider by index
set "index=%~1"
for /f "tokens=1-3 delims==" %%a in ("!dns_providers[%index%]!") do (
    :: DNSCrypt is always 0ms (local address)
    if %index% EQU 9 (
        set "dns_latency[%index%]=0ms"
    ) else (
        :: Try primary DNS first
        call :ping_server "%%b" latency_primary
        if "!latency_primary!" NEQ "N/A" (
            set "dns_latency[%index%]=!latency_primary!"
        ) else (
            :: Primary failed, try secondary if it exists
            if "%%c" NEQ "" (
                call :ping_server "%%c" latency_secondary
                set "dns_latency[%index%]=!latency_secondary!"
            ) else (
                set "dns_latency[%index%]=N/A"
            )
        )
    )
)
exit /b

:ping_server
:: Fast ping with retry - single ping with up to 4 attempts total
set "ip=%~1"
set "result=N/A"
set "attempts=0"

:retry_ping
set /a attempts+=1
if !attempts! GTR 4 (
    set "%~2=N/A"
    exit /b
)

:: Single fast ping attempt (500ms timeout)
set "line="
for /f "delims=" %%a in ('ping -n 1 -w 500 %ip% 2^>nul ^| findstr /i "TTL"') do set "line=%%a"

if not defined line goto retry_ping

:: Extract time value from the response line
:: Example: "Reply from 1.1.1.1: bytes=32 time=15ms TTL=56"
set "temp=!line:*time=!"
if "!temp!"=="!line!" goto retry_ping

:: Remove the equals sign
set "temp=!temp:~1!"

:: Extract just the time value (15ms)
for /f "tokens=1 delims= " %%t in ("!temp!") do set "result=%%t"

if "!result!"=="" goto retry_ping
if "!result!"=="N/A" goto retry_ping

set "%~2=!result!"
exit /b

:choose_dns
:retry_dns
set "dnschoice="
echo %line_sep%
echo.

:: Display cached ping results
call :display_dns_list

echo.
echo  Ping time: !ping_time!
echo.
echo  10. Ping again
echo.
echo  0. Back to main menu
echo  00. Exit completely
echo.
call :clear_input_buffer
set /p "dnschoice=Enter your choice: "
echo.

if "%dnschoice%"=="0" goto main_menu
if "%dnschoice%"=="00" exit
if "%dnschoice%"=="10" goto :reping_dns

:: Validate user selection
call :validate_dns_choice "%dnschoice%"
if !ERRORLEVEL! NEQ 0 goto invalid_dns

:: Extract DNS information for selected provider
call :get_dns_info "%dnschoice%"
goto apply_dns

:reping_dns
echo %line_sep%
echo.
call :ping_all_dns_visible
echo  Ping time: !ping_time!
echo.
echo  10. Ping again
echo.
echo  0. Back to main menu
echo  00. Exit completely
echo.
call :clear_input_buffer
set /p "dnschoice=Enter your choice: "
echo.

if "%dnschoice%"=="0" goto main_menu
if "%dnschoice%"=="00" exit
if "%dnschoice%"=="10" goto :reping_dns

:: Validate user selection
call :validate_dns_choice "%dnschoice%"
if !ERRORLEVEL! NEQ 0 goto invalid_dns

:: Extract DNS information for selected provider
call :get_dns_info "%dnschoice%"
goto apply_dns

:invalid_dns
call :show_invalid_message
goto retry_dns

:display_dns_list
:: Display all DNS providers with their latencies
for /l %%i in (1,1,%dns_count%) do (
    for /f "tokens=1 delims==" %%a in ("!dns_providers[%%i]!") do (
        if "!dns_latency[%%i]!" NEQ "N/A" (
            echo  %%i. %%a ^(!dns_latency[%%i]!^)
        ) else (
            echo  %%i. %%a ^(N/A^)
        )
    )
)
exit /b

:validate_dns_choice
:: Validate if the choice is a valid DNS provider number
set "choice=%~1"
for /l %%i in (1,1,%dns_count%) do (
    if "%choice%"=="%%i" exit /b 0
)
exit /b 1

:get_dns_info
:: Extract DNS information for the selected provider
set "choice=%~1"
for /f "tokens=1-3 delims==" %%a in ("!dns_providers[%choice%]!") do (
    set "NAME=%%a"
    set "DNS1=%%b"
    set "DNS2=%%c"
)
exit /b

:advanced_dns
echo %line_sep%
echo.
:get_primary
set "DNS1="
call :clear_input_buffer
set /p "DNS1=Enter primary DNS server: "
echo.

:: Validate primary DNS input
if not defined DNS1 goto invalid_format_primary
call :validate_ip "!DNS1!"
if !ERRORLEVEL! NEQ 0 goto invalid_format_primary

:get_secondary
set "DNS2="
call :clear_input_buffer
set /p "DNS2=Enter secondary DNS server (optional): "
echo.

:: Validate secondary DNS input if provided
if defined DNS2 if "!DNS2!" NEQ "" (
    call :validate_ip "!DNS2!"
    if !ERRORLEVEL! NEQ 0 goto invalid_format_secondary
)

:: Try to identify if manual entry matches known providers
call :identify_dns_provider "!DNS1!" "!DNS2!"
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

:identify_dns_provider
:: Try to identify if manual entry matches known providers
set "input_primary=%~1"
set "input_secondary=%~2"
set "custom_name="
set "found_provider=0"

for /l %%i in (1,1,%dns_count%) do (
    for /f "tokens=1-3 delims==" %%a in ("!dns_providers[%%i]!") do (
        if "!input_primary!"=="%%b" if "!input_secondary!"=="%%c" (
            set "custom_name=%%a"
            set "found_provider=1"
        )
    )
)

:: Set appropriate display name
if !found_provider! EQU 1 (
    set "NAME=!custom_name! (manual)"
) else (
    set "NAME=Custom"
)
exit /b

:validate_ip
:: IP Address Validation Function
set "ip=%~1"
set "valid=1"

:: Parse IP address into octets
for /f "tokens=1-4 delims=." %%a in ("!ip!") do (
    set "oct1=%%a" & set "oct2=%%b" & set "oct3=%%c" & set "oct4=%%d"
)

:: Check if all 4 octets are present
if not defined oct4 set "valid=0"
if not defined oct3 set "valid=0"
if not defined oct2 set "valid=0"
if not defined oct1 set "valid=0"

:: Validate each octet
if !valid! EQU 1 (
    for %%o in (!oct1! !oct2! !oct3! !oct4!) do (
        echo %%o| findstr /r "^[0-9]*$" >nul || set "valid=0"
        if %%o LSS 0 set "valid=0"
        if %%o GTR 255 set "valid=0"
        if "%%o" NEQ "0" if "%%o" GEQ "00" if "%%o" LEQ "09" set "valid=0"
    )
)

:: Return validation result via ERRORLEVEL
if !valid! EQU 0 (exit /b 1) else (exit /b 0)

:apply_dns
echo %line_sep%
echo.
echo %double_eq%!applying_msg!...
echo.

:: Configure primary DNS server
netsh interface ipv4 set dns name="%interface%" static %DNS1% primary >nul
:: Configure secondary DNS server if provided
if defined DNS2 if "%DNS2%" NEQ "" netsh interface ipv4 add dns name="%interface%" %DNS2% index=2 >nul

:: Display updated configuration
call :detect_and_show_network_info
echo %line_sep%
echo.

:: Clear DNS cache after configuration change
call :perform_dns_flush
goto :exit_menu

:perform_dns_flush
echo %double_eq%!clearing_msg!...
echo.
:: Execute DNS cache flush command
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

:clear_input_buffer
:: Use PowerShell to clear any pending keyboard input
>nul powershell -noprofile -command "if($Host.UI.RawUI.KeyAvailable){$Host.UI.RawUI.FlushInputBuffer()}"
exit /b

:detect_and_show_network_info
echo %double_eq%Detecting active network interface...
echo.

:: Find the first connected network interface using netsh
call :get_active_interface
if not defined interface (
    echo %quad_eq%No active network interface found
    echo.
    exit /b
)

echo %quad_eq%Active network interface: %interface%
echo.

:: Get network information
call :get_public_ip
call :get_local_ip
call :get_gateway_ip

:: Display network information
echo %quad_eq%Public IP: %public_ip%
echo %quad_eq%Local IP: %local_ip%
echo %quad_eq%Gateway IP: %gateway_ip%
echo.

:: Get and display DNS information
call :get_dns_servers
call :display_dns_info
exit /b

:get_active_interface
:: Find the first connected network interface
set "interface="
for /f "tokens=3,*" %%a in ('netsh interface show interface ^| findstr /C:"Connected"') do (
    set "interface=%%b"
    goto :break_interface
)
:break_interface
exit /b

:get_public_ip
:: Get Public IP Address using fastest method
set "public_ip=Not available"
for /f "delims=" %%a in ('curl -s --max-time 0.4 https://icanhazip.com 2^>nul') do set "public_ip=%%a"
if "!public_ip!"=="Not available" (
    for /f "delims=" %%a in ('curl -s --max-time 0.4 https://api.ipify.org 2^>nul') do set "public_ip=%%a"
)
exit /b

:get_local_ip
:: Get Local IP Address
set "local_ip=Not available"
for /f "tokens=2 delims=:" %%a in ('ipconfig ^| findstr /c:"IPv4 Address"') do (
    set "local_ip=%%a"
    set "local_ip=!local_ip:~1!"
    goto :break_local
)
:break_local
exit /b

:get_gateway_ip
:: Get Gateway IP (Default Gateway)
set "gateway_ip=Not available"
for /f "tokens=2 delims=:" %%a in ('ipconfig ^| findstr /c:"Default Gateway"') do (
    set "gateway_ip=%%a"
    set "gateway_ip=!gateway_ip:~1!"
    if "!gateway_ip!" NEQ "" goto :break_gateway
)
:break_gateway
exit /b

:get_dns_servers
:: Check if DNS is configured via DHCP and get DNS server addresses
set "is_dhcp=0"
for /f "tokens=*" %%a in ('netsh interface ipv4 show dnsservers "%interface%" ^| findstr /i "dhcp"') do set "is_dhcp=1"

:: Get current DNS server addresses using netsh
set "primary_dns=" & set "secondary_dns="
set "dns_index=0"
for /f "tokens=*" %%a in ('netsh interface ipv4 show dnsservers "%interface%" ^| findstr /r "[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*"') do (
    set /a dns_index+=1
    set "dns_line=%%a"
    set "dns_line=!dns_line:Statically Configured DNS Servers: =!"
    set "dns_line=!dns_line:DNS servers configured through DHCP: =!"
    for /f %%b in ("!dns_line!") do (
        if !dns_index! EQU 1 set "primary_dns=%%b"
        if !dns_index! EQU 2 set "secondary_dns=%%b"
    )
)
exit /b

:display_dns_info
:: Display DNS information based on configuration type
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

:: Identify DNS provider names by matching IP addresses
call :identify_current_dns_provider

:: Display DNS configuration with provider identification
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

:identify_current_dns_provider
:: Identify DNS provider names by matching current DNS IPs with known providers
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
exit /b

:set_dhcp
echo %line_sep%
echo.
echo %double_eq%!applying_msg!...
echo.

:: Configure interface to use DHCP for DNS
netsh interface ipv4 set dns name="%interface%" source=dhcp >nul

:: Show updated DNS configuration
call :detect_and_show_network_info
echo %line_sep%
echo.

:: Clear DNS cache after configuration change
call :perform_dns_flush
goto :exit_menu

:network_reset
echo %line_sep%
echo.
echo %double_eq%Network reset warning
echo.

:: Explain what network reset will do
call :display_network_reset_info

:: Get user confirmation for destructive operation
call :confirm_network_reset
if !ERRORLEVEL! NEQ 0 (
    echo %line_sep%
    echo.
    echo %quad_eq%Network reset cancelled.
    echo.
    echo %line_sep%
    echo.
    goto :exit_menu
)

:: Execute network reset
call :execute_network_reset
goto :exit_menu

:display_network_reset_info
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
exit /b

:confirm_network_reset
set "confirm="
call :clear_input_buffer
set /p "confirm=Continue with network reset? (Y/N): "
echo.
if /i "!confirm!" NEQ "Y" if /i "!confirm!" NEQ "YES" exit /b 1
exit /b 0

:execute_network_reset
echo %line_sep%
echo.
echo %double_eq%Performing network reset...
echo.

:: Reset Winsock catalog
echo %quad_eq%Resetting Winsock catalog...
netsh winsock reset >nul 2>&1
if !ERRORLEVEL! EQU 0 (echo %quad_eq%Success) else (echo %quad_eq%Warning: Failed)
echo.

:: Reset TCP/IP stack
echo %quad_eq%Resetting TCP/IP stack...
netsh int ip reset >nul 2>&1
echo %quad_eq%Success
echo.

:: Reset Windows Firewall
echo %quad_eq%Resetting Windows Firewall...
netsh advfirewall reset >nul 2>&1
if !ERRORLEVEL! EQU 0 (echo %quad_eq%Success) else (echo %quad_eq%Warning: Failed)
echo.

:: Flush DNS cache
echo %quad_eq%Flushing DNS cache...
ipconfig /flushdns >nul 2>&1
if !ERRORLEVEL! EQU 0 (echo %quad_eq%Success) else (echo %quad_eq%Warning: Failed - Check DNS Client service)
echo.

:: Release IP configuration
echo %quad_eq%Releasing IP configuration...
ipconfig /release >nul 2>&1
if !ERRORLEVEL! EQU 0 (echo %quad_eq%Success) else (echo %quad_eq%Warning: Failed or no DHCP lease)
echo.

:: Renew IP configuration
echo %quad_eq%Renewing IP configuration...
ipconfig /renew >nul 2>&1
if !ERRORLEVEL! EQU 0 (echo %quad_eq%Success) else (echo %quad_eq%Warning: Failed - Check network connection)
echo.

:: Completion message
echo %double_eq%Network reset completed!
echo.
echo %quad_eq%Recommendation: Restart your computer for all changes to take effect.
echo.
echo %line_sep%
echo.
exit /b

:exit_menu
set "userchoice="
echo  0. Back to main menu
echo  00. Exit completely
echo.

:: Clear input buffer to prevent accidental selections
call :clear_input_buffer

set /p "userchoice=Enter your choice: "
echo.

:: Process exit menu selection
if "%userchoice%"=="0" (
    if not defined interface (goto no_interface_menu) else (goto main_menu)
)
if "%userchoice%"=="00" exit

:: Handle invalid exit menu input
call :show_invalid_message
echo %line_sep%
echo.
goto exit_menu


