# hh (hstr) Configuration

This directory contains installation and configuration files for [hstr](https://github.com/dvorka/hstr) (formerly known as hh), a command-line history tool for bash/zsh that provides interactive history search.

## Installation

Run the installation script:

```bash
./hh/install.sh
```

Or install manually:

- **macOS**: `brew install hstr`
- **Linux (Debian/Ubuntu)**: `sudo apt-get install hstr`
- **Linux (RHEL/CentOS)**: `sudo yum install hstr` or `sudo dnf install hstr`

## Configuration

### For zsh users:

Add to your `~/.zshrc`:

```bash
source ~/dotfiles/hh/zshrc
```

Or copy the contents of `hh/zshrc` directly into your `~/.zshrc`.

### For bash users:

Add to your `~/.bashrc`:

```bash
source ~/dotfiles/hh/bashrc
```

Or copy the contents of `hh/bashrc` directly into your `~/.bashrc`.

## Usage

After installation and configuration:

- Press **Ctrl+R** to open hstr interactive history search
- Use **hh** command directly: `hh`
- Navigate with arrow keys, search with typing, select with Enter

## Features

- Interactive history search with fuzzy matching
- Keywords, favorites, bookmarks
- Regexp support
- Blacklist for excluding commands
- Case-sensitive/insensitive search
- Color-coded interface

## Configuration File

The `.hstr` file contains detailed configuration options. You can customize colors, behavior, and other settings by editing this file.
