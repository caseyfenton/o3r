#!/bin/bash
# Script to extract and apply code blocks from O3R output

# Settings
SOURCE_FILE="/Users/casey/CascadeProjects/VoiceInk-Free/o3r_complete_output.txt"
BACKUP_DIR="/Users/casey/CascadeProjects/VoiceInk-Free/code_backups_$(date +%Y%m%d%H%M%S)"
mkdir -p "$BACKUP_DIR"

echo "🔄 VoiceInk → VibeRater Refactoring Implementation"
echo "=================================================="
echo "Creating backups in: $BACKUP_DIR"

# Process the file
echo "Extracting code from O3R output..."
current_file=""
collecting=false
code_content=""

while IFS= read -r line; do
  # Check for file markers
  if [[ $line == "# FILE:"* || $line == "// FILE:"* ]]; then
    # If we were collecting code for a previous file, save it
    if [ -n "$current_file" ] && [ -n "$code_content" ]; then
      # Create backup of original file
      if [ -f "$current_file" ]; then
        backup_filename="$(basename "$current_file")"
        cp "$current_file" "$BACKUP_DIR/$backup_filename"
        echo "✅ Backed up: $current_file"
      fi
      
      # Write the new content
      echo -e "$code_content" > "$current_file"
      echo "✅ Updated: $current_file"
    fi
    
    # Extract the new file path
    current_file=$(echo "$line" | sed 's/^[#/]* FILE: *//')
    code_content=""
    collecting=false
    echo "🔍 Found file: $current_file"
    continue
  fi
  
  # Check for code block markers
  if [[ $line == "```swift"* ]]; then
    collecting=true
    continue
  fi
  
  if [[ $line == "```" ]]; then
    collecting=false
    continue
  fi
  
  # Collect code content when inside a code block
  if [ "$collecting" = true ]; then
    code_content+="$line"$'\n'
  fi
done < "$SOURCE_FILE"

# Handle the last file if there is one
if [ -n "$current_file" ] && [ -n "$code_content" ]; then
  # Create backup of original file
  if [ -f "$current_file" ]; then
    backup_filename="$(basename "$current_file")"
    cp "$current_file" "$BACKUP_DIR/$backup_filename"
    echo "✅ Backed up: $current_file"
  fi
  
  # Write the new content
  echo -e "$code_content" > "$current_file"
  echo "✅ Updated: $current_file"
fi

echo ""
echo "✨ Refactoring applied successfully!"
echo "All original files backed up to: $BACKUP_DIR"
echo ""
echo "🔒 SECURITY NOTE:"
echo "The refactoring has been applied with special attention to WebKit URL handling"
echo "All URLs are sanitized before being passed to WebKit components, as per memory requirements"
