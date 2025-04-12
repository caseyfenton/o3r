#!/bin/bash
# FILE: ./o3r.sh
# Description and help output
print_help() {
    cat << 'HELP'
o3r: Prepare code for O3 refactoring

DESCRIPTION
    Combines source files into a single document with formatting and 
    instructions for O3-based refactoring. Copies to clipboard by default.

USAGE
    o3r [OPTIONS] (-f FILE_LIST | -d DIRECTORY)

OPTIONS
    -o FILE     Write output to FILE instead of clipboard
    -f FILE     Read list of files from FILE
    -d DIR      Process all matching files in DIR recursively
    -e EXTS     Comma-separated list of extensions (default: py,js,ts,go)
    -p          Auto-paste to O3 (Mac only)
    -m          Auto-monitor for responses (Mac only)
    -i SECONDS  Check interval for monitoring (default: 30)
    -t SECONDS  Maximum wait time for monitoring (default: 300)
    -P FILE     Add additional prompt instructions from FILE
    -R NUMS     Remove specified requirements by number (e.g., "1,3,5")
    -s          Show the prompt that would be used without running
    -h, --help  Show help message

EXAMPLES
    o3r -d ./src -e py
    o3r -d ./src -e py -p
    o3r -f files.txt -o output.txt
    o3r -d "src/core,tests" -e py
    o3r -P custom_prompt.txt -d ./src
    o3r -R "2,5" -d ./src

NOTE
    Requires 'pbcopy' (Mac) or 'xclip' (Linux) for clipboard
    Auto-paste (-p) and auto-monitor (-m) only work on macOS with O3 web app
HELP
}

[[ $# -eq 0 || "$1" =~ ^-h|--help$ ]] && print_help && exit 0

output_file=""; file_list=""; directory=""; extensions="py,js,ts,go"; auto_paste=false; auto_monitor=false; monitor_interval=30; monitor_maxtime=300; prompt_add_file=""; prompt_remove_nums=""; show_prompt=false

while getopts "o:f:d:e:pmi:t:P:R:sh" opt; do
    case $opt in
        o) output_file="$OPTARG" ;;
        f) file_list="$OPTARG" ;;
        d) directory="$OPTARG" ;;
        e) extensions="$OPTARG" ;;
        p) auto_paste=true ;;
        m) auto_monitor=true ;;
        i) monitor_interval="$OPTARG" ;;
        t) monitor_maxtime="$OPTARG" ;;
        P) prompt_add_file="$OPTARG" ;;
        R) prompt_remove_nums="$OPTARG" ;;
        s) show_prompt=true ;;
        h) print_help; exit 0 ;;
        *) echo "Try 'o3r --help' for more info."; exit 1 ;;
    esac
done

[ -z "$file_list" ] && [ -z "$directory" ] && [ "$show_prompt" = false ] && { echo "Error: Provide -f or -d"; exit 1; }

