local wezterm = require("wezterm")

local config = wezterm.config_builder()

local is_windows = os.getenv("OS") and os.getenv("OS"):lower():find("windows")
local is_macos = wezterm.target_triple:lower():find("darwin") ~= nil

wezterm.on("gui-startup", function(cmd)
  local tab, pane, window = wezterm.mux.spawn_window(cmd or {})
  pane:split({ direction = "Right" })
end)

-- iTerm "Default" profile equivalent: shared ANSI palette, auto light/dark switch
local ansi = {
  "#14191e", -- black
  "#b43c2a", -- red
  "#00c200", -- green
  "#c7c400", -- yellow
  "#2744c7", -- blue
  "#c040be", -- magenta
  "#00c5c7", -- cyan
  "#c7c7c7", -- white
}
local brights = {
  "#686868", -- bright black
  "#dd7975", -- bright red
  "#58e790", -- bright green
  "#ece100", -- bright yellow
  "#a7abf2", -- bright blue
  "#e17ee1", -- bright magenta
  "#60fdff", -- bright cyan
  "#ffffff", -- bright white
}

config.color_schemes = {
  ["iTermDefault Dark"] = {
    foreground = "#dcdcdc",
    background = "#15191f",
    cursor_bg = "#ffffff",
    cursor_fg = "#000000",
    cursor_border = "#ffffff",
    selection_bg = "#b3d7ff",
    selection_fg = "#101010",
    ansi = ansi,
    brights = brights,
  },
  ["iTermDefault Light"] = {
    foreground = "#101010",
    background = "#fafafa",
    cursor_bg = "#000000",
    cursor_fg = "#ffffff",
    cursor_border = "#000000",
    selection_bg = "#b3d7ff",
    selection_fg = "#101010",
    ansi = ansi,
    brights = brights,
  },
}

local function scheme_for_appearance(appearance)
  if appearance:find("Dark") then
    return "iTermDefault Dark"
  end
  return "iTermDefault Light"
end

wezterm.on("window-config-reloaded", function(window)
  local overrides = window:get_config_overrides() or {}
  local scheme = scheme_for_appearance(window:get_appearance())
  if overrides.color_scheme ~= scheme then
    overrides.color_scheme = scheme
    window:set_config_overrides(overrides)
  end
end)

config.color_scheme = scheme_for_appearance(wezterm.gui and wezterm.gui.get_appearance() or "Dark")
config.max_fps = 120
config.font = wezterm.font("JetBrains Mono")
config.window_decorations = "INTEGRATED_BUTTONS|RESIZE"
config.window_frame = {
  font = wezterm.font("JetBrains Mono"),
}
config.inactive_pane_hsb = {
  saturation = 0.0,
  brightness = 0.5,
}
-- Single source of truth for custom key bindings. Each entry has a `desc`
-- so the cheat-sheet (CMD+/) stays in sync automatically.
local key_bindings = {
  {
    key = "t",
    mods = "CMD",
    desc = "New tab",
    action = wezterm.action.SpawnTab("CurrentPaneDomain"),
  },
  {
    key = "s",
    mods = "CMD",
    desc = "Select pane",
    action = wezterm.action.PaneSelect,
  },
  {
    key = "d",
    mods = "CMD",
    desc = "Split pane horizontally",
    action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" }),
  },
  {
    key = "d",
    mods = "CMD|SHIFT",
    desc = "Split pane vertically",
    action = wezterm.action.SplitVertical({ domain = "CurrentPaneDomain" }),
  },
  {
    key = "w",
    mods = "CMD",
    desc = "Close current pane",
    action = wezterm.action.CloseCurrentPane({ confirm = true }),
  },
  {
    key = "p",
    mods = "CMD",
    desc = "Activate next pane",
    action = wezterm.action.ActivatePaneDirection("Next"),
  },
  {
    key = "e",
    mods = "CMD",
    desc = "Rename current tab",
    action = wezterm.action.PromptInputLine({
      description = "Enter new name for tab",
      action = wezterm.action_callback(function(window, pane, line)
        if line then
          window:active_tab():set_title(line)
        end
      end),
    }),
  },
}

