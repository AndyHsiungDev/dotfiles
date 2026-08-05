# WezTerm config

Personal WezTerm setup. Highlights of the customizations in `wezterm.lua`:

## Claude Code attention indicator
- Shows a colored `●` + tinted background on a tab, by the state of the Claude Code session in it.
- Colors (Google Material), by state:
  - **Blue** `#4285F4` (muted) - Claude is working
  - **Yellow** `#FBBC05` (black text) - Claude needs your input
  - **Green** `#34A853` - Claude finished its turn
  - **Red** `#EA4335` - manually flagged with `ALT+b`
- Plays the macOS **Glass** sound when Claude needs input.
- Yellow and green **clear automatically** when you focus that tab.
- Powered by the [`pro-vi/wezterm-attention`](https://github.com/pro-vi/wezterm-attention) plugin in `manual` renderer mode.
- Polls markers ~4x/sec (`status_update_interval = 250`) so the tab keeps up with the sound.
- Depends on Claude Code hooks and marker scripts - see [`wezterm-attention/`](wezterm-attention/)
  for those files, the setup script, and why the "working" state needs a `PostToolUse` hook.

## Other tweaks
- Auto light/dark color scheme (iTerm "Default" palette).
- Startup splits the window into two panes side by side.
- Custom `CMD` keybindings (still shown even with the tab indicator) - press **`CMD+/`** for a searchable cheat-sheet.
- `CMD+e` renames a tab; custom names are preserved by the tab indicator.
- macOS: translucent background with blur.
