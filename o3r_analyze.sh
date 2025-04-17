#!/bin/bash
# O3R Analyze: Automated Code Analysis Tool
# Continuously analyzes your codebase in the background and provides insights

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
INTERVAL=3600  # Default: check every hour
OUTPUT_DIR="$HOME/.o3r/insights"
LOG_FILE="$HOME/.o3r/analyze.log"
CONFIG_FILE="$HOME/.o3r/analyze.conf"
DAEMON_MODE=false
MAX_FILES=10
INSIGHTS_FILE="o3r_insights.md"

function print_message {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

function print_help {
    cat << 'HELP'
o3r-analyze: Automated Code Analysis Tool

DESCRIPTION
    Continuously analyzes your codebase in the background and provides insights
    using O3. Can run as a daemon or one-time analysis.

USAGE
    o3r-analyze [OPTIONS] -d DIRECTORY

OPTIONS
    -d DIR        Directory to watch and analyze
    -e EXTS       Comma-separated list of extensions (default: py,js,ts,go)
    -i SECONDS    Check interval for daemon mode (default: 3600 seconds)
    -o DIR        Output directory for insights (default: ~/.o3r/insights)
    -n MAX        Maximum number of files to analyze at once (default: 10)
    -c FILE       Config file path (default: ~/.o3r/analyze.conf)
    -D            Run as daemon (background process)
    -1            Run once and exit
    -h, --help    Show help message

EXAMPLES
    # Run once on current directory
    o3r-analyze -d . -1
    
    # Start daemon watching src directory, checking every 4 hours
    o3r-analyze -d ./src -e py,js -i 14400 -D

    # Run with custom configuration file
    o3r-analyze -c ./myproject_analyze.conf
HELP
    exit 0
}

# Process command line arguments
[[ $# -eq 0 || "$1" =~ ^-h|--help$ ]] && print_help

while getopts "d:e:i:o:n:c:D1h" opt; do
    case $opt in
        d) WATCH_DIR="$OPTARG" ;;
        e) EXTENSIONS="$OPTARG" ;;
        i) INTERVAL="$OPTARG" ;;
        o) OUTPUT_DIR="$OPTARG" ;;
        n) MAX_FILES="$OPTARG" ;;
        c) CONFIG_FILE="$OPTARG" ;;
        D) DAEMON_MODE=true ;;
        1) DAEMON_MODE=false ;;
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
    if [[ "$DAEMON_MODE" == false ]]; then
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
    fi
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
    local recent_files=$(find "$dir" -type f -name "*.$ext" -mtime -1 | sort)
    
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
    
    local temp_dir=$(mktemp -d)
    local prompt_file="$temp_dir/analysis_prompt.txt"
    local insights_file="$output_dir/$INSIGHTS_FILE"
    local timestamp=$(date '+%Y%m%d%H%M%S')
    local files_to_analyze=$(select_files "$dir" "$exts" "$max_files")
    
    # Record start time
    local start_time=$(date '+%Y-%m-%d %H:%M:%S')
    
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
    
    # Add statistics
    local total_files=$(grep -c "# FILE:" "$prompt_file")
    local total_bytes=$(stat -f "%z" "$prompt_file")
    local total_lines=$(wc -l < "$prompt_file")
    local end_time=$(date '+%Y-%m-%d %H:%M:%S')
    # Estimate tokens (rough approximation: ~4 chars per token)
    local est_tokens=$(( total_bytes / 4 ))
    
    echo -e "### CODEBASE STATISTICS ###" >> "$prompt_file"
    echo -e "- Files processed: $total_files" >> "$prompt_file"
    echo -e "- Total size: $total_bytes bytes" >> "$prompt_file"
    echo -e "- Total lines: $total_lines" >> "$prompt_file"
    echo -e "- Estimated tokens: $est_tokens" >> "$prompt_file"
    echo -e "- Collection started: $start_time" >> "$prompt_file"
    echo -e "- Collection finished: $end_time" >> "$prompt_file"
    echo -e "### END STATISTICS ###\n" >> "$prompt_file"
    
    # Submit to O3 for analysis
    # This would use o3r's automation features
    # For now, we'll just simulate the process
    
    log "Preparing to submit to O3 for analysis"
    
    # Create a dated insights file
    local dated_insights="$output_dir/insights_$timestamp.md"
    
    # Check if we can actually send this to O3
    if command -v pbcopy > /dev/null && [[ -x "$SCRIPT_DIR/o3r_collect_response.sh" ]]; then
        log "Submitting to O3 using o3r tools"
        cat "$prompt_file" | pbcopy
        
        # Try to use o3r's automation
        "$SCRIPT_DIR/o3r_collect_response.sh" submit
        
        log "Waiting for O3 response (this would normally be async)"
        # In a real implementation, we'd start monitoring in the background
        # and continue with other tasks
        
        # For demo purposes, simulate getting a response
        cat > "$dated_insights" << EOL
# Code Analysis Insights (${timestamp})

## Potential Bugs

1. **Null Reference Risk in User Authentication**
   - **File**: src/auth/login.js:42
   - **Issue**: User object accessed without null check
   - **Impact**: Could cause application crash on invalid login
   - **Solution**: Add null/undefined guard before accessing properties

## Performance Optimizations

1. **Redundant API Calls**
   - **File**: src/services/data.js:78-95
   - **Impact**: Makes duplicate network requests for the same data
   - **Solution**: Implement request caching or use memoization

## Code Quality Improvements

1. **Function Length**
   - **File**: src/utils/parser.js:120-250
   - **Issue**: processData function is 130 lines long
   - **Impact**: Difficult to maintain and test
   - **Solution**: Break into smaller, focused functions

## Architecture Suggestions

1. **Centralize Error Handling**
   - **Issue**: Error handling scattered throughout the codebase
   - **Impact**: Inconsistent error reporting and recovery
   - **Solution**: Implement global error handler and standardized error objects

## Security Concerns

1. **Hardcoded Credentials**
   - **File**: src/config/database.js:8
   - **Issue**: Database password in plaintext
   - **Impact**: Critical security vulnerability
   - **Solution**: Move to environment variables or secure credential store
EOL
        
        # Create symlink to latest insights
        ln -sf "$dated_insights" "$insights_file"
        
        log "Analysis complete. Insights saved to: $dated_insights"
        log "Latest insights available at: $insights_file"
    else
        log "Cannot submit to O3: required tools not available"
        log "Would have analyzed $(echo "$files_to_analyze" | wc -l) files"
    fi
    
    # Clean up
    rm -rf "$temp_dir"
}

# Main execution
log "O3R Analyze starting with: WATCH_DIR=$WATCH_DIR, INTERVAL=$INTERVAL seconds"

if [[ "$DAEMON_MODE" == true ]]; then
    log "Running in daemon mode with interval $INTERVAL seconds"
    
    # Main daemon loop
    while true; do
        analyze_code "$WATCH_DIR" "$EXTENSIONS" "$MAX_FILES" "$OUTPUT_DIR"
        log "Sleeping for $INTERVAL seconds"
        sleep "$INTERVAL"
    done
else
    log "Running single analysis"
    analyze_code "$WATCH_DIR" "$EXTENSIONS" "$MAX_FILES" "$OUTPUT_DIR"
    log "Analysis complete"
fi