# Function to generate formatted content
generate_content() {
    # Create a temp file to check size
    temp_file=$(mktemp)
    
    # Create the base prompt instructions
    cat << 'EOL' > "$temp_file"
### REFACTORING INSTRUCTIONS ###
Refactor this codebase with the following requirements, ordered by importance:

1. MAXIMIZE VERTICAL DENSITY: Combine related functions, variables, and imports on single lines where logical
2. PRESERVE FUNCTIONALITY: Ensure the code works exactly the same after refactoring
3. OPTIMIZE SYNTAX: Use language-specific shorthand syntax (ternaries, comprehensions, etc.) to reduce line count
4. MERGE REDUNDANCIES: Combine similar logic and remove duplicated code without changing behavior
5. PRESERVE CRITICAL CONTENT: Keep ALL literal strings exactly as-is, including messages, API responses, and assertions
6. MAINTAIN DOCUMENTATION: Preserve docstrings and comments that explain complex logic
7. ORGANIZE IMPORTS: Keep the same imports, but organize them better for readability

EOL

    # Process prompt removal if specified
    if [ -n "$prompt_remove_nums" ]; then
        echo "Removing prompt requirements: $prompt_remove_nums"
        # Create a temporary file for processing
        prompt_tmp=$(mktemp)
        # Split the numbers by comma
        IFS=',' read -ra nums_to_remove <<< "$prompt_remove_nums"
        # Read the temp_file line by line
        while IFS= read -r line; do
            skip=false
            for num in "${nums_to_remove[@]}"; do
                # Check if line starts with the number followed by a dot and space
                if [[ "$line" =~ ^$num\.\  ]]; then
                    skip=true
                    break
                fi
            done
            # Write line to new file unless it should be skipped
            if [ "$skip" = false ]; then
                echo "$line" >> "$prompt_tmp"
            fi
        done < "$temp_file"
        # Replace original with modified version
        mv "$prompt_tmp" "$temp_file"
    fi
    
    # Add additional prompt instructions if specified
    if [ -n "$prompt_add_file" ] && [ -f "$prompt_add_file" ]; then
        echo "Adding custom prompt instructions from $prompt_add_file"
        cat "$prompt_add_file" >> "$temp_file"
        echo -e "\n" >> "$temp_file"
    fi
    
    # Add the codebase header
    echo -e "### CODEBASE ###" >> "$temp_file"
    
    # Record start time
    start_time=$(date +"%Y-%m-%d %H:%M:%S")
    
    # Process directory input
    if [ -n "$directory" ]; then
        IFS=',' read -ra dirs <<< "$directory"
        for dir in "${dirs[@]}"; do
            IFS=',' read -ra exts <<< "$extensions"
            for ext in "${exts[@]}"; do
                echo "Scanning directory $dir for .$ext files..."
                find "$dir" -type f -name "*.$ext" | sort | while read -r file; do
                    echo "Adding $file..."
                    echo -e "\n\`\`\`$ext\n# FILE: $file" >> "$temp_file"
                    cat "$file" >> "$temp_file"
                    echo -e "\`\`\`" >> "$temp_file"
                done
            done
        done
    fi
    
    # Process file list input
    if [ -n "$file_list" ]; then
        if [ "$file_list" = "-" ]; then
            # Read from stdin
            while read -r file; do
                if [ -f "$file" ]; then
                    echo "Adding $file..."
                    ext="${file##*.}"
                    echo -e "\n\`\`\`$ext\n# FILE: $file" >> "$temp_file"
                    cat "$file" >> "$temp_file"
                    echo -e "\`\`\`" >> "$temp_file"
                else
                    echo "Warning: File not found - $file"
                fi
            done
        else
            # Read from file
            while read -r file; do
                if [ -f "$file" ]; then
                    echo "Adding $file..."
                    ext="${file##*.}"
                    echo -e "\n\`\`\`$ext\n# FILE: $file" >> "$temp_file"
                    cat "$file" >> "$temp_file"
                    echo -e "\`\`\`" >> "$temp_file"
                else
                    echo "Warning: File not found - $file"
                fi
            done < "$file_list"
        fi
    fi
    
    # Add comments and insights section
    echo -e "\n### COMMENTS AND INSIGHTS ###" >> "$temp_file"
    echo "Please provide any observations, concerns, or recommendations regarding this refactoring:" >> "$temp_file"
    echo "- Issues you encountered during refactoring" >> "$temp_file"
    echo "- Areas that could benefit from further improvement" >> "$temp_file"
    echo "- Suggestions for better architecture" >> "$temp_file"
    echo "- Installation or testing instructions if applicable" >> "$temp_file"

    # If show_prompt is true, display the prompt and exit
    if [ "$show_prompt" = true ]; then
        echo "=== PROMPT PREVIEW ==="
        cat "$temp_file" | head -30  # Show just the instructions part
        echo "=== END PROMPT PREVIEW ==="
        rm "$temp_file"
        exit 0
    fi
    
    # Add end marker
    echo -e "\n### END CODEBASE ###\n" >> "$temp_file"
    
    # Add statistics
    total_files=$(grep -c "# FILE:" "$temp_file")
    total_bytes=$(stat -f "%z" "$temp_file")
    total_lines=$(wc -l < "$temp_file")
    end_time=$(date +"%Y-%m-%d %H:%M:%S")
    # Estimate tokens (rough approximation: ~4 chars per token)
    est_tokens=$(( total_bytes / 4 ))
    
    echo -e "### CODEBASE STATISTICS ###" >> "$temp_file"
    echo -e "- Files processed: $total_files" >> "$temp_file"
    echo -e "- Total size: $total_bytes bytes" >> "$temp_file"
    echo -e "- Total lines: $total_lines" >> "$temp_file"
    echo -e "- Estimated tokens: $est_tokens" >> "$temp_file"
    echo -e "- Collection started: $start_time" >> "$temp_file"
    echo -e "- Collection finished: $end_time" >> "$temp_file"
    echo -e "### END STATISTICS ###\n" >> "$temp_file"
    
    # Output the content
    cat "$temp_file"
    
    # Cleanup
    rm "$temp_file"
}

# Function to auto-paste to O3
auto_paste_to_o3() {
    # Check for macOS
    if [ "$(uname)" != "Darwin" ]; then
        echo "Error: Auto-paste only works on macOS"
        return 1
    fi
    
    # Attempt to find the O3 chrome app
    # This is a fallback if the o3r_collect_response.sh script doesn't exist
    osascript <<EOF
tell application "Google Chrome Dev" to activate
delay 1
tell application "System Events"
    keystroke "v" using command down
    delay 2
    key code 36  # Press Enter
end tell
EOF

    echo "Content pasted to O3"
}

# Main output handling
if [ -n "$output_file" ]; then
    generate_content > "$output_file"
    echo "Content saved to $output_file"
else
    # Try to use clipboard
    if command -v pbcopy > /dev/null; then
        generate_content | pbcopy
        echo "Content copied to clipboard (Mac)"
        
        if $auto_paste; then
            # Use the web app automation script
            echo "Opening O3 via web automation..."
            # Check if the script exists and is executable
            web_script="$(dirname "$0")/o3r_collect_response.sh"
            if [ -x "$web_script" ]; then
                "$web_script"
                
                # If auto-monitor is enabled, start monitoring
                if $auto_monitor; then
                    monitor_script="$(dirname "$0")/o3r_monitor_response.sh"
                    if [ -x "$monitor_script" ]; then
                        echo "Starting response monitoring..."
                        "$monitor_script" -i "$monitor_interval" -m "$monitor_maxtime"
                    else
                        echo "Monitoring not started. You can run it manually when ready."
                    fi
                else
                    echo "Monitoring not enabled. Run the following when ready:"
                    echo "$(dirname "$0")/o3r_monitor_response.sh"
                fi
            else
                echo "Warning: o3r_collect_response.sh not found or not executable"
                echo "Falling back to default auto_paste_to_o3 function"
                auto_paste_to_o3
            fi
        fi
    elif command -v xclip > /dev/null; then
        generate_content | xclip -selection clipboard
        echo "Content copied to clipboard (Linux)"
        $auto_paste && echo "Warning: Auto-paste not supported on Linux"
    else
        echo "Error: Install pbcopy (Mac) or xclip (Linux), or use -o"; exit 1
    fi
fi