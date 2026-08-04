# WezTerm config

Personal WezTerm setup. Highlights of the customizations in `wezterm.lua`:

## Claude Code attention indicator
- Shows a colored `●` + tinted background on a tab when a Claude Code session in it needs attention.
- Colors (Google Material), by state:
  - **Yellow** `#FBBC05` (black text) - Claude needs your input
  - **Green** `#34A853` - Claude finished its turn
  - **Blue** `#4285F4` - working (only if a `PreToolUse` hook is added)
  - **Red** `#EA4335` - manually flagged with `ALT+b`
- Plays the macOS **Hero** sound when Claude needs input.
- The dot **clears automatically** when you focus that tab.
- Powered by the [`pro-vi/wezterm-attention`](https://github.com/pro-vi/wezterm-attention) plugin in `manual` renderer mode.
- Depends on hooks in `~/.claude/settings.json` that run `~/.claude/wezterm-attention/write-marker.mjs` (writes/removes a per-pane marker file the plugin reads).
- Polls markers ~4x/sec (`status_update_interval = 250`) so the tab keeps up with the sound.

## Other tweaks
- Auto light/dark color scheme (iTerm "Default" palette).
- Startup splits the window into two panes side by side.
- Custom `CMD` keybindings (still shown even with the tab indicator) - press **`CMD+/`** for a searchable cheat-sheet.
- `CMD+e` renames a tab; custom names are preserved by the tab indicator.
- macOS: translucent background with blur.
