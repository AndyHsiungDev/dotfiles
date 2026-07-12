-- LSP: basedpyright (type checking + code intelligence) and ruff (linting).
--
-- Neovim 0.11+ has a native LSP config API (vim.lsp.config / vim.lsp.enable).
-- nvim-lspconfig ships the base server definitions; Mason installs the
-- server binaries and mason-lspconfig auto-enables the ones it installs.
return {
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      { "williamboman/mason.nvim", opts = {} },
      "williamboman/mason-lspconfig.nvim",
    },
    config = function()
      -- Build client capabilities, extended by blink.cmp for completion.
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      local ok, blink = pcall(require, "blink.cmp")
      if ok then
        capabilities = blink.get_lsp_capabilities(capabilities)
      end
      vim.lsp.config("*", { capabilities = capabilities })

      -- basedpyright: default to "standard" (its out-of-the-box "recommended"
      -- mode is extremely strict and noisy for most codebases).
      vim.lsp.config("basedpyright", {
        settings = {
          basedpyright = {
            analysis = {
              typeCheckingMode = "standard",
              diagnosticMode = "openFilesOnly",
              autoImportCompletions = true,
            },
          },
        },
      })

      -- ruff: linting + code actions + import sorting. Let basedpyright own
      -- hover so the two servers don't produce duplicate popups.
      vim.lsp.config("ruff", {})

      -- Ensure the servers are installed, then enable them.
      require("mason-lspconfig").setup({
        ensure_installed = { "basedpyright", "ruff" },
        automatic_enable = true,
      })

      -- Per-buffer setup when any language server attaches to a buffer.
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("UserLspAttach", { clear = true }),
        callback = function(event)
          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if client and client.name == "ruff" then
            -- Defer hover to basedpyright.
            client.server_capabilities.hoverProvider = false
          end

          local map = function(keys, fn, desc)
            vim.keymap.set("n", keys, fn, { buffer = event.buf, desc = "LSP: " .. desc })
          end
          map("gd", vim.lsp.buf.definition, "Go to definition")
          map("gr", vim.lsp.buf.references, "List references")
          map("gi", vim.lsp.buf.implementation, "Go to implementation")
          map("K", vim.lsp.buf.hover, "Hover documentation")
          map("<leader>rn", vim.lsp.buf.rename, "Rename symbol")
          map("<leader>ca", vim.lsp.buf.code_action, "Code action")
          map("<leader>e", vim.diagnostic.open_float, "Line diagnostics")
          map("[d", function() vim.diagnostic.jump({ count = -1 }) end, "Prev diagnostic")
          map("]d", function() vim.diagnostic.jump({ count = 1 }) end, "Next diagnostic")
        end,
      })
    end,
  },
}
