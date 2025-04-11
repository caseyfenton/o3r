@echo off
REM o3r_collect_response.bat - Windows version
REM Interact with O3 model via browser automation

setlocal EnableDelayedExpansion

REM Functions
goto :main

:print_help
echo o3r_collect_response.bat: Interact with O3 and collect responses
echo.
echo DESCRIPTION
echo     Opens O3 model using Chrome, pastes content from clipboard,
echo     and provides commands to collect responses.
echo.
echo USAGE
echo     o3r_collect_response.bat [OPTIONS] [COMMAND]
echo.
echo COMMANDS
echo     submit      - Open O3, paste and submit content (default)
echo     collect     - Copy the current response
echo     code        - Copy just the last code block
echo.
echo OPTIONS
echo     -h, --help     Show help message
echo     -w SECONDS     Wait time before pasting (default: 3)
echo     -b BROWSER     Browser to use (chrome, edge, default: chrome)
echo.
echo EXAMPLES
echo     o3r_collect_response.bat           # Submit content
echo     o3r_collect_response.bat collect   # Collect response
echo     o3r_collect_response.bat code      # Collect code block
exit /b 0

:submit_content
echo Opening O3 and submitting content...

REM Wait to ensure browser is fully open
timeout /t %wait_before_paste% > nul

REM Open the browser with O3 URL
if "%browser%"=="edge" (
    start microsoft-edge https://chat.openai.com/?model=o3-mini-high
) else (
    start chrome https://chat.openai.com/?model=o3-mini-high
)

echo.
echo Browser has been opened with O3 chat URL.
echo.
echo MANUAL STEPS TO FOLLOW:
echo 1. Wait for the browser to fully load
echo 2. Press Ctrl+V to paste your code
echo 3. Press Enter to submit to O3
echo.
echo When ready to collect the response, run:
echo   o3r-collect collect
echo.
echo For code blocks only, run:
echo   o3r-collect code
echo.

exit /b 0

:collect_response
echo.
echo To collect the response from O3, follow these steps:
echo.
echo 1. Make sure the O3 response is complete
echo 2. Select all the text by clicking at the beginning
echo    and dragging to the end of the response
echo 3. Press Ctrl+C to copy the response
echo.
echo The response is now in your clipboard.
echo.
echo To extract just the code blocks, run:
echo   o3r-collect code
echo.

exit /b 0

:collect_code
echo.
echo To collect code blocks from O3, follow these steps:
echo.
echo 1. Make sure you have the O3 response copied to clipboard
echo 2. Running this command will extract code blocks from your clipboard
echo.

REM Create temporary files
set "temp_input=%TEMP%\o3r_code_input_%RANDOM%.txt"
set "temp_output=%TEMP%\o3r_code_output_%RANDOM%.txt"

REM Get clipboard content and save to temp file
powershell -command "Get-Clipboard | Out-File -Encoding utf8 '%temp_input%'"

REM Use PowerShell to extract code blocks
powershell -Command "& {
    $content = Get-Content -Raw '%temp_input%'
    $codeBlocks = [regex]::Matches($content, '```(?:\w+)?\r?\n([\s\S]*?)\r?\n```')
    $extracted = $codeBlocks | ForEach-Object { $_.Groups[1].Value } | Out-String
    $extracted | Out-File -Encoding utf8 '%temp_output%'
}"

REM Copy extracted code blocks back to clipboard
powershell -command "Get-Content '%temp_output%' | Set-Clipboard"

REM Display preview
powershell -Command "& {
    $content = Get-Content -Raw '%temp_output%'
    if ($content.Length -gt 0) {
        Write-Host '------- CODE BLOCK PREVIEW -------'
        if ($content.Length -gt 200) {
            Write-Host $content.Substring(0, 200) '...'
        } else {
            Write-Host $content
        }
        Write-Host '----------------------------------'
        Write-Host ('Full code block in clipboard ({0} characters)' -f $content.Length)
    } else {
        Write-Host 'No code blocks found in clipboard'
    }
}"

REM Clean up temp files
del "%temp_input%" > nul 2>&1
del "%temp_output%" > nul 2>&1

exit /b 0

:main
set "command=submit"
set "wait_before_paste=3"
set "browser=chrome"

REM Process options
:parse_args
if "%~1"=="" goto args_done
if "%~1"=="-h" goto help_and_exit
if "%~1"=="--help" goto help_and_exit
if "%~1"=="-w" (
    set "wait_before_paste=%~2"
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
if "%~1"=="submit" (
    set "command=submit"
    shift
    goto parse_args
)
if "%~1"=="collect" (
    set "command=collect"
    shift
    goto parse_args
)
if "%~1"=="code" (
    set "command=collect_code"
    shift
    goto parse_args
)
echo Unknown option: %1
call :print_help
exit /b 1

:args_done
if "%command%"=="submit" call :submit_content
if "%command%"=="collect" call :collect_response
if "%command%"=="collect_code" call :collect_code
exit /b 0

:help_and_exit
call :print_help
exit /b 0
