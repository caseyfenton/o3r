@echo off
REM O3R Installer Script for Windows
REM Installs the commands to a location in PATH

echo O3R Installer for Windows
echo =========================

set SCRIPT_DIR=%~dp0
set SCRIPT_DIR=%SCRIPT_DIR:~0,-1%
set O3R_SCRIPT=%SCRIPT_DIR%\o3r.bat
set MAIN_SCRIPT=%SCRIPT_DIR%\o3r_main.bat
set COLLECT_SCRIPT=%SCRIPT_DIR%\o3r_collect_response.bat
set MONITOR_SCRIPT=%SCRIPT_DIR%\o3r_monitor_response.bat
set BACKGROUND_SCRIPT=%SCRIPT_DIR%\o3r_background.bat

REM Create bin directory in user profile if it doesn't exist
if not exist "%USERPROFILE%\bin" (
    echo Creating %USERPROFILE%\bin directory...
    mkdir "%USERPROFILE%\bin"
)

REM Check if Windows directory is writable (for admin users)
set INSTALL_DIRS="%USERPROFILE%\bin"
if exist "C:\Windows" (
    echo Found C:\Windows - checking if writable...
    echo Testing write permissions... > "C:\Windows\o3r_test.txt" 2>nul
    if exist "C:\Windows\o3r_test.txt" (
        del "C:\Windows\o3r_test.txt"
        set "INSTALL_DIRS=%INSTALL_DIRS% C:\Windows"
    )
)

REM Create the main wrapper script
echo @echo off > "%O3R_SCRIPT%"
echo REM O3R CLI wrapper script >> "%O3R_SCRIPT%"
echo REM Installed path: %SCRIPT_DIR% >> "%O3R_SCRIPT%"
echo. >> "%O3R_SCRIPT%"
echo REM Check if main script exists >> "%O3R_SCRIPT%"
echo if not exist "%MAIN_SCRIPT%" ( >> "%O3R_SCRIPT%"
echo   echo Error: Could not find o3r main script at %MAIN_SCRIPT% >> "%O3R_SCRIPT%"
echo   echo Please reinstall o3r or check your installation >> "%O3R_SCRIPT%"
echo   exit /b 1 >> "%O3R_SCRIPT%"
echo ) >> "%O3R_SCRIPT%"
echo. >> "%O3R_SCRIPT%"
echo call "%MAIN_SCRIPT%" %%* >> "%O3R_SCRIPT%"

REM Make scripts executable
echo Making scripts executable...

REM Create batch wrapper scripts for all installation directories
for %%I in (%INSTALL_DIRS%) do (
    REM Main o3r command
    echo Installing o3r command to %%~I...
    echo @echo off > "%%~I\o3r.bat"
    echo REM O3R wrapper script >> "%%~I\o3r.bat" 
    echo call "%O3R_SCRIPT%" %%* >> "%%~I\o3r.bat"

    REM Create wrapper for collect command
    echo Installing o3r-collect command to %%~I...
    echo @echo off > "%%~I\o3r-collect.bat"
    echo REM o3r-collect wrapper script >> "%%~I\o3r-collect.bat"
    echo call "%COLLECT_SCRIPT%" %%* >> "%%~I\o3r-collect.bat"

    REM Create wrapper for monitor command
    echo Installing o3r-monitor command to %%~I...
    echo @echo off > "%%~I\o3r-monitor.bat"
    echo REM o3r-monitor wrapper script >> "%%~I\o3r-monitor.bat"
    echo call "%MONITOR_SCRIPT%" %%* >> "%%~I\o3r-monitor.bat"

    REM Create wrapper for background command
    echo Installing o3r-run command to %%~I...
    echo @echo off > "%%~I\o3r-run.bat"
    echo REM o3r-run wrapper script >> "%%~I\o3r-run.bat"
    echo call "%BACKGROUND_SCRIPT%" %%* >> "%%~I\o3r-run.bat"

    echo ✓ Commands installed to %%~I
)

echo Checking if PATH contains installation directory...
echo %PATH% | findstr /i /c:"%USERPROFILE%\bin" > nul
if errorlevel 1 (
    echo WARNING: %USERPROFILE%\bin is not in your PATH.
    echo Please add it to your PATH to use o3r commands from anywhere.
    echo You can do this by running:
    echo setx PATH "%%PATH%%;%%USERPROFILE%%\bin"
)

echo.
echo ✓ O3R installed successfully!
echo   The following commands are now available:
echo   - o3r          : Prepare code for O3 refactoring
echo   - o3r-collect  : Collect response from O3
echo   - o3r-monitor  : Monitor for O3 responses
echo   - o3r-run      : Run complete O3 workflow in background
echo   Run each command with --help to see usage instructions.
