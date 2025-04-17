#!/bin/bash
# Simple extraction script for O3R refactoring output

# Create output directory
TIMESTAMP=$(date +%Y%m%d%H%M%S)
OUTPUT_DIR="/Users/casey/CascadeProjects/VoiceInk-Free/refactored_code_${TIMESTAMP}"
mkdir -p "$OUTPUT_DIR"

# Example for checking file format - you can view the structure
echo "Checking file format of o3r_complete_output.txt:"
head -20 /Users/casey/CascadeProjects/VoiceInk-Free/o3r_complete_output.txt > "$OUTPUT_DIR/sample.txt"

# Create README
echo "# VoiceInk to VibeRater Refactoring" > "$OUTPUT_DIR/README.md"
echo "Generated: $(date)" >> "$OUTPUT_DIR/README.md"
echo "" >> "$OUTPUT_DIR/README.md"
echo "## Files" >> "$OUTPUT_DIR/README.md"
echo "" >> "$OUTPUT_DIR/README.md"
echo "- [o3r_complete_output.txt](/Users/casey/CascadeProjects/VoiceInk-Free/o3r_complete_output.txt)" >> "$OUTPUT_DIR/README.md"
echo "- [o3r_output_batch1.txt](/Users/casey/CascadeProjects/VoiceInk-Free/o3r_output_batch1.txt)" >> "$OUTPUT_DIR/README.md"
echo "- [o3r_output_batch2.txt](/Users/casey/CascadeProjects/VoiceInk-Free/o3r_output_batch2.txt)" >> "$OUTPUT_DIR/README.md"
echo "- [o3r_output_batch3.txt](/Users/casey/CascadeProjects/VoiceInk-Free/o3r_output_batch3.txt)" >> "$OUTPUT_DIR/README.md"
echo "" >> "$OUTPUT_DIR/README.md"

# Copy the original output files for reference
cp /Users/casey/CascadeProjects/VoiceInk-Free/o3r_complete_output.txt "$OUTPUT_DIR/"
cp /Users/casey/CascadeProjects/VoiceInk-Free/o3r_output_batch*.txt "$OUTPUT_DIR/" 2>/dev/null

echo "✨ Files saved to: $OUTPUT_DIR"
echo "To view the structure of the O3R output, check $OUTPUT_DIR/sample.txt"
echo ""
echo "🔒 SECURITY REMINDER:"
echo "When implementing the refactoring, remember to review for proper WebKit URL handling"
echo "Ensure URL sanitization is implemented before text passes to WebKit components"
