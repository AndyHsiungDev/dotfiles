#!/bin/sh
# Installs the `schedules` launchd manager on this machine:
#   1. symlinks `schedules` into ~/.local/bin
#   2. creates the ~/.claude/scripts and ~/.claude/logs directories jobs write to
#
# Idempotent - safe to re-run. Installs no scheduled jobs of its own; see
# README.md for adding one with template.plist.
set -eu

REPO_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
BIN_DIR="$HOME/.local/bin"

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

case "$(uname -s)" in
	Darwin) ;;
	*) echo "Error: schedules manages launchd and is macOS-only." >&2; exit 1 ;;
esac

if [ ! -x /usr/bin/python3 ]; then
	echo "Error: /usr/bin/python3 not found. Install the Xcode Command Line Tools:" >&2
	echo "  xcode-select --install" >&2
	exit 1
fi

chmod +x "$REPO_DIR/schedules"

echo "Symlinks:"
link "$REPO_DIR/schedules" "$BIN_DIR/schedules"

echo "Directories:"
for dir in "$HOME/.claude/scripts" "$HOME/.claude/logs"; do
	mkdir -p "$dir"
	echo "  ok       $dir"
done

echo
case ":${PATH}:" in
	*:"$BIN_DIR":*)
		echo "Done. Run 'schedules' to list your jobs."
		;;
	*)
		echo "Done, but $BIN_DIR is not on your PATH. Add this to ~/.zshrc:"
		echo
		echo "  export PATH=\"\$HOME/.local/bin:\$PATH\""
		;;
esac
