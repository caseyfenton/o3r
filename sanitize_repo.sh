#!/bin/bash
# sanitize_repo.sh - Remove personal path information from the repository
# Run this script before publishing to GitHub

set -e  # Exit on error

echo "O3R Repository Sanitization Tool"
echo "================================"
echo "This script will remove personal path information from the repository."
echo

# Get the directory where this script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"

# Calculate the base directory name without personal information
BASE_DIR="$(basename "$SCRIPT_DIR")"
PARENT_DIR="$(dirname "$SCRIPT_DIR")"
USER_NAME="$(echo "$PARENT_DIR" | grep -o '[^/]*$')"

echo "Detected information:"
echo "- Repository directory: $BASE_DIR"
echo "- Current username: $USER_NAME"
echo

# Function to safely update file content
update_file() {
    local file="$1"
    local temp_file="$(mktemp)"
    
    if [ ! -f "$file" ]; then
        echo "Warning: File not found: $file"
        return 1
    fi
    
    # Replace absolute paths with script directory
    sed "s|$PARENT_DIR/$BASE_DIR|%INSTALL_DIR%|g" "$file" > "$temp_file"
    sed -i "" "s|/Users/$USER_NAME/|%USER_HOME%/|g" "$temp_file"
    sed -i "" "s|$USER_NAME|%USERNAME%|g" "$temp_file"
    
    # Only update if changes were made
    if ! diff -q "$file" "$temp_file" > /dev/null 2>&1; then
        cp "$temp_file" "$file"
        echo "✓ Sanitized: $file"
    else
        echo "  No changes needed: $file"
    fi
    
    rm "$temp_file"
}

# Create a template for the o3r script that uses relative paths
create_template_o3r() {
    cat > "o3r.template" << 'EOF'
#!/usr/bin/env bash
# Direct o3r CLI wrapper script

# Exit on error, undefined variables, and pipe failures
set -euo pipefail

# Get the directory where this script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
MAIN_SCRIPT="$SCRIPT_DIR/o3r.sh"

# Use script location to ensure command works from anywhere
if [ ! -x "$MAIN_SCRIPT" ]; then
    echo "Error: Could not find o3r main script at $MAIN_SCRIPT"
    echo "Please reinstall o3r or check your installation"
    exit 1
fi

exec "$MAIN_SCRIPT" "$@"
EOF
    echo "✓ Created template for o3r script"
}

# Modify the install.sh script to use relative paths
update_install_script() {
    # Create a backup
    cp "install.sh" "install.sh.bak"
    
    # Modify the script to use the template
    sed -i "" 's|cat > "$O3R_SCRIPT" << EOF|cat > "$O3R_SCRIPT" << '\''EOF'\''|' "install.sh"
    sed -i "" '/^# Installed path:/d' "install.sh"
    sed -i "" 's|# Use absolute paths to ensure command works from anywhere|# Get the directory where this script is located\nSCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" \&\& pwd )"\nMAIN_SCRIPT="$SCRIPT_DIR/o3r.sh"|' "install.sh"
    
    echo "✓ Updated install.sh to use relative paths"
}

# Find all script files and sanitize them
echo "Sanitizing files..."
create_template_o3r
find . -type f -name "*.sh" -o -name "*.bat" -o -name "o3r" -o -name "README*.md" | while read -r file; do
    update_file "$file"
done

# Update the install script
update_install_script

echo
echo "Repository sanitization complete!"
echo
echo "Next steps:"
echo "1. Review the changes (git diff)"
echo "2. Run the sanitized install script to update the o3r script"
echo "3. Test everything to ensure it works as expected"
echo "4. Commit changes to Git"
echo
echo "Remember to use git clean to remove any temporary files before publishing."
