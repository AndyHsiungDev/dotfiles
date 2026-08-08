#!/bin/sh
# Marks the current WezTerm pane as "thinking" (agent actively working) for the
# wezterm-attention plugin. Runs from UserPromptSubmit (turn starts) and from
# PostToolUse (turn is still going), so the blue tab tint survives a permission
# prompt: Notification overwrites the marker with "notify", focusing the tab to
# approve deletes it, and without this re-arm the tab stays unhighlighted for the
# rest of the turn.
#
# Deliberately POSIX sh rather than node: PostToolUse fires on every tool call
# and a node cold start (~60ms) there would tax every turn. See write-marker.mjs
# for notify/stop/clear, which need stdin parsing and the audible cue.
#
# Keyed on $WEZTERM_PANE, which WezTerm injects into every pane's environment and
# Claude Code passes through to hook subprocesses. No-op outside WezTerm.
set -u

case "${WEZTERM_PANE-}" in
	'' | *[!0-9]*) exit 0 ;;
esac

dir="$HOME/.local/state/wezterm-attention"
file="$dir/$WEZTERM_PANE"

# Never clobber a manual "review" flag (ALT+b). The marker file holds a single
# state, so writing over it would silently drop the flag with no way to notice.
if grep -q '"review"' "$file" 2>/dev/null; then
	exit 0
fi

mkdir -p "$dir" || exit 0

# Atomic write: temp file + rename, so the plugin's poll never reads a partial
# marker. updated_at is milliseconds, matching write-marker.mjs.
printf '{"type":"thinking","updated_at":%s000}' "$(date +%s)" >"$file.tmp" &&
	mv -f "$file.tmp" "$file"
