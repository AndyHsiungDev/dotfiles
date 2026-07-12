-- Editor options
vim.opt.swapfile = false
vim.opt.number = true
vim.opt.expandtab = true
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.textwidth = 80
vim.opt.showmatch = true
vim.opt.clipboard = "unnamedplus"

-- Leader key (used by some LSP keymaps below). Set before plugins load.
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Bootstrap the plugin manager and load everything under lua/plugins/.
require("config.lazy")

-- Diagnostics UI: inline virtual text, signs in the gutter, and rounded borders.
vim.diagnostic.config({
  virtual_text = { prefix = "●" },
  signs = true,
  underline = true,
  update_in_insert = false,
  severity_sort = true,
  float = { border = "rounded", source = true },
})
