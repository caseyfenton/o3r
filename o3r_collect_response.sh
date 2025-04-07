#!/bin/bash
# FILE: o3r_collect_response.sh
# Description: Script to automate interactions with O3 model using Chrome web app

print_help() {
    cat << 'HELP'
o3r_collect_response.sh: Interact with O3 and collect responses

DESCRIPTION
    Opens O3 model using a Chrome web app, pastes content from clipboard,
    and provides commands to collect responses via keyboard shortcuts.

USAGE
    ./o3r_collect_response.sh [OPTIONS] [COMMAND]

COMMANDS
    submit      - Open O3, paste and submit content (default)
    collect     - Copy the current response with Cmd+Shift+C
    code        - Copy just the last code block with Cmd+Shift+;

OPTIONS
    -h, --help     Show help message
    -w SECONDS     Wait time before pasting (default: 3)
    -a APP_PATH    Full path to Chrome web app (default: auto-detect)

EXAMPLES
    ./o3r_collect_response.sh           # Submit content
    ./o3r_collect_response.sh collect   # Collect response
    ./o3r_collect_response.sh code      # Collect code block
HELP
}

# Check for macOS
if [ "$(uname)" != "Darwin" ]; then
    echo "Error: This script only works on macOS"
    exit 1
fi

# Default values
wait_before_paste=3
command="submit"
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
while getopts "hw:a:" opt; do
    case $opt in
        h) print_help; exit 0 ;;
        w) wait_before_paste="$OPTARG" ;;
        a) web_app_path="$OPTARG" ;;
        *) echo "Try './o3r_collect_response.sh --help' for more info."; exit 1 ;;
    esac
done

shift $((OPTIND-1))
[ "$1" ] && command="$1"

# Auto-detect web app if not specified
if [ -z "$web_app_path" ]; then
    auto_detect_web_app
fi

# Submit content to O3
submit_content() {
    echo "Opening O3 and submitting content..."
    
    # Wait to ensure app is fully open
    sleep "$wait_before_paste"
    
    # Submit clipboard content to web app
    if [ -n "$web_app_path" ] && [ -e "$web_app_path" ]; then
        osascript << EOF
tell application "$web_app_path" to activate
delay 1
tell application "System Events"
    # Paste clipboard content
    keystroke "v" using command down
    delay 2
    key code 36  # Press Enter
end tell
EOF
    else
        osascript << EOF
tell application "Google Chrome Dev" to activate
delay 1
tell application "System Events"
    # Paste clipboard content
    keystroke "v" using command down
    delay 2
    key code 36  # Press Enter
end tell
EOF
    fi
    
    echo "✅ Content submitted to O3"
    echo "⏳ Waiting for response..."
    echo "📋 When ready, run: $0 collect"
    echo "📊 For code blocks only, run: $0 code"
}

# Modified collect_response function to use keyboard shortcuts
collect_response() {
    local app_id="$1"
    local app_name="$2"
    local response_type="$3"
    
    echo "Collecting response from O3 model..."
    
    if [ "$response_type" = "code" ]; then
        # Extract only code blocks
        osascript << EOF
tell application "$web_app_path" to activate
delay 1
tell application "System Events"
    tell application process "$app_id"
        set frontmost to true
        delay 1
        keystroke ";" using {command down, shift down}
        delay 1
    end tell
end tell
EOF
        echo "✅ Code blocks collected from O3 response"
        
        # Show preview of collected content
        if command -v pbpaste > /dev/null; then
            code=$(pbpaste)
            echo "------- CODE BLOCK PREVIEW -------"
            echo "${code:0:200}..."
            echo "----------------------------------"
            echo "Full code block in clipboard (${#code} characters)"
        fi
    else
        # Collect full response
        osascript << EOF
tell application "$web_app_path" to activate
delay 1
tell application "System Events"
    tell application process "$app_id"
        set frontmost to true
        delay 1
        keystroke "c" using {command down, shift down}
        delay 1
    end tell
end tell
EOF
        echo "✅ Full response collected from O3"
        
        # Show preview of collected content
        if command -v pbpaste > /dev/null; then
            response=$(pbpaste)
            echo "------- RESPONSE PREVIEW -------"
            echo "${response:0:200}..."
            echo "--------------------------------"
            echo "Full response in clipboard (${#response} characters)"
        fi
    fi
}

case "$command" in
    submit)
        submit_content
        ;;
    collect)
        collect_response "$(basename "$web_app_path")" "$(basename "$web_app_path")" "full"
        ;;
    code)
        collect_response "$(basename "$web_app_path")" "$(basename "$web_app_path")" "code"
        ;;
    *)
        echo "Unknown command: $command"
        print_help
        exit 1
        ;;
esac

exit 0
