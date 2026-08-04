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
