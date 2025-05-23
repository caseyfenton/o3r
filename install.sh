#!/usr/bin/env bash
# O3R Installer Script
# Installs the commands globally
set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
O3R_SCRIPT="$SCRIPT_DIR/o3r"
MAIN_SCRIPT="$SCRIPT_DIR/o3r.sh"
COLLECT_SCRIPT="$SCRIPT_DIR/o3r_collect_response.sh"
MONITOR_SCRIPT="$SCRIPT_DIR/o3r_monitor_response.sh"
BACKGROUND_SCRIPT="$SCRIPT_DIR/o3r_background.sh"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

function print_message {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

function command_exists {
    command -v "$1" >/dev/null 2>&1
}

# Create wrapper scripts
cat > "$O3R_SCRIPT" << EOF
#!/usr/bin/env bash
# Direct o3r CLI wrapper script
# Installed path: $SCRIPT_DIR

# Exit on error, undefined variables, and pipe failures
set -euo pipefail

# Use absolute paths to ensure command works from anywhere
if [ ! -x "$MAIN_SCRIPT" ]; then
    echo "Error: Could not find o3r main script at $MAIN_SCRIPT"
    echo "Please reinstall o3r or check your installation"
    exit 1
fi

exec "$MAIN_SCRIPT" "\$@"
EOF
chmod +x "$O3R_SCRIPT"

# Check for required commands
if ! command_exists pbcopy && ! command_exists xclip; then
    print_message "$YELLOW" "Warning: Neither pbcopy (Mac) nor xclip (Linux) found. Clipboard features will be disabled."
fi

# Determine installation directories
INSTALL_DIRS=()

# Check for user bin directory (like bgrun)
if [ -d "$HOME/bin" ]; then
    INSTALL_DIRS+=("$HOME/bin")
fi

# Check for local bin directory (like askp)
if [ -d "$HOME/.local/bin" ]; then
    INSTALL_DIRS+=("$HOME/.local/bin")
elif [ -w "/usr/local/bin" ]; then
    INSTALL_DIRS+=("/usr/local/bin")
fi

# Create .local/bin if no installation directories found
if [ ${#INSTALL_DIRS[@]} -eq 0 ]; then
    mkdir -p "$HOME/.local/bin"
    INSTALL_DIRS+=("$HOME/.local/bin")
fi

# Create wrapper scripts for all commands
for INSTALL_DIR in "${INSTALL_DIRS[@]}"; do
    # Main o3r command
    ln -sf "$O3R_SCRIPT" "$INSTALL_DIR/o3r"
    
    # Create wrapper scripts for O3R automation commands
    cat > "$INSTALL_DIR/o3r-collect" << EOF
#!/usr/bin/env bash
# o3r-collect wrapper script
# Points to: $COLLECT_SCRIPT

# Exit on error, undefined variables, and pipe failures
set -euo pipefail

# Check if target script exists
if [ ! -x "$COLLECT_SCRIPT" ]; then
    echo "Error: Could not find o3r collect script at $COLLECT_SCRIPT"
    echo "Please reinstall o3r or check your installation"
    exit 1
fi

exec "$COLLECT_SCRIPT" "\$@"
EOF
    chmod +x "$INSTALL_DIR/o3r-collect"
    
    cat > "$INSTALL_DIR/o3r-monitor" << EOF
#!/usr/bin/env bash
# o3r-monitor wrapper script
# Points to: $MONITOR_SCRIPT

# Exit on error, undefined variables, and pipe failures
set -euo pipefail

# Check if target script exists
if [ ! -x "$MONITOR_SCRIPT" ]; then
    echo "Error: Could not find o3r monitor script at $MONITOR_SCRIPT"
    echo "Please reinstall o3r or check your installation"
    exit 1
fi

exec "$MONITOR_SCRIPT" "\$@"
EOF
    chmod +x "$INSTALL_DIR/o3r-monitor"
    
    cat > "$INSTALL_DIR/o3r-run" << EOF
#!/usr/bin/env bash
# o3r-run wrapper script
# Points to: $BACKGROUND_SCRIPT

# Exit on error, undefined variables, and pipe failures
set -euo pipefail

# Check if target script exists
if [ ! -x "$BACKGROUND_SCRIPT" ]; then
    echo "Error: Could not find o3r background script at $BACKGROUND_SCRIPT"
    echo "Please reinstall o3r or check your installation"
    exit 1
fi

exec "$BACKGROUND_SCRIPT" "\$@"
EOF
    chmod +x "$INSTALL_DIR/o3r-run"
    
    print_message "$GREEN" "✓ Commands installed to $INSTALL_DIR"
done

print_message "$GREEN" "✓ O3R installed successfully!"
print_message "$GREEN" "  The following commands are now available:"
print_message "$GREEN" "  - o3r          : Prepare code for O3 refactoring"
print_message "$GREEN" "  - o3r-collect  : Collect response from O3"
print_message "$GREEN" "  - o3r-monitor  : Monitor for O3 responses"
print_message "$GREEN" "  - o3r-run      : Run complete O3 workflow in background"
print_message "$YELLOW" "  Run each command with --help to see usage instructions."
