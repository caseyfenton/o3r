# O3R: Unleash the Power of O3 for Code Refactoring

**O3R** (pronounced "o-three-r") is a powerful utility that unlocks the full potential of OpenAI's O3 model for code refactoring, enhancement, and development. This tool bridges the gap between limited-context coding assistants and O3's massive context window capabilities.

## 🚀 Why O3R Changes the Game

Most coding assistants suffer from limited context windows, making it difficult to work with large codebases. O3R solves this problem by:

- **Leveraging O3's 200K token context window** - Process entire modules or projects at once
- **Utilizing O3's 100K output token capacity** - Get comprehensive rewrites and refactors in one shot
- **Automating the entire workflow** - From code preparation to response collection
- **Maximizing value from ChatGPT subscriptions** - O3 web interface charges per query/response, not per token

## 💡 Use Cases

### Comprehensive Code Refactoring
Feed entire modules into O3 to:
- Modernize legacy codebases
- Apply consistent patterns across your project
- Convert between paradigms (e.g., OOP to functional)

### One-Shot Feature Implementation
Provide full context for more accurate feature additions:
- Add new functionality with complete understanding of your codebase
- Implement cross-cutting concerns correctly the first time
- Ensure new code follows existing patterns and conventions

### Deep Bug Fixing
Fix complex bugs that span multiple files:
- Include all relevant code paths in a single prompt
- Get fixes that address root causes, not just symptoms
- Debug issues that depend on interactions between components

### Code Quality Improvements
Enhance your entire codebase at once:
- Apply consistent formatting and style
- Improve performance bottlenecks
- Add proper error handling throughout
- Enhance documentation and type hints

## ✨ Features

- 🔄 **Smart Concatenation**: Combines source files with proper formatting and instructions
- 📎 **Clipboard Integration**: Automatically copies prepared content
- 🚀 **Auto-Paste**: Opens O3 web app and pastes your code (optional)
- 📊 **Response Monitoring**: Watches for when O3 completes its response (optional)
- 📋 **Response Collection**: Extracts code from O3's response for easy integration
- ⚙️ **Customizable Process**: Supports various file types and configurations

## 💰 Cost Efficiency

Using o3r with a ChatGPT subscription provides exceptional value:
- **Subscription-based pricing**: Pay a flat fee (e.g., $20/month) rather than per-token API costs
- **Unlimited queries**: Process large codebases without worrying about token costs
- **Avoid $1+ API charges**: A single large refactoring job via API could cost dollars per run

## 🔧 Installation

```bash
# Clone the repository
git clone https://github.com/caseyfenton/o3r.git
cd o3r

# Install globally
./install.sh
```

This will install the following commands:

- `o3r`: Main tool for preparing code for O3 refactoring
- `o3r-collect`: Tool for collecting responses from O3
- `o3r-monitor`: Tool for monitoring O3 for responses
- `o3r-run`: All-in-one background tool for the complete O3 workflow

## 📖 Usage

### Basic Usage

```bash
# Process all Python files in the current directory
o3r -d . -e py

# Process JavaScript and TypeScript files in the src directory
o3r -d ./src -e js,ts

# Process specific files listed in a text file
o3r -f my_files.txt
```

### Command Options Explained

The main command `o3r` takes the following options:

- `-d DIR` : **Directory** - Process all matching files in the specified directory (recursively)
- `-f FILE` : **File List** - Read list of files from the specified file
- `-e EXTS` : **Extensions** - Comma-separated list of file extensions to include (default: py,js,ts,go)
- `-o FILE` : **Output** - Write output to a file instead of clipboard
- `-p` : **Paste** - Auto-paste to O3 web app (Mac only)
- `-m` : **Monitor** - Auto-monitor for responses after submission (Mac only)
- `-i SECS` : **Interval** - Check interval for monitoring in seconds (default: 30)
- `-t SECS` : **Timeout** - Maximum wait time for monitoring in seconds (default: 300)

### Advanced Usage Examples

```bash
# Auto-paste to O3 web app
o3r -d ./src -e py -p

# Auto-paste AND monitor for responses
o3r -d ./src -e py -p -m

# Write output to a file instead of clipboard
o3r -d ./src -e py -o refactor_request.txt

# Set custom monitoring intervals (check every 10 seconds for 5 minutes)
o3r -d ./src -e py -p -m -i 10 -t 300

# Process multiple directories
o3r -d "src/core,tests" -e py

# Use with file list from standard input
echo -e "file1.py\nfile2.py" | o3r -f -
```

### Response Collection

Once your code has been processed by O3, you can collect the response using:

```bash
# Collect the full response from O3
o3r-collect collect

# Extract just the code blocks
o3r-collect code
```

## 🛠️ Customizing the Prompt

The default prompt instructs O3 to refactor code to be more vertically compressed and efficient while maintaining functionality. You can customize this prompt by editing the `o3r.sh` script:

1. Locate the `generate_content()` function in `/path/to/o3r/o3r.sh`
2. Find the section that begins with `### REFACTORING INSTRUCTIONS ###`
3. Modify these instructions to suit your specific needs

### Default Prompt

```markdown
### REFACTORING INSTRUCTIONS ###
Refactor this codebase to be more vertically compressed and efficient while maintaining functionality. Requirements:
1. Combine related functions, variables, and imports on single lines where logical
2. Use Python shorthand syntax (list/dict comprehensions, ternaries, etc.)
3. Merge similar logic and remove redundant code
4. CRITICAL: Preserve ALL literal strings exactly as-is, including:
   - Success messages
   - Error messages
   - API responses
   - Log messages
   - Test assertions
5. Preserve docstrings and comments that explain complex logic
6. Maintain the same imports, just organize them better
```

You can modify this prompt to request different refactoring styles, add features, fix bugs, or explain code.

### Example Alternative Prompts

#### Add Type Hints

```markdown
### REFACTORING INSTRUCTIONS ###
Add comprehensive type hints to this Python codebase while maintaining functionality:
1. Add appropriate type annotations to all function parameters and return values
2. Use typing module for complex types (List, Dict, Optional, etc.)
3. Preserve existing docstrings and extend them with type information
4. DO NOT change the logic or functionality of the code
```

#### Performance Optimization

```markdown
### REFACTORING INSTRUCTIONS ###
Optimize this codebase for better performance:
1. Identify and fix performance bottlenecks
2. Use more efficient algorithms and data structures where appropriate
3. Minimize redundant operations and memory usage
4. Add comments explaining the performance improvements
5. Maintain the same API and functionality
```

## 🚧 Future Plans

This project is actively evolving with several enhancements planned:

### AI-Assisted File Selection

We're working on integrating intelligent file selection to automatically identify the most relevant files for refactoring:

- Use AI to analyze project structure and determine entry points
- Identify core files and dependencies based on import graphs
- Prioritize files based on complexity and refactoring potential
- Optimize token usage by focusing on the most impactful files

### Enhanced Workflow Integration

- Integration with popular IDEs and editors
- Support for diff-based application of changes
- Automatic test running after refactoring
- Version control integration

### Additional Features

- Support for custom templates and prompt libraries
- Project configuration files for recurring refactoring tasks
- Expanded language support

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.
