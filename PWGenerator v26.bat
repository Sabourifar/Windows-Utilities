@echo off
setlocal enabledelayedexpansion
chcp 65001 >nul 2>&1
title PWGenerator v26 By Sabourifar
set "UPPERCASE=ABCDEFGHIJKLMNOPQRSTUVWXYZ"
set "LOWERCASE=abcdefghijklmnopqrstuvwxyz"
set "NUMBERS=0123456789"
set "SYMBOLS=^!^"#$%%^&'()*+,-./:;^<^=^>^?@[\]^^^_^`{^|}^~"
set "LINE_SEP========================================================================================================================="
set "GENERAL_ERROR=Please enter a valid option."
set "SCRIPT_DIR=%~dp0"
set "SAVE_FILE=%SCRIPT_DIR%Passwords.txt"

echo ============================================ PWGenerator v26 By Sabourifar =============================================
echo.

:MAIN_MENU
set "CHOICE="
echo 1. Secure password (recommended)
echo 2. Custom password
echo.
echo 00. Exit
echo.
set /p "CHOICE=Enter your choice: "
if "%CHOICE%"=="1" goto SET_SECURE
if "%CHOICE%"=="2" goto GET_LENGTH
if "%CHOICE%"=="00" exit /b
echo.
echo %LINE_SEP%
echo.
echo %GENERAL_ERROR%
echo.
echo %LINE_SEP%
echo.
goto MAIN_MENU

:SET_SECURE
set "CHOICE=1"
goto GET_LENGTH

:GET_LENGTH
echo.
set "LENGTH="
set /p "LENGTH=Enter password length (4-80): "
if not defined LENGTH (
    echo.
    echo %LINE_SEP%
    echo.
    echo %GENERAL_ERROR%
    echo.
    echo %LINE_SEP%
    echo.
    goto GET_LENGTH
)
set /a "TEST_NUM=%LENGTH%" 2>nul
if !TEST_NUM! LSS 4 (
    echo.
    echo %LINE_SEP%
    echo.
    echo %GENERAL_ERROR%
    echo.
    echo %LINE_SEP%
    echo.
    goto GET_LENGTH
)
if !TEST_NUM! GTR 80 (
    echo.
    echo %LINE_SEP%
    echo.
    echo %GENERAL_ERROR%
    echo.
    echo %LINE_SEP%
    echo.
    goto GET_LENGTH
)
set "LENGTH=!TEST_NUM!"

:SETUP_CHARSET
set "USE_UPPER=0" & set "USE_LOWER=0" & set "USE_NUMBERS=0" & set "USE_SYMBOLS=0"
set "ACTIVE_SETS=0"
if "%CHOICE%"=="1" (
    set "USE_UPPER=1" & set "USE_LOWER=1" & set "USE_NUMBERS=1" & set "USE_SYMBOLS=1"
    set "ACTIVE_SETS=4"
    goto GENERATE_BALANCED
)
echo.

:check_upper
set /p "IN=Include uppercase? (Y/y or N/n): "
if /i "%IN%"=="Y" (
    set "USE_UPPER=1"
    set /a ACTIVE_SETS+=1
    goto check_lower
)
if /i "%IN%"=="N" goto check_lower
echo.
echo %LINE_SEP%
echo.
echo %GENERAL_ERROR%
echo.
echo %LINE_SEP%
echo.
goto check_upper

:check_lower
set /p "IN=Include lowercase? (Y/y or N/n): "
if /i "%IN%"=="Y" (
    set "USE_LOWER=1"
    set /a ACTIVE_SETS+=1
    goto check_numbers
)
if /i "%IN%"=="N" goto check_numbers
echo.
echo %LINE_SEP%
echo.
echo %GENERAL_ERROR%
echo.
echo %LINE_SEP%
echo.
goto check_lower

:check_numbers
set /p "IN=Include numbers? (Y/y or N/n): "
if /i "%IN%"=="Y" (
    set "USE_NUMBERS=1"
    set /a ACTIVE_SETS+=1
    goto check_symbols
)
if /i "%IN%"=="N" goto check_symbols
echo.
echo %LINE_SEP%
echo.
echo %GENERAL_ERROR%
echo.
echo %LINE_SEP%
echo.
goto check_numbers

:check_symbols
set /p "IN=Include symbols? (Y/y or N/n): "
if /i "%IN%"=="Y" (
    set "USE_SYMBOLS=1"
    set /a ACTIVE_SETS+=1
    goto validate_charset
)
if /i "%IN%"=="N" goto validate_charset
echo.
echo %LINE_SEP%
echo.
echo %GENERAL_ERROR%
echo.
echo %LINE_SEP%
echo.
goto check_symbols

:validate_charset
if !ACTIVE_SETS! EQU 0 (
    echo.
    echo %LINE_SEP%
    echo.
    echo %GENERAL_ERROR%
    echo.
    echo %LINE_SEP%
    echo.
    goto SETUP_CHARSET
)
goto GENERATE_BALANCED

