-- Git decorations in the sign column (added/changed/removed lines) plus
-- blame and hunk navigation. Loads lazily on file open.
return {
  {
    "lewis6991/gitsigns.nvim",
    event = "BufReadPre",
    keys = {
      { "<leader>gb", "<cmd>Gitsigns blame_line<cr>", desc = "Git Blame Line" },
      { "<leader>gB", "<cmd>Gitsigns toggle_current_line_blame<cr>", desc = "Toggle Inline Blame" },
      { "<leader>gp", "<cmd>Gitsigns preview_hunk<cr>", desc = "Preview Hunk" },
      { "]c", "<cmd>Gitsigns next_hunk<cr>", desc = "Next Hunk" },
      { "[c", "<cmd>Gitsigns prev_hunk<cr>", desc = "Prev Hunk" },
    },
    opts = {
      current_line_blame = false,
    },
  },
}
