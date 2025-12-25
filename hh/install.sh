#!/bin/bash

# Install hstr (hh) - History Suggest Box
# https://github.com/dvorka/hstr

set -e

echo "Installing hstr (hh)..."

# Detect OS
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS - use Homebrew
    if command -v brew &> /dev/null; then
        echo "Installing hstr via Homebrew..."
        brew install hstr
    else
        echo "Error: Homebrew not found. Please install Homebrew first:"
        echo "  /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
        exit 1
    fi
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # Linux - try different package managers
    if command -v apt-get &> /dev/null; then
        echo "Installing hstr via apt-get..."
        sudo apt-get update
        sudo apt-get install -y hstr
    elif command -v yum &> /dev/null; then
        echo "Installing hstr via yum..."
        sudo yum install -y hstr
    elif command -v dnf &> /dev/null; then
        echo "Installing hstr via dnf..."
        sudo dnf install -y hstr
    else
        echo "Error: No supported package manager found (apt-get, yum, or dnf)"
        exit 1
    fi
else
    echo "Error: Unsupported OS: $OSTYPE"
    exit 1
fi

# Configure hstr
echo "Configuring hstr..."
hstr --show-configuration >> ~/.zshrc 2>/dev/null || hstr --show-configuration >> ~/.bashrc 2>/dev/null || echo "Warning: Could not auto-configure shell. Please run 'hstr --show-configuration' and add to your shell config."

echo "hstr (hh) installation complete!"
echo "Restart your shell or run: source ~/.zshrc (or ~/.bashrc)"
