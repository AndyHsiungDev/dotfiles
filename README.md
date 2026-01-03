# Dotfiles

Personal dotfiles repository containing configuration files for various tools and shells.

## Table of Contents

- [Overview](#overview)
- [Quick Start](#quick-start)
- [Repository Structure](#repository-structure)
- [Installation](#installation)
  - [zsh Configuration](#zsh-configuration)
  - [vim Configuration](#vim-configuration)
  - [hstr (hh) Configuration](#hstr-hh-configuration)
  - [Raycast Configuration](#raycast-configuration)
- [Customization](#customization)
- [Maintenance](#maintenance)
- [License](#license)
- [Contributing](#contributing)

## Overview

This repository contains configuration files for:
- **zsh** - Shell configuration with oh-my-zsh, pyenv, nvm, and other tools
- **vim** - Vim editor configuration
- **hstr (hh)** - Interactive command history tool
- **Raycast** - macOS productivity app configuration

## Quick Start

1. Clone this repository:
   ```bash
   git clone <repository-url> ~/dotfiles
   cd ~/dotfiles
   ```

2. Set up symlinks for your configurations:
   ```bash
   # zsh
   ln -s ~/dotfiles/zsh/.zshrc ~/.zshrc
   
   # vim
   ln -s ~/dotfiles/vim/.vimrc ~/.vimrc
   ```

3. Install oh-my-zsh (if not already installed):
   ```bash
   sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
   ```

4. Reload your shell:
   ```bash
   source ~/.zshrc
   ```

## Repository Structure

```
.
├── zsh/
│   └── .zshrc          # zsh configuration with oh-my-zsh, pyenv, nvm, etc.
├── vim/
│   └── .vimrc          # Vim editor configuration
├── hh/
│   ├── .hstr           # hstr configuration file
│   ├── .hstr_favorites # hstr favorites
│   ├── zshrc           # hstr configuration for zsh
│   ├── bashrc          # hstr configuration for bash
│   ├── install.sh      # Installation script for hstr
│   └── README.md       # hstr-specific documentation
├── raycast/
│   └── .rayconfig      # Raycast configuration
└── README.md           # This file
```

## Installation

### Quick Setup

1. Clone this repository:
   ```bash
   git clone <repository-url> ~/dotfiles
   cd ~/dotfiles
   ```

2. Set up symlinks or copy files to your home directory:
   ```bash
   # zsh
   ln -s ~/dotfiles/zsh/.zshrc ~/.zshrc
   
   # vim
   ln -s ~/dotfiles/vim/.vimrc ~/.vimrc
   
   # hstr (if using)
   source ~/dotfiles/hh/zshrc  # or bashrc for bash users
   ```

### zsh Configuration

The zsh configuration includes:
- **oh-my-zsh** with the `robbyrussell` theme
- Plugins: `git`, `vi-mode`
- **pyenv** for Python version management
- **nvm** for Node.js version management
- **hstr** integration for command history (bound to `Ctrl+R`)
- Various PATH configurations for:
  - Yarn global packages
  - Google Cloud SDK
  - Dart SDK
  - PostgreSQL (via Homebrew)
  - Custom local binaries

**Prerequisites:**
- [oh-my-zsh](https://ohmyz.sh/) installed
- pyenv (optional, for Python version management)
- nvm (optional, for Node.js version management)

**Setup:**
```bash
# Install oh-my-zsh if not already installed
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Link or copy the zshrc
ln -s ~/dotfiles/zsh/.zshrc ~/.zshrc

# Reload shell
source ~/.zshrc
```

### vim Configuration

The vim configuration includes:
- Syntax highlighting and filetype detection
- Line numbers
- Tab settings (4 spaces, expand tabs to spaces)
- Clipboard integration (system clipboard support)
- Search highlighting
- Auto-indentation
- Text width limit (80 characters)
- No swap files or backups

**Setup:**
```bash
ln -s ~/dotfiles/vim/.vimrc ~/.vimrc
```

**Note:** The configuration uses `clipboard^=unnamedplus,unnamed` for clipboard integration, which works on macOS and Linux systems with appropriate vim builds.

### hstr (hh) Configuration

[hstr](https://github.com/dvorka/hstr) is an interactive command history tool that provides better history search than the default shell history.

**Installation:**
```bash
# Run the installation script
./hh/install.sh

# Or install manually
# macOS:
brew install hstr

# Linux (Debian/Ubuntu):
sudo apt-get install hstr
```

**Configuration:**
- For zsh: Add `source ~/dotfiles/hh/zshrc` to your `~/.zshrc`
- For bash: Add `source ~/dotfiles/hh/bashrc` to your `~/.bashrc`

**Usage:**
- Press `Ctrl+R` to open hstr interactive history search
- Use `hh` command directly
- Navigate with arrow keys, search by typing, select with Enter

See `hh/README.md` for more details.

### Raycast Configuration

Raycast configuration is stored in `raycast/.rayconfig`. This file contains your Raycast app settings and preferences.

**Setup:**
```bash
# Copy the configuration (adjust path as needed)
cp ~/dotfiles/raycast/.rayconfig ~/.rayconfig
```

## Customization

Feel free to customize these configurations to suit your needs:

- **zsh**: Edit `zsh/.zshrc` to change themes, plugins, or add custom aliases
- **vim**: Edit `vim/.vimrc` to adjust editor settings
- **hstr**: Edit `hh/.hstr` to customize hstr behavior and colors

## Maintenance

To keep your dotfiles in sync:

```bash
# Add changes
git add .
git commit -m "Update configuration"

# Push to remote
git push
```

### Updating Individual Configurations

After making changes to configuration files, reload them:

- **zsh**: `source ~/.zshrc` or restart your terminal
- **vim**: Changes take effect on next vim launch
- **hstr**: Restart your shell or run `source ~/.zshrc`

## License

This repository contains personal configuration files. Feel free to use and modify as needed.

## Contributing

This is a personal dotfiles repository, but suggestions and improvements are welcome!
