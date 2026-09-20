-- Copy "relative/path:line" (or "relative/path:start-end" for a visual
-- selection) to the system clipboard, so it can be pasted as an @-reference
-- into an adjacent Claude Code pane (e.g. in wezterm).
local function yank_ref(is_visual)
  local file = vim.fn.expand("%:.")
  local line1, line2
  if is_visual then
    line1 = vim.fn.line("'<")
    line2 = vim.fn.line("'>")
  else
    line1 = vim.fn.line(".")
    line2 = line1
  end

  local ref = line1 == line2
    and string.format("%s:%d", file, line1)
    or string.format("%s:%d-%d", file, line1, line2)

  vim.fn.setreg("+", ref)
  vim.notify("Copied " .. ref, vim.log.levels.INFO, { title = "Yank Ref" })
end

vim.keymap.set("n", "<leader>yl", function()
  yank_ref(false)
end, { desc = "Yank file:line ref" })

vim.keymap.set("v", "<leader>yl", function()
  yank_ref(true)
end, { desc = "Yank file:line ref" })

-- IDE-style comment toggle. Neovim has commenting built in as the `gc` operator
-- (`gcc` for the current line, `gc{motion}`, `gc` over a visual selection); these
-- mappings just put it on the CMD+/ chord muscle memory expects.
--
-- A terminal cannot transmit CMD, so wezterm translates CMD+/ into CTRL+/. That
-- arrives as <C-_> in legacy encoding and as <C-/> under the kitty keyboard
-- protocol, so both are bound.
for _, lhs in ipairs({ "<C-_>", "<C-/>" }) do
  vim.keymap.set("n", lhs, "gcc", { remap = true, desc = "Toggle comment line" })
  vim.keymap.set("x", lhs, "gc", { remap = true, desc = "Toggle comment selection" })
  vim.keymap.set("i", lhs, "<C-o>gcc", { remap = true, desc = "Toggle comment line" })
end

-- Disable the arrow keys in normal, visual, select and operator-pending modes,
-- so movement goes through hjkl. Insert mode is left alone.
for _, lhs in ipairs({ "<Up>", "<Down>", "<Left>", "<Right>" }) do
  vim.keymap.set("", lhs, "<Nop>", { desc = "Disabled: use hjkl" })
end

-- Delete into the black hole register, leaving the clipboard untouched. Takes a
-- motion in normal mode (<leader>dw, <leader>d$) and operates on the selection
-- in visual mode.
vim.keymap.set({ "n", "x" }, "<leader>d", '"_d', { desc = "Delete (no yank)" })

-- Replace the selection with the clipboard contents without the overwritten
-- text displacing them.
vim.keymap.set("x", "<leader>p", '"_dP', { desc = "Paste over (keep clipboard)" })
