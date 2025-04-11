@echo off
REM o3r_main.bat - Windows version of o3r main script
REM Prepares code for O3 refactoring

setlocal EnableDelayedExpansion

REM Functions
goto :main

:print_help
echo o3r: Prepare code for O3 refactoring
echo.
echo DESCRIPTION
echo     Combines source files into a single document with formatting and
echo     instructions for O3-based refactoring. Copies to clipboard by default.
echo.
echo USAGE
echo     o3r [OPTIONS] (-f FILE_LIST ^| -d DIRECTORY)
echo.
echo OPTIONS
echo     -o FILE     Write output to FILE instead of clipboard
echo     -f FILE     Read list of files from FILE
echo     -d DIR      Process all matching files in DIR recursively
echo     -e EXTS     Comma-separated list of extensions (default: py,js,ts,go)
echo     -p          Auto-paste to O3 (Windows only)
echo     -m          Auto-monitor for responses (Windows only)
echo     -i SECONDS  Check interval for monitoring (default: 30)
echo     -t SECONDS  Maximum wait time for monitoring (default: 300)
echo     -h, --help  Show help message
echo.
echo EXAMPLES
echo     o3r -d ./src -e py
echo     o3r -d ./src -e py -p
echo     o3r -f files.txt -o output.txt
echo     o3r -d "src/core,tests" -e py
echo.
echo NOTE
echo     Uses Windows clipboard for copy/paste operations
echo     Auto-paste (-p) and auto-monitor (-m) functionality requires O3 web app
exit /b 0

:generate_content
REM Create a temp file
set "temp_file=%TEMP%\o3r_%RANDOM%.txt"

echo ### REFACTORING INSTRUCTIONS ### > "%temp_file%"
echo Refactor this codebase to be more vertically compressed and efficient while maintaining functionality. Requirements: >> "%temp_file%"
echo 1. Combine related functions, variables, and imports on single lines where logical >> "%temp_file%"
echo 2. Use Python shorthand syntax (list/dict comprehensions, ternaries, etc.) >> "%temp_file%"
echo 3. Merge similar logic and remove redundant code >> "%temp_file%"
echo 4. CRITICAL: Preserve ALL literal strings exactly as-is, including: >> "%temp_file%"
echo    - Success messages >> "%temp_file%"
echo    - Error messages >> "%temp_file%"
echo    - API responses >> "%temp_file%"
echo    - Log messages >> "%temp_file%"
echo    - Test assertions >> "%temp_file%"
echo 5. Preserve docstrings and comments that explain complex logic >> "%temp_file%"
echo 6. Maintain the same imports, just organize them better >> "%temp_file%"
echo. >> "%temp_file%"
echo ### CODEBASE ### >> "%temp_file%"

REM Process directory input
if not "%directory%"=="" (
    for %%d in (%directory%) do (
        for %%e in (%extensions%) do (
            echo Scanning directory %%d for .%%e files...
            for /r "%%d" %%f in (*.%%e) do (
                echo Adding %%f...
                echo. >> "%temp_file%"
                echo ```%%e >> "%temp_file%"
                echo # FILE: %%f >> "%temp_file%"
                type "%%f" >> "%temp_file%"
                echo ``` >> "%temp_file%"
            )
        )
    )
)

REM Process file list input
if not "%file_list%"=="" (
    if "%file_list%"=="-" (
        REM Read from stdin - not directly supported in batch
        echo Error: Reading from stdin not supported in Windows version
        exit /b 1
    ) else (
        REM Read from file
        for /f "usebackq tokens=*" %%f in ("%file_list%") do (
            if exist "%%f" (
                echo Adding %%f...
                for %%e in ("%%f") do set "ext=%%~xe"
                set "ext=!ext:~1!"
                echo. >> "%temp_file%"
                echo ```!ext! >> "%temp_file%"
                echo # FILE: %%f >> "%temp_file%"
                type "%%f" >> "%temp_file%"
                echo ``` >> "%temp_file%"
            ) else (
                echo Warning: File not found - %%f
            )
        )
    )
)

REM Handle output destination
if not "%output_file%"=="" (
    copy "%temp_file%" "%output_file%" > nul
    echo Content written to %output_file%
) else (
    REM Copy to clipboard using PowerShell
    powershell -command "Get-Content '%temp_file%' | Set-Clipboard"
    echo Content copied to clipboard (Windows)
    
    REM Auto paste if enabled
    if "%auto_paste%"=="true" (
        echo Auto-pasting content to O3...
        call "%~dp0o3r_collect_response.bat"
        
        REM If monitoring is enabled, start monitoring
        if "%auto_monitor%"=="true" (
            set "monitor_script=%~dp0o3r_monitor_response.bat"
            echo Starting response monitoring...
            call "!monitor_script!" -i %monitor_interval% -m %monitor_maxtime%
        ) else (
            echo Monitoring not enabled. Run the following when ready:
            echo %~dp0o3r_monitor_response.bat
        )
    )
)

REM Clean up temp file
del "%temp_file%" > nul 2>&1
exit /b 0

:main
set "output_file="
set "file_list="
set "directory="
set "extensions=py,js,ts,go"
set "auto_paste=false"
set "auto_monitor=false"
set "monitor_interval=30"
set "monitor_maxtime=300"

if "%~1"=="" goto help_and_exit
if "%~1"=="-h" goto help_and_exit
if "%~1"=="--help" goto help_and_exit

:parse_args
if "%~1"=="" goto args_done
if "%~1"=="-o" (
    set "output_file=%~2"
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
if "%~1"=="-p" (
    set "auto_paste=true"
    shift
    goto parse_args
)
if "%~1"=="-m" (
    set "auto_monitor=true"
    shift
    goto parse_args
)
if "%~1"=="-i" (
    set "monitor_interval=%~2"
    shift
    shift
    goto parse_args
)
if "%~1"=="-t" (
    set "monitor_maxtime=%~2"
    shift
    shift
    goto parse_args
)
echo Unknown option: %1
call :print_help
exit /b 1

:args_done
if "%file_list%"=="" if "%directory%"=="" (
    echo Error: Provide -f or -d
    exit /b 1
)

call :generate_content
exit /b 0

:help_and_exit
call :print_help
exit /b 0
