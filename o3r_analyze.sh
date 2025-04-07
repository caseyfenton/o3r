#!/bin/bash
# O3R Analyze: Automated Code Analysis Tool
# Analyzes your codebase and provides insights using O3

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

# Default values
WATCH_DIR="."
EXTENSIONS="py,js,ts,go"
OUTPUT_DIR="$HOME/.o3r/insights"
LOG_FILE="$HOME/.o3r/analyze.log"
CONFIG_FILE="$HOME/.o3r/analyze.conf"
MAX_FILES=10
INSIGHTS_FILE="o3r_insights.md"

function print_message {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

function print_help {
    cat << 'HELP'
o3r-analyze: Code Analysis Tool

DESCRIPTION
    Analyzes your codebase and provides insights using O3.

USAGE
    o3r-analyze [OPTIONS] -d DIRECTORY

OPTIONS
    -d DIR        Directory to analyze
    -e EXTS       Comma-separated list of extensions (default: py,js,ts,go)
    -o DIR        Output directory for insights (default: ~/.o3r/insights)
    -n MAX        Maximum number of files to analyze at once (default: 10)
    -c FILE       Config file path (default: ~/.o3r/analyze.conf)
    -h, --help    Show help message

EXAMPLES
    # Analyze current directory
    o3r-analyze -d .
    
    # Analyze src directory with Python and JavaScript files
    o3r-analyze -d ./src -e py,js

    # Run with custom configuration file
    o3r-analyze -c ./myproject_analyze.conf
HELP
    exit 0
}

# Process command line arguments
[[ $# -eq 0 || "$1" =~ ^-h|--help$ ]] && print_help

while getopts "d:e:o:n:c:h" opt; do
    case $opt in
        d) WATCH_DIR="$OPTARG" ;;
        e) EXTENSIONS="$OPTARG" ;;
        o) OUTPUT_DIR="$OPTARG" ;;
        n) MAX_FILES="$OPTARG" ;;
        c) CONFIG_FILE="$OPTARG" ;;
        h) print_help ;;
        *) print_message "$RED" "Error: Invalid option. Try 'o3r-analyze --help' for usage." && exit 1 ;;
    esac
done

# Load config file if it exists
if [[ -f "$CONFIG_FILE" ]]; then
    print_message "$BLUE" "Loading configuration from $CONFIG_FILE"
    source "$CONFIG_FILE"
fi

# Ensure output directory exists
mkdir -p "$OUTPUT_DIR"
mkdir -p "$(dirname "$LOG_FILE")"

# Log function
function log {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

# Function to select important files for analysis
function select_files {
    local dir="$1"
    local exts="$2"
    local max_files="$3"
    local temp_file=$(mktemp)
    
    IFS=',' read -ra EXTENSIONS_ARRAY <<< "$exts"
    
    # Find all matching files
    for ext in "${EXTENSIONS_ARRAY[@]}"; do
        find "$dir" -type f -name "*.$ext" >> "$temp_file"
    done
    
    # Get list of files changed recently
    local recent_files=$(find "$dir" -type f -mtime -1 | sort)
    
    # If we have AI file selection, we could call an AI service here
    # For now, just take the most recently modified files up to max_files
    
    # Output the top N files, prioritizing recently changed ones
    (echo "$recent_files"; cat "$temp_file" | sort -u) | head -n "$max_files"
    
    rm "$temp_file"
}

# Function to generate analysis prompt
function generate_analysis_prompt {
    cat << 'EOL'
### CODE ANALYSIS INSTRUCTIONS ###
Please analyze this codebase and provide insights in the following categories:
1. Potential bugs or error-prone patterns
2. Performance optimization opportunities
3. Code quality and maintainability improvements
4. Architecture suggestions
5. Security concerns

For each insight:
- Provide a clear description of the issue or opportunity
- Reference specific file and line numbers
- Explain the impact or risk
- Suggest a concrete solution or improvement

Format your response as Markdown, with each category as a level-2 heading.
EOL
}

# Function to analyze code
function analyze_code {
    local dir="$1"
    local exts="$2"
    local max_files="$3"
    local output_dir="$4"
    local insights_file="$output_dir/$INSIGHTS_FILE"
    local temp_dir=$(mktemp -d)
    local prompt_file="$temp_dir/prompt.txt"
    local timestamp=$(date '+%Y%m%d%H%M%S')
    local files_to_analyze=$(select_files "$dir" "$exts" "$max_files")
    
    log "Starting analysis of $dir"
    log "Selected $(echo "$files_to_analyze" | wc -l) files for analysis"
    
    # Generate analysis prompt
    generate_analysis_prompt > "$prompt_file"
    
    # Append each file to the prompt
    echo -e "\n### CODEBASE ###\n" >> "$prompt_file"
    
    for file in $files_to_analyze; do
        if [[ -f "$file" ]]; then
            ext="${file##*.}"
            log "Adding $file to analysis"
            echo -e "\n\`\`\`$ext\n# FILE: $file" >> "$prompt_file"
            cat "$file" >> "$prompt_file"
            echo -e "\`\`\`" >> "$prompt_file"
        fi
    done
    
    # Add end marker
    echo -e "\n### END CODEBASE ###\n" >> "$prompt_file"
    
    log "Preparing to submit to O3 for analysis"
    
    # Create a dated insights file
    local dated_insights="$output_dir/insights_$timestamp.md"
    
    # Check if we can actually send this to O3
    if command -v pbcopy > /dev/null && [[ -x "$SCRIPT_DIR/o3r_collect_response.sh" ]]; then
        log "Analysis content prepared. Options:"
        log "1. Copy to clipboard: cat $prompt_file | pbcopy"
        log "2. Save to file: cp $prompt_file [destination]"
        log "3. Submit to O3: cat $prompt_file | pbcopy && \"$SCRIPT_DIR/o3r_collect_response.sh\" submit"
        
        # Copy to clipboard for convenience
        cat "$prompt_file" | pbcopy
        log "Analysis content copied to clipboard"
        
        # Provide the prompt file for manual use
        cp "$prompt_file" "$output_dir/analysis_prompt_$timestamp.txt"
        log "Analysis prompt saved to: $output_dir/analysis_prompt_$timestamp.txt"
        
        print_message "$GREEN" "✓ Analysis preparation complete!"
        print_message "$YELLOW" "Next steps:"
        print_message "$YELLOW" "1. Submit to O3 manually, or run: ${SCRIPT_DIR}/o3r_collect_response.sh submit"
        print_message "$YELLOW" "2. Once O3 responds, collect the response: ${SCRIPT_DIR}/o3r_collect_response.sh collect"
        print_message "$YELLOW" "3. Save the response to: $dated_insights"
    else
        log "Cannot access clipboard or required tools not available"
        cp "$prompt_file" "$output_dir/analysis_prompt_$timestamp.txt"
        log "Analysis prompt saved to: $output_dir/analysis_prompt_$timestamp.txt"
    fi
    
    # Clean up
    rm -rf "$temp_dir"
}

# Main execution
log "O3R Analyze starting with: TARGET_DIR=$WATCH_DIR"
analyze_code "$WATCH_DIR" "$EXTENSIONS" "$MAX_FILES" "$OUTPUT_DIR"
log "Analysis preparation complete"
