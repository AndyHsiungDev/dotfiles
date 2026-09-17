-- Autocompletion engine. blink.cmp ships a prebuilt fuzzy matcher, so there
-- is nothing to compile; the release tag downloads the right binary.
return {
  {
    "saghen/blink.cmp",
    version = "*",
    opts = {
      -- <Tab> accepts the highlighted item, jumps to the next placeholder while
      -- a snippet is active, and indents when the menu is closed. <C-space>
      -- opens, <C-y> also accepts, <C-n>/<C-p> navigate, <C-e> cancels.
      keymap = {
        preset = "super-tab",
        ["<C-y>"] = { "select_and_accept", "fallback" },
      },
      appearance = { nerd_font_variant = "mono" },
      completion = {
        documentation = { auto_show = true, auto_show_delay_ms = 250 },
      },
      sources = {
        default = { "lsp", "path", "snippets", "buffer" },
      },
      fuzzy = { implementation = "prefer_rust_with_warning" },
    },
  },
}
