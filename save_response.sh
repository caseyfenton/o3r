#!/bin/bash
# Save O3R response from clipboard to files

# Create output directory
TIMESTAMP=$(date +%Y%m%d%H%M%S)
OUTPUT_DIR="/Users/casey/CascadeProjects/VoiceInk-Free/o3r_output/${TIMESTAMP}"
mkdir -p "$OUTPUT_DIR"

# First save the complete response
echo "Saving complete response..."
pbpaste > "$OUTPUT_DIR/complete_response.txt"
echo "✅ Complete response saved to: $OUTPUT_DIR/complete_response.txt"

# Extract and save code blocks
echo "Extracting refactored code files..."
RESPONSE=$(pbpaste)
CURRENT_FILE=""
CURRENT_CONTENT=""
IN_CODE_BLOCK=false

# Process line by line
IFS=$'\n'
for line in $RESPONSE; do
  # Check for file markers
  if [[ $line =~ ^//\ *FILE:\ *(.+)$ ]]; then
    # If we were in a code block, save the previous file
    if [ "$IN_CODE_BLOCK" = true ] && [ -n "$CURRENT_FILE" ]; then
      FILENAME=$(basename "$CURRENT_FILE")
      echo "$CURRENT_CONTENT" > "$OUTPUT_DIR/$FILENAME"
      echo "✅ Extracted: $FILENAME"
    fi
    
    # Set up for the new file
    CURRENT_FILE="${BASH_REMATCH[1]}"
    CURRENT_CONTENT=""
    IN_CODE_BLOCK=true
    continue
  fi
  
  # Only add content when in a code block
  if [ "$IN_CODE_BLOCK" = true ]; then
    # Skip the closing code fence
    if [[ $line =~ ^```$ ]]; then
      IN_CODE_BLOCK=false
      continue
    fi
    
    # Skip the opening code fence
    if [[ $line =~ ^```swift$ ]]; then
      continue
    fi
    
    # Add the content line
    CURRENT_CONTENT+="$line"$'\n'
  fi
done

# Save the last file if needed
if [ "$IN_CODE_BLOCK" = true ] && [ -n "$CURRENT_FILE" ]; then
  FILENAME=$(basename "$CURRENT_FILE")
  echo "$CURRENT_CONTENT" > "$OUTPUT_DIR/$FILENAME"
  echo "✅ Extracted: $FILENAME"
fi

echo "✨ Refactoring extraction complete!"
echo "Extracted files are saved in: $OUTPUT_DIR"

# Important reminder about WebKit URL handling
echo ""
echo "🔒 SECURITY REMINDER:"
echo "Remember to review the extracted code for proper WebKit URL handling"
echo "Ensure URL sanitization is implemented before text passes to WebKit"
echo "Check for placeholders replacing URLs in any WebKit-related components"
