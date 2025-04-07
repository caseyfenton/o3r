# O3R - O3 Refactoring Tool

A utility for preparing code for the O3 model to assist with refactoring. This tool combines source files with proper formatting and instructions for better results with the O3 model.

## Features

- 🔄 Concatenates source files with automatic formatting for the O3 model
- 📎 Copies prepared content to clipboard
- 🚀 Auto-pastes to the O3 web app (optional)
- 📊 Monitors for O3 responses (optional)
- 📋 Extracts code responses from O3

## Installation

```bash
# Clone the repository
git clone https://github.com/username/o3r.git
cd o3r

# Install globally
./install.sh
```

This will install the following commands to your system:

- `o3r`: Main tool for preparing code for O3 refactoring
- `o3r_collect_response`: Tool for collecting responses from O3
- `o3r_monitor_response`: Tool for monitoring O3 for responses
- `o3r_background`: All-in-one background tool for the complete O3 workflow

Commands are installed to both `~/bin` and `~/.local/bin` if they exist, ensuring they work the same way as other system tools.

## Usage

### Basic Usage

```bash
# Show help
o3r --help

# Process all JavaScript files in a directory
o3r -d ./src -e js

# Process specific files
o3r -f files.txt

# Save output to file instead of clipboard
o3r -d ./src -e js -o output.txt

# Auto-paste to O3 web app (optional)
o3r -d ./src -e js -p

# Auto-paste and monitor for responses
o3r -d ./src -e js -p -M

# Change check interval and max wait time for monitoring
o3r -d ./src -e js -p -M -i 60 -t 600
```

### O3 Model Automation Options

The toolkit provides multiple ways to interact with the O3 model, from modular step-by-step processes to a fully automated background workflow:

#### Option 1: All-in-one Background Process (Recommended)

The `o3r_background` command handles the entire O3 workflow in the background:

```bash
# Submit content from clipboard to O3 and monitor for response
o3r_background

# Submit content from file with custom check interval (60s) and timeout (1h)
o3r_background -f input.txt -i 60 -m 3600 -o response.txt
```

This background process:
1. Opens the O3 web app
2. Pastes content and sends it
3. Checks for responses at regular intervals
4. Saves the response to a file when ready
5. Provides progress updates during monitoring

#### Option 2: Step-by-Step Process

For more granular control, you can use the individual commands:

```bash
# Step 1: Prepare content using o3r tool
o3r -d ./src -e js -o content.txt

# Step 2: Submit to O3 (interactive)
o3r_collect_response submit -f content.txt

# Step 3: Monitor for response
o3r_monitor_response -i 30 -m 1800 -o response.txt

# Step 4: Collect response (if not using monitor)
o3r_collect_response collect
```

Both approaches provide the same functionality, but the all-in-one process is more convenient for most use cases.

### Advanced Usage

```bash
# Multiple directories
o3r -d "src/core,tests" -e js

# Use with file list
echo -e "file1.js\nfile2.js" | o3r -f -

# Pipe output to another command
o3r -d ./src -e js | your-command
```

## Chrome Web App Integration

The scripts now use Chrome web apps for better window management:

- Automatically detects installed O3 web app
- Looks for `/Users/casey/Applications/Chrome Apps.localized/ChatGPT-o3-mini-high.app`
- Supports keyboard shortcuts:
  - Cmd+Shift+C: Copy full response
  - Cmd+Shift+;: Extract only code blocks

### Response Monitoring

The new monitoring script checks for O3 responses:

```bash
# After submitting content with o3r -p
./o3r_monitor_response.sh

# With custom interval and timeout
./o3r_monitor_response.sh -i 30 -m 600

# Save response to file
./o3r_monitor_response.sh -o response.txt
```

## Scripts

- **o3r_concatenate.sh**: Main script for combining files
- **o3r_collect_response.sh**: Submits content to O3 web app
- **o3r_monitor_response.sh**: Monitors for O3 responses
- **install.sh**: Installs the command system-wide

## Requirements

- Mac or Linux
- For clipboard support:
  - Mac: pbcopy (built-in)
  - Linux: xclip
- For auto-paste feature (optional):
  - Mac only
  - O3 desktop app

## Contributing

Pull requests are welcome! Please make sure to update tests as appropriate.

## License

MIT
