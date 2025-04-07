#!/bin/bash
# FILE: o3r_monitor_response.sh
# Description: Monitor for O3 response at regular intervals in Chrome web app

print_help() {
    cat << 'HELP'
o3r_monitor_response.sh: Monitor for O3 responses

DESCRIPTION
    Periodically checks for O3 responses in a Chrome web app until 
    a valid response is detected or the maximum time limit is reached.
    IMPORTANT: This script assumes O3 is already open in a Chrome web app!

USAGE
    ./o3r_monitor_response.sh [OPTIONS]

OPTIONS
    -h, --help           Show help message
    -i, --interval SEC   Check interval in seconds (default: 30)
    -m, --max-time SEC   Maximum time to wait in seconds (default: 300)
    -s, --min-size BYTES Minimum response size to consider valid (default: 20)
    -o, --output FILE    Save final response to file
    -a, --app-path PATH  Path to O3 web app (default: auto-detect)

EXAMPLES
    ./o3r_monitor_response.sh
    ./o3r_monitor_response.sh -i 5 -m 600
    ./o3r_monitor_response.sh --interval 15 --max-time 900 --output response.txt
HELP
}

# Default values
check_interval=30
max_wait_time=300
min_response_size=20
output_file=""
web_app_path=""

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

# Process options
while [[ "$#" -gt 0 ]]; do
    case $1 in
        -h|--help) print_help; exit 0 ;;
        -i|--interval) check_interval="$2"; shift ;;
        -m|--max-time) max_wait_time="$2"; shift ;;
        -s|--min-size) min_response_size="$2"; shift ;;
        -o|--output) output_file="$2"; shift ;;
        -a|--app-path) web_app_path="$2"; shift ;;
        *) echo "Unknown parameter: $1"; print_help; exit 1 ;;
    esac
    shift
done

# Check for macOS
if [ "$(uname)" != "Darwin" ]; then
    echo "Error: This script only works on macOS"
    exit 1
fi

# Auto-detect web app if not specified
if [ -z "$web_app_path" ]; then
    auto_detect_web_app
fi

# Start time tracking
start_time=$(date +%s)
end_time=$((start_time + max_wait_time))
check_count=0
response_size=0

# Start monitoring
echo "🔍 Starting response monitoring at $(date)"
echo "⏱️  Will check every ${check_interval} seconds for up to ${max_wait_time} seconds"
echo "⚡ Press Ctrl+C to cancel monitoring at any time"
echo "-------------------------------------------------"

while [ $(date +%s) -lt $end_time ]; do
    # Increment check counter
    check_count=$((check_count + 1))
    
    # Calculate elapsed time
    current_time=$(date +%s)
    elapsed=$((current_time - start_time))
    
    # Attempt to collect response using the appropriate app
    if [ -n "$web_app_path" ] && [ -e "$web_app_path" ]; then
        osascript << EOF > /dev/null
tell application "$web_app_path" to activate
delay 1
tell application "System Events"
    keystroke "c" using {command down, shift down}
end tell
EOF
    else
        osascript << EOF > /dev/null
tell application "Google Chrome Dev" to activate
delay 1
tell application "System Events"
    keystroke "c" using {command down, shift down}
end tell
EOF
    fi
    
    # Check clipboard content size
    if command -v pbpaste > /dev/null; then
        response=$(pbpaste)
        response_size=${#response}
        
        echo "[Check $check_count] After ${elapsed}s: Response size ${response_size} bytes"
        
        # If response is large enough, consider it valid
        if [ $response_size -gt $min_response_size ]; then
            echo "✅ Valid response detected after ${elapsed} seconds!"
            echo "📋 Response size: ${response_size} bytes"
            
            # Save to file if requested
            if [ -n "$output_file" ]; then
                echo "$response" > "$output_file"
                echo "💾 Response saved to ${output_file}"
            fi
            
            # Show preview
            echo "----- RESPONSE PREVIEW (first 200 chars) -----"
            echo "${response:0:200}"
            echo "----------------------------------------------"
            echo "Full response is in clipboard"
            
            exit 0
        fi
    fi
    
    # Wait before checking again
    sleep $check_interval
done

# If we get here, we timed out
echo "⏰ Timeout after ${max_wait_time} seconds"
echo "No valid response detected after ${check_count} checks"
exit 1
