@echo off
REM o3r_monitor_response.bat - Windows version
REM Monitor for O3 responses in clipboard

setlocal EnableDelayedExpansion

REM Functions
goto :main

:print_help
echo o3r_monitor_response.bat: Monitor for O3 responses
echo.
echo DESCRIPTION
echo     Periodically checks clipboard for O3 responses.
echo.
echo USAGE
echo     o3r_monitor_response.bat [OPTIONS]
echo.
echo OPTIONS
echo     -o FILE     Output file for response (default: o3r_response.txt)
echo     -i SECONDS  Check interval in seconds (default: 30)
echo     -m SECONDS  Maximum wait time in seconds (default: 300)
echo     -s SIZE     Minimum response size in bytes (default: 100)
echo     -h, --help  Show help message
echo.
echo EXAMPLES
echo     o3r_monitor_response.bat
echo     o3r_monitor_response.bat -i 10 -m 600
echo     o3r_monitor_response.bat -o result.txt -s 500
exit /b 0

:monitor_response
echo.
echo MANUAL MONITORING INSTRUCTIONS FOR WINDOWS
echo.
echo 1. This script will periodically check your clipboard
echo    for content that appears to be from O3.
echo.
echo 2. When O3 is finished, manually select the entire
echo    response and press Ctrl+C to copy it.
echo.
echo 3. This script will detect when clipboard content changes
echo    and save it to the output file.
echo.
echo Starting monitoring at %time%
echo Will check every %check_interval% seconds for up to %max_wait_time% seconds.
echo Response will be saved to: %output_file%
echo.

REM Create temporary files
set "temp_prev=%TEMP%\o3r_monitor_prev_%RANDOM%.txt"
set "temp_curr=%TEMP%\o3r_monitor_curr_%RANDOM%.txt"

REM Initialize previous clipboard content
powershell -command "Get-Clipboard | Out-File -Encoding utf8 '%temp_prev%'"
set /a "prev_size=0"
for %%A in ("%temp_prev%") do set "prev_size=%%~zA"

REM Start the monitoring loop
set "start_time=%time%"
set /a "end_seconds=%SECONDS% + %max_wait_time%"
set "check_count=0"

:monitor_loop
set /a "check_count+=1"
set /a "elapsed=%SECONDS% - %start_seconds%"

REM Get current clipboard content
powershell -command "Get-Clipboard | Out-File -Encoding utf8 '%temp_curr%'"
set /a "curr_size=0"
for %%A in ("%temp_curr%") do set "curr_size=%%~zA"

echo [Check %check_count%] After %elapsed%s: Response size %curr_size% bytes

REM Check if response is valid
if %curr_size% geq %min_response_size% (
    if %curr_size% neq %prev_size% (
        echo ✓ Valid response detected after %elapsed% seconds!
        echo ✓ Response size: %curr_size% bytes
        echo ----- RESPONSE PREVIEW (first 200 chars) -----
        powershell -command "Get-Content '%temp_curr%' -Raw | ForEach-Object { if ($_.Length -gt 200) {$_.Substring(0, 200) + '...'} else {$_} }"
        echo ----------------------------------------------
        
        REM Save response to file
        copy "%temp_curr%" "%output_file%" > nul
        echo ✓ Full response saved to: %output_file%
        
        REM Clean up temp files
        del "%temp_prev%" > nul 2>&1
        del "%temp_curr%" > nul 2>&1
        
        exit /b 0
    )
)

REM Update previous size
set "prev_size=%curr_size%"
copy "%temp_curr%" "%temp_prev%" > nul

REM Check if we've reached the timeout
if %SECONDS% geq %end_seconds% (
    echo ❌ No valid response detected within %max_wait_time% seconds
    
    REM Clean up temp files
    del "%temp_prev%" > nul 2>&1
    del "%temp_curr%" > nul 2>&1
    
    exit /b 1
)

REM Wait for next check
timeout /t %check_interval% > nul
goto monitor_loop

:main
set "output_file=o3r_response.txt"
set "check_interval=30"
set "max_wait_time=300"
set "min_response_size=100"

REM Initialize SECONDS variable (not built into batch)
for /f "tokens=1-3 delims=:.," %%a in ("%time%") do (
   set /a "start_seconds=(((%%a*60)+1%%b %% 100)*60+1%%c %% 100)"
)
set "SECONDS=%start_seconds%"

REM Process options
:parse_args
if "%~1"=="" goto args_done
if "%~1"=="-h" goto help_and_exit
if "%~1"=="--help" goto help_and_exit
if "%~1"=="-o" (
    set "output_file=%~2"
    shift
    shift
    goto parse_args
)
if "%~1"=="-i" (
    set "check_interval=%~2"
    shift
    shift
    goto parse_args
)
if "%~1"=="-m" (
    set "max_wait_time=%~2"
    shift
    shift
    goto parse_args
)
if "%~1"=="-s" (
    set "min_response_size=%~2"
    shift
    shift
    goto parse_args
)
echo Unknown option: %1
call :print_help
exit /b 1

:args_done
call :monitor_response
exit /b 0

:help_and_exit
call :print_help
exit /b 0