-- Build a searchable cheat-sheet from the bindings above. Selecting an entry
-- runs its action; type to fuzzy-filter, Esc to dismiss.
local function keymap_cheatsheet()
  local choices = {}
  for _, b in ipairs(key_bindings) do
    table.insert(choices, {
      id = tostring(#choices + 1),
      label = string.format("%-14s  %s", b.mods .. "+" .. b.key, b.desc),
    })
  end
  return wezterm.action.InputSelector({
    title = "Keybindings",
    fuzzy = true,
    choices = choices,
    action = wezterm.action_callback(function(window, pane, id)
      if id then
        window:perform_action(key_bindings[tonumber(id)].action, pane)
      end
    end),
  })
end

config.keys = key_bindings
table.insert(config.keys, {
  key = "/",
  mods = "CMD",
  action = keymap_cheatsheet(),
})

-- Claude Code attention dot: tints a tab by the state of its Claude session
-- (working, needs input, or finished its turn) and marks it with a ●. Driven by
-- per-pane marker files that the hooks in ~/.claude/settings.json write:
-- UserPromptSubmit and PostToolUse mark "thinking", Notification "notify", Stop
-- "stop", SessionEnd clears. PostToolUse is what keeps a tab blue for the rest of
-- a turn after a permission prompt - the notify marker is deleted when you focus
-- the tab to approve, and nothing else would re-arm "thinking".
-- Terminal states auto-clear when the tab is focused. See
-- github.com/pro-vi/wezterm-attention.
-- Marker plugin runs in "manual" renderer mode so we own the tab-title rendering:
-- the plugin's built-in renderer only tints the tab background, but we want a
-- readable foreground per state too. The plugin still polls the per-pane marker
-- files that the Claude hooks write, and exposes get_attention/remove_marker.
local attention = wezterm.plugin.require("https://github.com/pro-vi/wezterm-attention")
attention.apply_to_config(config, { renderer = "manual" })

-- The plugin re-reads marker files on update-status, which fires every
-- status_update_interval ms (default 1000). The attention sound is instant, so at
-- the default the tab lags the sound by up to ~1s; poll ~4x/sec to keep them tight.
config.status_update_interval = 250

-- Google Material palette per attention state: { bg tint, readable fg }.
local ATTENTION_STYLE = {
  thinking = { bg = "rgba(66,133,244,0.28)", fg = "#c9d6ee" }, -- Google Blue (muted): working
  stop = { bg = "#34A853", fg = "#ffffff" }, --     Google Green:  finished
  notify = { bg = "#FBBC05", fg = "#000000" }, --   Google Yellow: needs input
  review = { bg = "#EA4335", fg = "#ffffff" }, --   Google Red:    flagged (ALT+b)
}
-- When a tab's panes disagree, the higher number wins: notify > stop > review > thinking.
local ATTENTION_PRIORITY = { thinking = 1, review = 2, stop = 3, notify = 4 }
-- States that clear when you focus the tab (mirrors the plugin's default auto_clear).
local ATTENTION_AUTO_CLEAR = { stop = true, notify = true }

wezterm.on("format-tab-title", function(tab)
  local best
  for _, p in ipairs(tab.panes) do
    local atype = attention.get_attention(p.pane_id)
    if atype and tab.is_active and ATTENTION_AUTO_CLEAR[atype] then
      attention.remove_marker(p.pane_id) -- viewing the tab clears it
      atype = nil
    end
    if atype and (not best or ATTENTION_PRIORITY[atype] > ATTENTION_PRIORITY[best]) then
      best = atype
    end
  end

  -- Honor a custom name set via CMD+e (tab.tab_title); else the active pane title.
  local base = (tab.tab_title and #tab.tab_title > 0) and tab.tab_title or tab.active_pane.title
  local index = tab.tab_index + 1
  local style = best and ATTENTION_STYLE[best]

  if style then
    return {
      { Background = { Color = style.bg } },
      { Foreground = { Color = style.fg } },
      { Text = " ● " .. index .. ": " .. base .. " " },
    }
  end
  return " " .. index .. ": " .. base .. " "
end)

if is_windows then
  config.win32_system_backdrop = "Acrylic"
  config.window_background_opacity = 0.7
  config.window_frame.font_size = 10.0
end

if is_macos then
  config.window_background_opacity = 0.8
  config.macos_window_background_blur = 50
  config.font_size = 13.0
  config.window_frame.font_size = 14.0
end

return config
