#!/bin/bash
# o3r_bgrun_integration.sh - Integration between o3r_analyze and BGRun
# Makes O3 insights available in .windsurfrules for LLMs

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
O3R_ANALYZE="$SCRIPT_DIR/o3r_analyze.sh"
O3R_INSIGHTS_DIR="${O3R_INSIGHTS_DIR:-$HOME/.o3r/insights}"
DEFAULT_CHECK_INTERVAL="4h"  # Default interval for checking code
DEFAULT_PROJECT_DIR="."      # Default project directory to analyze
DEFAULT_WIDGET_NAME="o3r-insights"

# Print help message
function print_help {
    cat << 'HELP'
o3r-insights: Integrate o3r code analysis with BGRun for LLM awareness

DESCRIPTION
    Sets up automated code analysis with o3r and makes insights available
    through BGRun widgets in .windsurfrules for LLMs to access.

USAGE
    o3r-insights [OPTIONS]

OPTIONS
    -d DIR        Project directory to analyze (default: current directory)
    -e EXTS       Comma-separated list of extensions (default: py,js,ts,go)
    -i INTERVAL   Check interval for analysis (default: 4h)
    -n MAX        Maximum number of files to analyze (default: 10)
    -w NAME       Custom widget name (default: o3r-insights)
    -s            Show current insights without starting analysis
    -1            Run analysis once and exit (no background monitoring)
    -h, --help    Show help message

EXAMPLES
    # Setup automated analysis of current directory with default settings
    o3r-insights
    
    # Analyze Python files in src directory every 12 hours
    o3r-insights -d ./src -e py -i 12h
    
    # Run once and show insights
    o3r-insights -1 -s
HELP
    exit 0
}

# Format insights for BGRun widget
function format_insights_for_widget {
    local insights_file="$1"
    local max_length=1500  # Maximum length to keep widget reasonable
    
    if [ ! -f "$insights_file" ]; then
        echo "No insights available yet. Analysis may still be running."
        return 0
    fi
    
    # Extract the most important insights
    {
        echo "## 🔍 O3 Code Insights"
        echo ""
        
        # Get section headers
        grep -E "^## " "$insights_file" | head -5
        
        echo ""
        echo "### Top Issues:"
        echo ""
        
        # Extract top item from each section (most important issues)
        awk '/^## / {in_section=1; section=$0; next} /^## / {in_section=0} in_section && /^1\. / {print "- " substr(section, 4) ": " substr($0, 4); in_section=0}' "$insights_file"
        
        echo ""
        echo "For full insights, run: cat $insights_file"
    } | head -c $max_length
}

# Show current insights
function show_current_insights {
    local insights_file="$O3R_INSIGHTS_DIR/o3r_insights.md"
    
    if [ ! -f "$insights_file" ]; then
        echo "No insights available yet."
        return 1
    fi
    
    echo "=== Current O3 Insights ==="
    cat "$insights_file"
    echo "=========================="
    
    return 0
}

# Setup BGRun widget with insights
function setup_bgrun_widget {
    local project_dir="$1"
    local extensions="$2"
    local interval="$3"
    local max_files="$4"
    local widget_name="$5"
    local one_time="$6"
    
    # Create insights directory if it doesn't exist
    mkdir -p "$O3R_INSIGHTS_DIR"
    
    if [ "$one_time" = "true" ]; then
        # Run analysis once and create widget, but don't schedule recurring checks
        echo "Running one-time analysis..."
        
        # Run o3r_analyze once
        "$O3R_ANALYZE" -d "$project_dir" -e "$extensions" -n "$max_files" -o "$O3R_INSIGHTS_DIR" -1
        
        # Format insights for widget
        local insights=$(format_insights_for_widget "$O3R_INSIGHTS_DIR/o3r_insights.md")
        
        # Use bgrun to create a one-time widget
        bgrun --widget "$widget_name" "echo '$insights'"
        
        echo "One-time analysis complete. Insights added to .windsurfrules widget '$widget_name'."
    else
        # Setup recurring analysis with BGRun
        echo "Setting up recurring analysis every $interval..."
        
        # Create the update command that will:
        # 1. Run o3r_analyze
        # 2. Format insights for the widget
        local update_cmd="\"$O3R_ANALYZE\" -d \"$project_dir\" -e \"$extensions\" -n \"$max_files\" -o \"$O3R_INSIGHTS_DIR\" -1 && cat \"$O3R_INSIGHTS_DIR/o3r_insights.md\" | head -n 50"
        
        # Use BGRun to schedule recurring analysis and widget updates
        bgrun --name "o3r-analysis" --widget "$widget_name" --interval "$interval" "$update_cmd"
        
        echo "Automated analysis scheduled with interval $interval."
        echo "Insights will be available in .windsurfrules widget '$widget_name'."
    fi
}

# Parse arguments
PROJECT_DIR="$DEFAULT_PROJECT_DIR"
EXTENSIONS="py,js,ts,go"
CHECK_INTERVAL="$DEFAULT_CHECK_INTERVAL"
MAX_FILES=10
WIDGET_NAME="$DEFAULT_WIDGET_NAME"
SHOW_ONLY=false
ONE_TIME=false

# Process command-line arguments
while getopts "d:e:i:n:w:s1h" opt; do
    case $opt in
        d) PROJECT_DIR="$OPTARG" ;;
        e) EXTENSIONS="$OPTARG" ;;
        i) CHECK_INTERVAL="$OPTARG" ;;
        n) MAX_FILES="$OPTARG" ;;
        w) WIDGET_NAME="$OPTARG" ;;
        s) SHOW_ONLY=true ;;
        1) ONE_TIME=true ;;
        h) print_help ;;
        *) echo "Unknown option: $opt"; print_help ;;
    esac
done

# Check if o3r_analyze.sh exists and is executable
if [ ! -x "$O3R_ANALYZE" ]; then
    echo "Error: o3r_analyze.sh not found or not executable at $O3R_ANALYZE"
    exit 1
fi

# Check if BGRun is installed
if ! command -v bgrun >/dev/null 2>&1; then
    echo "Error: bgrun not found. Please install BGRun first."
    exit 1
fi

# If show-only mode, just show current insights and exit
if [ "$SHOW_ONLY" = "true" ]; then
    show_current_insights
    exit $?
fi

# Setup the integration
setup_bgrun_widget "$PROJECT_DIR" "$EXTENSIONS" "$CHECK_INTERVAL" "$MAX_FILES" "$WIDGET_NAME" "$ONE_TIME"

exit 0
