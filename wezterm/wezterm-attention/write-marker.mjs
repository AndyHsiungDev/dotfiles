#!/usr/bin/env node
// Writes (or clears) a per-pane marker file that the wezterm-attention plugin
// reads to render an attention dot beside the WezTerm tab.
//   usage: write-marker.mjs <notify|stop|clear>
// Keyed on $WEZTERM_PANE, which WezTerm injects into every pane's environment
// and Claude Code passes through to hook subprocesses. No-op outside WezTerm.
import { mkdirSync, writeFileSync, renameSync, unlinkSync, readFileSync } from "node:fs";
import { spawn } from "node:child_process";

const state = process.argv[2];

// Claude Code fires the Notification hook both for genuine permission prompts and
// for the periodic idle "Claude is waiting for your input" reminder. The idle one
// re-fires on a timer whenever a session just sits at the prompt, lighting the tab
// yellow (and dinging) with nothing actually running. Read the hook payload from
// stdin and skip the idle reminder so notify only ever signals a real prompt.
if (state === "notify") {
	let message = "";
	try {
		message = (JSON.parse(readFileSync(0, "utf8")) || {}).message || "";
	} catch {}
	if (/waiting for your input/i.test(message)) {
		process.exit(0);
	}
}

// Audible cue when Claude is waiting on you (the "notify" state). Detached +
// unref'd so it outlives this short hook process and never blocks it. macOS only;
// fires regardless of WezTerm so you hear it from any terminal.
if (state === "notify" && process.platform === "darwin") {
	try {
		spawn("afplay", ["/System/Library/Sounds/Glass.aiff"], {
			detached: true,
			stdio: "ignore",
		}).unref();
	} catch {}
}

const pane = process.env.WEZTERM_PANE;
if (!pane || !/^\d+$/.test(pane)) {
	process.exit(0);
}

const dir = `${process.env.HOME}/.local/state/wezterm-attention`;
const file = `${dir}/${pane}`;

if (state === "clear") {
	try {
		unlinkSync(file);
	} catch {}
	process.exit(0);
}

// Atomic write: temp file + rename, so the plugin never reads a half-written marker.
mkdirSync(dir, { recursive: true });
writeFileSync(`${file}.tmp`, JSON.stringify({ type: state, updated_at: Date.now() }));
renameSync(`${file}.tmp`, file);
