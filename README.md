# Dotfiles

Personal configuration files for various tools and applications.

## Contents

- **zsh** - Zsh shell configuration with oh-my-zsh, pyenv, nvm, and other tools
- **vim** - Vim editor configuration
- **nvim** - Neovim configuration (Lua)
- **hh** - Hstr (command history tool) configuration and installation scripts
- **raycast** - Raycast app configuration

## Usage

These dotfiles can be symlinked or copied to their respective locations in your home directory:

- `zsh/.zshrc` → `~/.zshrc`
- `vim/.vimrc` → `~/.vimrc`
- `nvim/` → `~/.config/nvim`
- `hh/` → `~/dotfiles/hh/` (then source the appropriate config file)

See individual directories for specific setup instructions.

## Neovim setup

The Neovim config manages its own plugins and language servers, so setup on a new
machine is largely automatic.

### Prerequisites

- **Neovim 0.11+** (uses the native `vim.lsp.config` / `vim.lsp.enable` API)
- **git** and **curl** - lazy.nvim and Mason clone/download over these
- **Node.js** - Mason installs `basedpyright` as an npm package

### Steps

1. Symlink the config into place:

   ```sh
   ln -s ~/projects/dotfiles/nvim ~/.config/nvim
   ```

2. Launch `nvim`. On first start it will:
   - bootstrap [lazy.nvim](https://github.com/folke/lazy.nvim) and install the plugins
     pinned in `nvim/lazy-lock.json`
   - use [Mason](https://github.com/williamboman/mason.nvim) to install the language
     servers listed in `ensure_installed` (`basedpyright` for type checking,
     `ruff` for linting) - watch progress with `:Mason`

3. Open a Python file to confirm the LSP attaches (`:LspInfo`).
