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

### Advanced Usage

```bash
# Auto-paste to O3 web app
o3r -d ./src -e py -p

# Auto-paste AND monitor for responses
o3r -d ./src -e py -p -m

# Write output to a file instead of clipboard
o3r -d ./src -e py -o refactor_request.txt

# Set custom monitoring intervals (check every 10 seconds for 5 minutes)
o3r -d ./src -e py -p -m -i 10 -t 300
```

### Collecting Responses

```bash
# Collect the full response from O3
o3r-collect collect

# Extract just the code blocks
o3r-collect code
```

### Complete Workflow in Background

```bash
# Run the entire process in the background
o3r-run -d ./src -e py
```

## 🔄 Workflow

1. **Prepare**: o3r combines your source files with proper formatting
2. **Submit**: The tool copies to clipboard or auto-pastes to O3
3. **Process**: O3 processes your entire codebase at once
4. **Collect**: o3r extracts the response when ready
5. **Integrate**: Apply O3's suggestions to your project

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.
