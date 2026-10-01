# Dotfiles

Personal configuration files for various tools and applications.

## Contents

- **zsh** - Zsh shell configuration with oh-my-zsh, pyenv, nvm, and other tools
- **vim** - Vim editor configuration
- **nvim** - Neovim configuration (Lua)
- **wezterm** - WezTerm terminal configuration, incl. the Claude Code tab attention indicator
- **hh** - Hstr (command history tool) configuration and installation scripts
- **raycast** - Raycast app configuration
- **macos/schedules** - `schedules` CLI for managing personal launchd scheduled jobs

## Usage

These dotfiles can be symlinked or copied to their respective locations in your home directory:

- `zsh/.zshrc` → `~/.zshrc`
- `vim/.vimrc` → `~/.vimrc`
- `nvim/` → `~/.config/nvim`
- `wezterm/wezterm.lua` → `~/.config/wezterm/wezterm.lua` (or run `wezterm/wezterm-attention/install.sh`)
- `hh/` → `~/dotfiles/hh/` (then source the appropriate config file)
- `macos/schedules/schedules` → `~/.local/bin/schedules` (or run `macos/schedules/install.sh`)

See individual directories for specific setup instructions.

## Neovim setup

The Neovim config manages its own plugins and language servers, so setup on a new
machine is largely automatic.

### Prerequisites

- **Neovim 0.11+** (uses the native `vim.lsp.config` / `vim.lsp.enable` API)
- **git** and **curl** - lazy.nvim and Mason clone/download over these
- **Python 3** - Mason installs `pyrefly` and `ruff` as pip packages into virtualenvs

### Steps

1. Symlink the config into place:

   ```sh
   ln -s ~/projects/dotfiles/nvim ~/.config/nvim
   ```

2. Launch `nvim`. On first start it will:
   - bootstrap [lazy.nvim](https://github.com/folke/lazy.nvim) and install the plugins
     pinned in `nvim/lazy-lock.json`
   - use [Mason](https://github.com/williamboman/mason.nvim) to install the language
     servers listed in `ensure_installed` (`pyrefly` for type checking,
     `ruff` for linting) - watch progress with `:Mason`

3. Open a Python file to confirm the LSP attaches (`:LspInfo`).
