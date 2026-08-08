#!/bin/sh
# Installs the WezTerm Claude Code attention indicator on this machine:
#   1. symlinks wezterm.lua and the marker scripts back to this repo
#   2. merges hooks.json into ~/.claude/settings.json
#
# Idempotent - safe to re-run. settings.json is merged, never overwritten, since
# it also holds hooks unrelated to WezTerm; a timestamped backup is kept.
set -eu

REPO_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
WEZTERM_DIR=$(dirname -- "$REPO_DIR")
CLAUDE_DIR="$HOME/.claude/wezterm-attention"

link() {
	target=$1
	link_path=$2
	mkdir -p "$(dirname -- "$link_path")"
	if [ -L "$link_path" ] && [ "$(readlink "$link_path")" = "$target" ]; then
		echo "  ok       $link_path"
		return
	fi
	if [ -e "$link_path" ] && [ ! -L "$link_path" ]; then
		echo "  SKIPPED  $link_path already exists and is not a symlink - move it aside first" >&2
		return
	fi
	ln -sfn "$target" "$link_path"
	echo "  linked   $link_path -> $target"
}

echo "Symlinks:"
link "$WEZTERM_DIR/wezterm.lua" "$HOME/.config/wezterm/wezterm.lua"
link "$REPO_DIR/mark-thinking.sh" "$CLAUDE_DIR/mark-thinking.sh"
link "$REPO_DIR/write-marker.mjs" "$CLAUDE_DIR/write-marker.mjs"

chmod +x "$REPO_DIR/mark-thinking.sh" "$REPO_DIR/write-marker.mjs"

echo "Hooks:"
REPO_DIR="$REPO_DIR" python3 - <<'PY'
import json, os, shutil, time

repo = os.environ["REPO_DIR"]
home = os.path.expanduser("~")
settings_path = os.path.join(home, ".claude", "settings.json")

with open(os.path.join(repo, "hooks.json")) as f:
    # hooks.json keeps $HOME for portability; resolve it here rather than relying
    # on the hook command being expanded by a shell at run time.
    wanted = json.loads(f.read().replace("$HOME", home))

try:
    with open(settings_path) as f:
        settings = json.load(f)
except FileNotFoundError:
    settings = {}

hooks = settings.setdefault("hooks", {})
added = 0

for event, groups in wanted.items():
    existing = hooks.setdefault(event, [])
    for group in groups:
        for hook in group["hooks"]:
            already = any(
                h.get("command") == hook["command"]
                for g in existing
                for h in g.get("hooks", [])
            )
            if already:
                print(f"  ok       {event}")
                continue
            # Reuse a group with a compatible matcher so we don't fragment the
            # event into one group per hook.
            matcher = group.get("matcher")
            target = next(
                (g for g in existing if g.get("matcher") == matcher), None
            )
            if target is None:
                target = {k: v for k, v in group.items() if k != "hooks"}
                target["hooks"] = []
                existing.append(target)
            target.setdefault("hooks", []).append(hook)
            added += 1
            print(f"  added    {event}")

if added:
    if os.path.exists(settings_path):
        backup = f"{settings_path}.bak.{time.strftime('%Y%m%d%H%M%S')}"
        shutil.copy2(settings_path, backup)
        print(f"  backup   {backup}")
    os.makedirs(os.path.dirname(settings_path), exist_ok=True)
    with open(settings_path, "w") as f:
        json.dump(settings, f, indent=2)
        f.write("\n")
    print(f"  wrote    {settings_path} ({added} hook(s) added)")
else:
    print("  settings.json already up to date")
PY

echo
echo "Done. Restart running Claude Code sessions to pick up the hooks."
