-- Autocompletion engine. blink.cmp ships a prebuilt fuzzy matcher, so there
-- is nothing to compile; the release tag downloads the right binary.
return {
  {
    "saghen/blink.cmp",
    version = "*",
    opts = {
      keymap = { preset = "default" }, -- <C-space> open, <C-y> accept, <C-n>/<C-p> navigate
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
