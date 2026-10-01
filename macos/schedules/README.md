# schedules

A small CLI for keeping track of personal `launchd` scheduled jobs on macOS -
what exists, what's active, when each one next fires, and which ones are failing.

```
  NAME                  SCHEDULE     STATUS  NEXT RUN   LAST RUN  RUNS  EXIT
  --------------------  -----------  ------  ---------  --------  ----  ----
  claude-daily-summary  daily 09:00  active  in 23h46m  13m ago   1     0
  weekly-cleanup        Sun 03:00    active  in 2d 17h  6d ago    4     0

  2 schedule(s): 2 active
```

## Install

```sh
macos/schedules/install.sh
```

Symlinks `schedules` into `~/.local/bin` and creates `~/.claude/scripts` and
`~/.claude/logs`. Idempotent. It installs no jobs of its own - those are personal
and machine-specific, so add them with `template.plist` as below.

Requires `/usr/bin/python3` (Xcode Command Line Tools) and `~/.local/bin` on
`PATH`; the installer checks both and tells you what's missing.

## Commands

```sh
schedules                    # the table above
schedules --all              # include vendor agents (Homebrew etc.) you don't own
schedules status <name>      # plist path, command, next fire time, exit history
schedules logs <name> [-f]   # tail stdout + stderr together
schedules run <name>         # trigger now, off-schedule
schedules disable <name>     # unload; plist stays on disk
schedules enable <name>
schedules reload <name>      # after editing a plist - launchd won't notice otherwise
```

`<name>` accepts either the short form (`weekly-cleanup`) or the full label
(`com.andy.weekly-cleanup`).

### Status values

| Value      | Meaning                              |
| ---------- | ------------------------------------ |
| `active`   | loaded, and last run exited cleanly  |
| `disabled` | plist on disk but not loaded         |
| `RUNNING`  | executing right now                  |
| `failing`  | last run exited non-zero             |

`NEXT RUN` is computed from the plist rather than asked of `launchd`, so weekly
and day-of-month schedules are handled, not just daily.

## The convention

Three rules make the inventory answerable:

1. **`com.andy.` prefix** on every job you own, so yours are distinguishable from
   vendor agents like `homebrew.mxcl.mysql`. Set `SCHEDULES_PREFIX` to change it.
2. **Script at `~/.claude/scripts/<name>/run.sh`**, plist at
   `~/Library/LaunchAgents/com.andy.<name>.plist`. The plist stays a thin
   scheduling shim; logic lives in the script, where it can be run by hand.
3. **Always set `StandardOutPath` / `StandardErrorPath`** to
   `~/.claude/logs/<name>.{out,err}.log`. `launchd` keeps no output of its own, so
   a job without these fails silently.

There is no registry file to maintain - `schedules` reads the plists themselves
as the source of truth, so a new job shows up as soon as it's bootstrapped.

## Adding a job

```sh
mkdir -p ~/.claude/scripts/myjob
$EDITOR ~/.claude/scripts/myjob/run.sh    # and chmod +x it
sed 's/__NAME__/myjob/g' macos/schedules/template.plist \
    > ~/Library/LaunchAgents/com.andy.myjob.plist
launchctl bootstrap gui/$(id -u) ~/Library/LaunchAgents/com.andy.myjob.plist
schedules run myjob                       # verify before trusting the schedule
```

Two things worth knowing when writing `run.sh`:

- **`launchd` gives jobs a bare `PATH`** of `/usr/bin:/bin:/usr/sbin:/sbin`.
  Anything in `/usr/local/bin` or `/opt/homebrew/bin` won't be found unless the
  script exports its own `PATH`. Prefer that over a login shell (`bash -lc`),
  which drags in unrelated profile output.
- **`RUNS` resets on reload.** `launchd` counts per-load, not forever, so
  `LAST RUN` (taken from log mtime) is the more trustworthy "did this fire" signal.

## Implementation note

`schedules` targets `/usr/bin/python3` deliberately rather than `python3` - a
`python3` on `PATH` is often a pyenv/asdf shim that breaks when the active version
changes, which is a bad property for a tool whose job is reporting breakage.
