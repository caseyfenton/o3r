@echo off
REM o3r_background.bat - Windows version
REM Run the complete O3 workflow in background

setlocal EnableDelayedExpansion

REM Functions
goto :main

:print_help
echo o3r-run: Run complete O3 workflow in background
echo.
echo DESCRIPTION
echo     Runs the full O3 workflow in background - processing files,
echo     submitting to O3, monitoring for response, and saving output.
echo.
echo USAGE
echo     o3r-run [OPTIONS] (-f FILE_LIST ^| -d DIRECTORY)
echo.
echo OPTIONS
echo     -d DIR        Directory to process (default: current directory)
echo     -e EXTS       Extensions to process (default: py,js,ts,go)
echo     -f FILE       File containing list of files to process
echo     -o FILE       Output file for response (default: o3r_response.txt)
echo     -w SECONDS    Wait before pasting (default: 3)
echo     -i SECONDS    Check interval (default: 30)
echo     -m SECONDS    Maximum wait time (default: 300)
echo     -s SIZE       Minimum response size (default: 100)
echo     -b BROWSER    Browser to use (chrome, edge, default: chrome)
echo     -h, --help    Show help message
echo.
echo EXAMPLES
echo     o3r-run -d ./src -e py
echo     o3r-run -f files.txt -o result.txt
echo     o3r-run -d . -e js -m 600 -i 60
exit /b 0

:main
set "directory="
set "extensions=py,js,ts,go"
set "file_list="
set "output_file=o3r_response.txt"
set "wait_before_paste=3"
set "check_interval=30"
set "max_wait_time=300"
set "min_response_size=100"
set "browser=chrome"

REM Process options
:parse_args
if "%~1"=="" goto args_done
if "%~1"=="-h" goto help_and_exit
if "%~1"=="--help" goto help_and_exit
if "%~1"=="-d" (
    set "directory=%~2"
    shift
    shift
    goto parse_args
)
if "%~1"=="-e" (
    set "extensions=%~2"
    shift
    shift
    goto parse_args
)
if "%~1"=="-f" (
    set "file_list=%~2"
    shift
    shift
    goto parse_args
)
if "%~1"=="-o" (
    set "output_file=%~2"
    shift
    shift
    goto parse_args
)
if "%~1"=="-w" (
    set "wait_before_paste=%~2"
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
if "%~1"=="-b" (
    set "browser=%~2"
    shift
    shift
    goto parse_args
)
echo Unknown option: %1
call :print_help
exit /b 1

:args_done
REM Validate inputs
if "%directory%"=="" if "%file_list%"=="" (
    echo Error: Must provide either -d or -f option
    call :print_help
    exit /b 1
)

echo O3R Workflow Starting
echo =====================
echo.

REM Step 1: Generate and copy content
echo STEP 1: Processing input files...
set "script_dir=%~dp0"
set "script_dir=%script_dir:~0,-1%"

if not "%directory%"=="" (
    echo Running: %script_dir%\o3r_main.bat -d "%directory%" -e "%extensions%" 
    call "%script_dir%\o3r_main.bat" -d "%directory%" -e "%extensions%"
) else (
    echo Running: %script_dir%\o3r_main.bat -f "%file_list%"
    call "%script_dir%\o3r_main.bat" -f "%file_list%"
)

if %ERRORLEVEL% neq 0 (
    echo Error: Failed to process input files
    exit /b 1
)

echo Content successfully copied to clipboard.
echo.

REM Step 2: Submit to O3
echo STEP 2: Submitting to O3...
echo Running: %script_dir%\o3r_collect_response.bat -w "%wait_before_paste%" -b "%browser%"
call "%script_dir%\o3r_collect_response.bat" -w "%wait_before_paste%" -b "%browser%"

echo.
echo Content submitted to O3.
echo IMPORTANT: You'll need to manually click in the browser and:
echo 1. Press Ctrl+V to paste your code
echo 2. Press Enter to submit to O3
echo.

REM Step 3: Monitor for response
echo STEP 3: Monitoring for response...
echo When O3 finishes generating a response, select all the text
echo and press Ctrl+C to copy it to clipboard.
echo.
echo Waiting for response...
echo Running: %script_dir%\o3r_monitor_response.bat -o "%output_file%" -i "%check_interval%" -m "%max_wait_time%" -s "%min_response_size%"
call "%script_dir%\o3r_monitor_response.bat" -o "%output_file%" -i "%check_interval%" -m "%max_wait_time%" -s "%min_response_size%"

if %ERRORLEVEL% equ 0 (
    echo.
    echo ✓ O3R workflow completed successfully!
    echo ✓ Response saved to: "%output_file%"
) else (
    echo.
    echo ❌ O3R workflow did not complete successfully
    echo Try running o3r-collect and o3r-monitor manually
)

exit /b %ERRORLEVEL%

:help_and_exit
call :print_help
exit /b 0
