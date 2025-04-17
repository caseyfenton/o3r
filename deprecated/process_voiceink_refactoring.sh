#!/bin/bash
# Complete processor for VoiceInk → VibeRater refactoring

# Directories to process in priority order
DIRS=(
  "/Users/casey/CascadeProjects/VoiceInk-Free/VibeRater/AppConfig.swift"
  "/Users/casey/CascadeProjects/VoiceInk-Free/VibeRater/Utilities"
  "/Users/casey/CascadeProjects/VoiceInk-Free/VibeRater/Services"
  "/Users/casey/CascadeProjects/VoiceInk-Free/VibeRater/ViewModels"
  "/Users/casey/CascadeProjects/VoiceInk-Free/VibeRater/Models"
  "/Users/casey/CascadeProjects/VoiceInk-Free/VibeRater/Views"
)

# Timestamp for output files
TIMESTAMP=$(date +%Y%m%d%H%M%S)
mkdir -p /Users/casey/CascadeProjects/VoiceInk-Free/o3r_output

# Process each directory in sequence
for dir in "${DIRS[@]}"; do
  echo ""
  echo "====================================="
  echo "Processing: $dir"
  echo "====================================="
  
  # Handle single file case
  if [[ -f "$dir" ]]; then
    # Generate clipboard content
    echo "Processing single file: $dir"
    ./o3r.sh -P viberate_prompt.txt -f <(echo "$dir") -e swift
    
    # Save a copy of what was generated
    BASENAME=$(basename "$dir")
    pbpaste > "/Users/casey/CascadeProjects/VoiceInk-Free/o3r_output/${BASENAME}_${TIMESTAMP}.txt"
    
    echo "Content saved to: /Users/casey/CascadeProjects/VoiceInk-Free/o3r_output/${BASENAME}_${TIMESTAMP}.txt"
    echo "Ready to paste to ChatGPT/O3 - press ENTER when you want to continue to next batch"
    read
    continue
  fi
  
  # Directory case
  echo "Processing directory: $dir"
  ./o3r.sh -P viberate_prompt.txt -d "$dir" -e swift
  
  # Save a copy of what was generated
  DIRNAME=$(basename "$dir")
  pbpaste > "/Users/casey/CascadeProjects/VoiceInk-Free/o3r_output/${DIRNAME}_${TIMESTAMP}.txt"
  
  echo "Content saved to: /Users/casey/CascadeProjects/VoiceInk-Free/o3r_output/${DIRNAME}_${TIMESTAMP}.txt"
  echo "Ready to paste to ChatGPT/O3 - press ENTER when you want to continue to next batch"
  read
done

echo "All components have been processed!"
echo "Refactored code is saved in the o3r_output directory"
