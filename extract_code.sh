#!/bin/bash
# Simple script to extract code blocks from the O3R output

SOURCE_FILE="/Users/casey/CascadeProjects/VoiceInk-Free/o3r_complete_output.txt"
OUTPUT_DIR="/Users/casey/CascadeProjects/VoiceInk-Free/extracted_code_$(date +%Y%m%d%H%M%S)"
BACKUP_DIR="/Users/casey/CascadeProjects/VoiceInk-Free/backups_$(date +%Y%m%d%H%M%S)"

mkdir -p "$OUTPUT_DIR" "$BACKUP_DIR"

echo "📋 Extracting VoiceInk → VibeRater refactored code"
echo "=================================================="
echo "Output directory: $OUTPUT_DIR"
echo "Backup directory: $BACKUP_DIR"

# Extract file names and their code blocks
grep -n "^# FILE:" "$SOURCE_FILE" | while read -r line; do
  line_num=$(echo "$line" | cut -d: -f1)
  file_path=$(echo "$line" | sed 's/^[0-9]*:# FILE: //')
  echo "Processing: $file_path"
  
  # Create backup of original file if it exists
  if [ -f "$file_path" ]; then
    backup_file="$BACKUP_DIR/$(basename "$file_path")"
    cp "$file_path" "$backup_file"
    echo "✅ Backed up to: $backup_file"
  fi
  
  # Get the code block after this file marker
  start_line=$((line_num + 1))
  extract_file="$OUTPUT_DIR/$(basename "$file_path")"
  
  # Extract content between the file marker and the next file marker or end of file
  next_marker=$(grep -n "^# FILE:" "$SOURCE_FILE" | awk -F: -v start="$start_line" '$1 > start {print $1; exit}')
  
  if [ -z "$next_marker" ]; then
    # No next marker, so extract until end of file
    tail -n "+$start_line" "$SOURCE_FILE" > "$extract_file.tmp"
  else
    # Extract until the next file marker
    head_lines=$((next_marker - start_line))
    tail -n "+$start_line" "$SOURCE_FILE" | head -n "$head_lines" > "$extract_file.tmp"
  fi
  
  # Clean up the extracted content to get just the code
  sed -n '/^```swift/,/^```/ { /^```swift/d; /^```$/d; p; }' "$extract_file.tmp" > "$extract_file"
  rm "$extract_file.tmp"
  
  echo "✅ Extracted to: $extract_file"
  
  # Also apply the changes to the original file if it exists
  if [ -f "$file_path" ]; then
    cp "$extract_file" "$file_path"
    echo "✅ Applied changes to: $file_path"
  fi
done

echo ""
echo "✨ Extraction and application complete!"
echo "All files have been extracted to: $OUTPUT_DIR"
echo "And applied to their original locations"
echo "Original files backed up to: $BACKUP_DIR"
echo ""
echo "🔒 SECURITY NOTE:"
echo "Remember to verify WebKit URL handling in the refactored code"
echo "Ensure proper URL sanitization is implemented before text passes to WebKit components"
