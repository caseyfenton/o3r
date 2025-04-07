#!/bin/bash
#
# O3 Background Process
# Automates the entire O3 workflow in the background
#

set -e

# Default values
check_interval=30
max_wait_time=1800  # 30 minutes
min_response_size=100
output_file="o3_response_$(date +%Y%m%d_%H%M%S).txt"
web_app_path=""
input_file=""

print_help() {
    cat << EOF
o3r_background.sh: Complete O3 workflow automation

DESCRIPTION
    Runs a complete O3 workflow in the background:
    1. Opens O3 web app
    2. Pastes content from file or clipboard
    3. Submits request
    4. Periodically checks for response
    5. Saves response to file when ready

USAGE
    ./o3r_background.sh [OPTIONS]

OPTIONS
    -h, --help           Show help message
    -i, --interval SEC   Check interval in seconds (default: 30)
    -m, --max-time SEC   Maximum time to wait in seconds (default: 1800)
    -s, --min-size BYTES Minimum response size to consider valid (default: 100)
    -f, --file FILE      Input file containing content to submit
    -o, --output FILE    Save final response to file (default: o3_response_DATE.txt)
    -a, --app-path PATH  Path to O3 web app (default: auto-detect)

EXAMPLES
    # Submit content from clipboard
    ./o3r_background.sh

    # Submit content from file
    ./o3r_background.sh -f input.txt -o response.txt

    # Custom check interval and timeout
    ./o3r_background.sh -i 60 -m 3600
EOF
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        -h|--help)
            print_help
            exit 0
            ;;
        -i|--interval)
            check_interval="$2"
            shift 2
            ;;
        -m|--max-time)
            max_wait_time="$2"
            shift 2
            ;;
        -s|--min-size)
            min_response_size="$2"
            shift 2
            ;;
        -f|--file)
            input_file="$2"
            shift 2
            ;;
        -o|--output)
            output_file="$2"
            shift 2
            ;;
        -a|--app-path)
            web_app_path="$2"
            shift 2
            ;;
        *)
            echo "Unknown option: $1"
            print_help
            exit 1
            ;;
    esac
done

# Auto-detect O3 web app
auto_detect_web_app() {
    local apps=(
        "$HOME/Applications/Chrome Apps.localized/ChatGPT-o3-mini-high.app"
    )
    
    for app in "${apps[@]}"; do
        if [ -e "$app" ]; then
            web_app_path="$app"
            echo "Found O3 web app: $web_app_path"
            return 0
        fi
    done
    
    echo "No O3 web app found. Will use Chrome Dev instead."
    return 1
}

# Get clipboard content
get_clipboard() {
    if command -v pbpaste > /dev/null; then
        pbpaste
    else
        echo "Error: pbpaste command not found (not on macOS?)" >&2
        exit 1
    fi
}

# Set clipboard content
set_clipboard() {
    if command -v pbcopy > /dev/null; then
        pbcopy
    else
        echo "Error: pbcopy command not found (not on macOS?)" >&2
        exit 1
    fi
}

# Submit content to O3
submit_content() {
    # Get content from file or clipboard
    if [ -n "$input_file" ]; then
        if [ -f "$input_file" ]; then
            cat "$input_file" | set_clipboard
            echo "Content loaded from file: $input_file"
        else
            echo "Error: Input file not found: $input_file" >&2
            exit 1
        fi
    else
        echo "Using content from clipboard"
    fi
    
    # Determine app to use
    if [ -z "$web_app_path" ]; then
        auto_detect_web_app
    fi
    
    app_name=$(basename "$web_app_path")
    echo "Opening O3 using web app: $app_name..."
    
    # Open app and submit content
    open -a "$web_app_path"
    echo "Waiting 3 seconds for app to load..."
    sleep 3
    
    # Paste and submit content
    osascript <<EOF
tell application "System Events"
    keystroke "v" using command down
    delay 1
    key code 36 -- Return key
end tell
EOF
    
    echo "✅ Content submitted to O3 at $(date)"
    echo "⏳ Monitoring for response..."
}

# Periodically check for response
monitor_response() {
    local start_time=$(date +%s)
    local end_time=$((start_time + max_wait_time))
    local check_count=0
    
    echo "🔍 Starting response monitoring at $(date)"
    echo "⏱️  Will check every $check_interval seconds for up to $max_wait_time seconds"
    echo "💾 Response will be saved to: $output_file"
    echo "⚡ This is running in the background (PID: $$)"
    echo "-------------------------------------------------"
    
    while [ $(date +%s) -lt $end_time ]; do
        check_count=$((check_count + 1))
        local elapsed=$(($(date +%s) - start_time))
        
        # Attempt to copy response
        osascript <<EOF
tell application "System Events"
    keystroke "c" using {command down, shift down}
    delay 1
end tell
EOF
        
        local response=$(get_clipboard)
        local response_size=${#response}
        
        echo "[Check $check_count] After ${elapsed}s: Response size $response_size bytes"
        
        # Check if response is valid
        if [ $response_size -ge $min_response_size ]; then
            echo "✅ Valid response detected after $elapsed seconds!"
            echo "📋 Response size: $response_size bytes"
            echo "----- RESPONSE PREVIEW (first 200 chars) -----"
            echo "${response:0:200}"
            echo "----------------------------------------------"
            
            # Save response to file
            echo "$response" > "$output_file"
            echo "💾 Full response saved to: $output_file"
            return 0
        fi
        
        # Wait for next check
        sleep $check_interval
    done
    
    echo "❌ No valid response detected within $max_wait_time seconds"
    return 1
}

# Main workflow
submit_content
monitor_response

exit $?
