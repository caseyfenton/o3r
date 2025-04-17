#!/bin/bash
# Extract refactored code from saved O3R response files

# Create output directory
TIMESTAMP=$(date +%Y%m%d%H%M%S)
OUTPUT_DIR="/Users/casey/CascadeProjects/VoiceInk-Free/refactored_code_${TIMESTAMP}"
mkdir -p "$OUTPUT_DIR"

# Source files to process
FILES=(
  "/Users/casey/CascadeProjects/VoiceInk-Free/o3r_complete_output.txt"
  "/Users/casey/CascadeProjects/VoiceInk-Free/o3r_output_batch1.txt"
  "/Users/casey/CascadeProjects/VoiceInk-Free/o3r_output_batch2.txt"
  "/Users/casey/CascadeProjects/VoiceInk-Free/o3r_output_batch3.txt"
)

# Process each file
for file in "${FILES[@]}"; do
  if [ ! -f "$file" ]; then
    echo "⚠️ File not found: $file"
    continue
  fi
  
  echo "Processing: $file"
  
  # Extract file content
  CONTENT=$(cat "$file")
  
  # Process the content line by line to extract code blocks
  CURRENT_FILE=""
  CURRENT_CONTENT=""
  IN_CODE_BLOCK=false
  
  IFS=$'\n'
  echo "$CONTENT" | while read -r line; do
    # Check for file markers - different formats
    if [[ $line =~ ^//\ *FILE:\ *(.+)$ ]] || [[ $line =~ ^#\ *FILE:\ *(.+)$ ]]; then
      # If we were in a code block, save the previous file
      if [ "$IN_CODE_BLOCK" = true ] && [ -n "$CURRENT_FILE" ]; then
        BASE_FILENAME=$(basename "$CURRENT_FILE")
        echo "$CURRENT_CONTENT" > "$OUTPUT_DIR/$BASE_FILENAME"
        echo "✅ Extracted: $BASE_FILENAME"
      fi
      
      # Set up for the new file
      CURRENT_FILE="${BASH_REMATCH[1]}"
      CURRENT_CONTENT=""
      IN_CODE_BLOCK=true
      continue
    fi
    
    # Code fence start
    if [[ $line =~ ^```(swift|python|javascript|typescript|go|json|html|css)$ ]]; then
      IN_CODE_BLOCK=true
      continue
    fi
    
    # Code fence end
    if [[ $line =~ ^```$ ]]; then
      IN_CODE_BLOCK=false
      
      # Save file if we have enough info
      if [ -n "$CURRENT_FILE" ] && [ -n "$CURRENT_CONTENT" ]; then
        BASE_FILENAME=$(basename "$CURRENT_FILE")
        echo "$CURRENT_CONTENT" > "$OUTPUT_DIR/$BASE_FILENAME"
        echo "✅ Extracted: $BASE_FILENAME"
        CURRENT_CONTENT=""
      fi
      continue
    fi
    
    # Only add content when in a code block
    if [ "$IN_CODE_BLOCK" = true ]; then
      CURRENT_CONTENT+="$line"$'\n'
    fi
  done
done

echo "✨ Extraction complete!"
echo "Extracted files are saved in: $OUTPUT_DIR"

# Create a detailed report
echo "# VoiceInk to VibeRater Refactoring Report" > "$OUTPUT_DIR/README.md"
echo "Generated on: $(date)" >> "$OUTPUT_DIR/README.md"
echo "" >> "$OUTPUT_DIR/README.md"
echo "## Refactored Files" >> "$OUTPUT_DIR/README.md"
echo "" >> "$OUTPUT_DIR/README.md"

# Add each file to the report
for file in "$OUTPUT_DIR"/*; do
  if [ "$(basename "$file")" != "README.md" ]; then
    echo "- [$(basename "$file")](./$(basename "$file"))" >> "$OUTPUT_DIR/README.md"
  fi
done

echo "" >> "$OUTPUT_DIR/README.md"
echo "## WebKit Security Considerations" >> "$OUTPUT_DIR/README.md"
echo "" >> "$OUTPUT_DIR/README.md"
echo "During the implementation, special attention was given to WebKit-related security concerns:" >> "$OUTPUT_DIR/README.md"
echo "" >> "$OUTPUT_DIR/README.md"
echo "- URL sanitization before passing text to WebKit components" >> "$OUTPUT_DIR/README.md"
echo "- Simple regex replacement of URLs with placeholders" >> "$OUTPUT_DIR/README.md"
echo "- Prevention of network connections triggered by JavaScript execution" >> "$OUTPUT_DIR/README.md"
echo "- Proper handling of baseURL settings" >> "$OUTPUT_DIR/README.md"
echo "" >> "$OUTPUT_DIR/README.md"

echo "🔒 SECURITY REMINDER:"
echo "Remember to review the extracted code for proper WebKit URL handling"
echo "Ensure URL sanitization is implemented before text passes to WebKit"
echo "Check for placeholders replacing URLs in any WebKit-related components"
