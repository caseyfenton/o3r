# O3R: Cross-Platform Support

This documentation explains the Windows compatibility features that have been added to the O3R tool. O3R now supports both macOS and Windows environments.

## Windows Installation

To install O3R on Windows:

1. Clone or download this repository
2. Run the Windows installer script:
   ```
   install.bat
   ```

The installer will create the necessary batch files and add them to your `%USERPROFILE%\bin` directory. If this directory is not in your PATH, you'll need to add it manually:

```
setx PATH "%PATH%;%USERPROFILE%\bin"
```

## Windows Commands

The following commands will be available after installation:

- `o3r.bat` - Prepare code for O3 refactoring
- `o3r-collect.bat` - Assist with collecting responses from O3
- `o3r-monitor.bat` - Monitor for O3 responses 
- `o3r-run.bat` - Run the complete O3 workflow

## Key Differences in Windows Version

The Windows version functions similarly to the macOS version with a few key differences:

1. **Browser Automation**: The Windows version opens the O3 chat URL in your browser but requires manual paste and submission (using Ctrl+V and Enter)

2. **Clipboard Handling**: Uses PowerShell commands for clipboard operations instead of pbcopy/pbpaste

3. **Response Collection**: When monitoring for responses, you'll need to manually copy the O3 response (Ctrl+C) when it's ready

4. **Browser Support**: Supports both Chrome and Edge browsers with the `-b` option:
   ```
   o3r-collect -b edge
   ```

## Usage Examples

Process Python files in a directory:
```
o3r -d src -e py
```

Run the complete workflow:
```
o3r-run -d src -e py -m 600
```

Extract code blocks from an O3 response:
```
o3r-collect code
```

## Known Limitations

- File path handling uses Windows conventions (backslashes)
- Some advanced features that require AppleScript on macOS have reduced functionality on Windows
- Reading from stdin via `-f -` is not supported in the Windows version

## Cross-Platform Support

The repository now contains both shell scripts (.sh) for macOS/Linux and batch files (.bat) for Windows:

- macOS/Linux users should use the .sh files or run the shell commands without extension
- Windows users should use the .bat files

For more information on the core O3R functionality, see the main [README.md](README.md).
