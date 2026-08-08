# WezTerm Claude Code attention indicator

Tints a WezTerm tab by the state of the Claude Code session running in it, so a
wall of tabs tells you at a glance which one wants you. Rendering lives in
[`../wezterm.lua`](../wezterm.lua); this directory holds the pieces that live
outside the WezTerm config.

| State      | Colour                | Meaning                          |
| ---------- | --------------------- | -------------------------------- |
| `thinking` | Blue (muted)          | Agent is working                 |
| `notify`   | Yellow `#FBBC05`      | Needs your input + Glass sound   |
| `stop`     | Green `#34A853`       | Finished its turn                |
| `review`   | Red `#EA4335`         | Manually flagged with `ALT+b`    |

## How it works

The [`pro-vi/wezterm-attention`](https://github.com/pro-vi/wezterm-attention)
plugin reads one marker file per pane from `~/.local/state/wezterm-attention/`,
keyed on `$WEZTERM_PANE`. Claude Code hooks write those files; `wezterm.lua`
polls them 4x/sec and renders the tab. Terminal states (`stop`, `notify`) clear
when you focus the tab.

## Files

- **`mark-thinking.sh`** - writes the `thinking` marker. Wired to both
  `UserPromptSubmit` (turn starts) and `PostToolUse` (turn is still going).
  POSIX sh rather than node because `PostToolUse` fires on every tool call and a
  node cold start there would tax every turn.
- **`write-marker.mjs`** - writes `notify` / `stop` and clears on session end.
  Needs node: it parses the hook payload on stdin to drop Claude's periodic idle
  "waiting for your input" reminder (which would otherwise light the tab yellow
  and ding with nothing running), and plays the macOS Glass sound.
- **`hooks.json`** - the `~/.claude/settings.json` hook fragment. Reference copy,
  since `settings.json` itself is shared with unrelated hooks and so is not
  symlinked.
- **`install.sh`** - creates the symlinks and merges `hooks.json` into
  `settings.json`.

## Why `PostToolUse` matters

`thinking` used to be written only at `UserPromptSubmit`, which left a hole: when
Claude asks permission mid-turn, `Notification` overwrites the marker with
`notify`, and focusing the tab to approve **deletes** it. Nothing then re-armed
`thinking`, so an actively working tab sat unhighlighted for the rest of the turn
- and long turns also hit the plugin's 30-minute `stale_after_ms` expiry, since
nothing refreshed the timestamp. Re-arming on `PostToolUse` closes both.

`mark-thinking.sh` will not overwrite a `review` marker: the file holds a single
state, so writing over it would silently drop an `ALT+b` flag.

## Setup

```sh
./install.sh
```

Creates these symlinks (idempotent, and it refuses to clobber a real file):

- `wezterm/wezterm.lua` → `~/.config/wezterm/wezterm.lua`
- `wezterm-attention/mark-thinking.sh` → `~/.claude/wezterm-attention/mark-thinking.sh`
- `wezterm-attention/write-marker.mjs` → `~/.claude/wezterm-attention/write-marker.mjs`

then merges `hooks.json` into `~/.claude/settings.json`, preserving anything
already there and backing the file up first.

Restart running Claude Code sessions afterwards - they read hooks at startup.

### Requirements

- **Node.js** - for `write-marker.mjs`
- **macOS** for the Glass sound; everything else is cross-platform

## Debugging

The marker files are the whole state, so read them directly:

```sh
for f in ~/.local/state/wezterm-attention/*; do echo "$f: $(cat "$f")"; done
```

Map a pane ID back to its tab with `wezterm cli list`. A tab with a spinner in
its title but no marker file means a hook did not fire (or its marker was
cleared) - check that `$WEZTERM_PANE` is set in that pane, since every script
here no-ops without it.
