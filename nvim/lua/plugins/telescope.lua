-- Fuzzy finder over files, buffers, grep, and more. plenary.nvim is a required
-- Lua utility dependency. Loads lazily on its keymaps.
return {
  {
    "nvim-telescope/telescope.nvim",
    branch = "0.1.x",
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find Files" },
      { "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Live Grep" },
      { "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "Buffers" },
      { "<leader>fh", "<cmd>Telescope help_tags<cr>", desc = "Help Tags" },
      { "<leader>fr", "<cmd>Telescope oldfiles<cr>", desc = "Recent Files" },
      { "<leader>fd", "<cmd>Telescope diagnostics<cr>", desc = "Diagnostics" },
    },
    opts = {
      defaults = {
        file_ignore_patterns = {
          "__pycache__",
          "%.pyc",
        },
      },
      pickers = {
        -- <C-d> isn't bound to anything in the buffers picker by default
        -- (globally it scrolls the preview), so bind it here to close
        -- the selected buffer without leaving the picker.
        buffers = {
          mappings = {
            i = { ["<C-d>"] = require("telescope.actions").delete_buffer },
            n = { ["<C-d>"] = require("telescope.actions").delete_buffer },
          },
        },
      },
    },
  },
}