:GENERATE_BALANCED
set "TEMP_PASS="
set /a "BASE_PER_SET=LENGTH / ACTIVE_SETS"
set /a "REMAINDER=LENGTH %% ACTIVE_SETS"

if "%USE_UPPER%"=="1" (
    set /a "COUNT=BASE_PER_SET"
    if !REMAINDER! GTR 0 (set /a "COUNT+=1" & set /a "REMAINDER-=1")
    for /L %%k in (1,1,!COUNT!) do (
        set /a "R=!RANDOM! %% 26"
        for %%r in (!R!) do set "TEMP_PASS=!TEMP_PASS!!UPPERCASE:~%%r,1!"
    )
)
if "%USE_LOWER%"=="1" (
    set /a "COUNT=BASE_PER_SET"
    if !REMAINDER! GTR 0 (set /a "COUNT+=1" & set /a "REMAINDER-=1")
    for /L %%k in (1,1,!COUNT!) do (
        set /a "R=!RANDOM! %% 26"
        for %%r in (!R!) do set "TEMP_PASS=!TEMP_PASS!!LOWERCASE:~%%r,1!"
    )
)
if "%USE_NUMBERS%"=="1" (
    set /a "COUNT=BASE_PER_SET"
    if !REMAINDER! GTR 0 (set /a "COUNT+=1" & set /a "REMAINDER-=1")
    for /L %%k in (1,1,!COUNT!) do (
        set /a "R=!RANDOM! %% 10"
        for %%r in (!R!) do set "TEMP_PASS=!TEMP_PASS!!NUMBERS:~%%r,1!"
    )
)
if "%USE_SYMBOLS%"=="1" (
    set /a "COUNT=BASE_PER_SET"
    if !REMAINDER! GTR 0 (set /a "COUNT+=1" & set /a "REMAINDER-=1")
    for /L %%k in (1,1,!COUNT!) do (
        set /a "R=!RANDOM! %% 32"
        for %%r in (!R!) do set "TEMP_PASS=!TEMP_PASS!!SYMBOLS:~%%r,1!"
    )
)

set "PASSWORD="
set /a "MAX_IDX=LENGTH - 1"
for /L %%i in (0,1,%MAX_IDX%) do set "CH_%%i=!TEMP_PASS:~%%i,1!"
for /L %%i in (%MAX_IDX%,-1,0) do (
    set /a "RJ=!RANDOM! %% (%%i + 1)"
    set "TMP=!CH_%%i!"
    for %%j in (!RJ!) do (
        set "CH_%%i=!CH_%%j!"
        set "CH_%%j=!TMP!"
    )
)
for /L %%i in (0,1,%MAX_IDX%) do set "PASSWORD=!PASSWORD!!CH_%%i!"

:DISPLAY_PASSWORD
echo.
echo %LINE_SEP%
echo.
echo  ==== Password: !PASSWORD!
echo.
echo %LINE_SEP%
echo.

:DISPLAY_PASSWORD_MENU
echo 1. Generate another
echo 2. Save password
echo 3. Save password with login info (title and username)
echo.
echo 0. Back to main menu
echo 00. Exit completely
echo.
set /p "A=Enter your choice: "
if "%A%"=="1" goto GENERATE_BALANCED
if "%A%"=="2" goto SAVE_PASSWORD
if "%A%"=="3" goto SAVE_WITH_INFO
if "%A%"=="0" goto RETURN_MAIN
if "%A%"=="00" (
    endlocal
    exit /b 0
)
echo.
echo %LINE_SEP%
echo.
echo %GENERAL_ERROR%
echo.
echo %LINE_SEP%
echo.
goto DISPLAY_PASSWORD_MENU

:RETURN_MAIN
echo.
echo %LINE_SEP%
echo.
goto MAIN_MENU

:SAVE_PASSWORD
echo Password: !PASSWORD!>>"%SAVE_FILE%"
echo =>>"%SAVE_FILE%"
echo.
echo %LINE_SEP%
echo.
echo  ==== Saved to %SAVE_FILE%
echo.
echo %LINE_SEP%
echo.
goto MAIN_MENU

:SAVE_WITH_INFO
echo.
set /p "TITLE=Title: "
if not defined TITLE (
    echo.
    echo %LINE_SEP%
    echo.
    echo %GENERAL_ERROR%
    echo.
    echo %LINE_SEP%
    echo.
    goto SAVE_WITH_INFO
)
set /p "USERNAME=Username: "
if not defined USERNAME (
    echo.
    echo %LINE_SEP%
    echo.
    echo %GENERAL_ERROR%
    echo.
    echo %LINE_SEP%
    echo.
    goto SAVE_WITH_INFO
)
echo Title: !TITLE!>>"%SAVE_FILE%"
echo Username: !USERNAME!>>"%SAVE_FILE%"
echo Password: !PASSWORD!>>"%SAVE_FILE%"
echo =>>"%SAVE_FILE%"
echo.
echo %LINE_SEP%
echo.
echo  ==== Saved to %SAVE_FILE%
echo.
echo %LINE_SEP%
echo.
goto MAIN_MENU
