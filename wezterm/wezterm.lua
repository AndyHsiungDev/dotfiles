local wezterm = require("wezterm")

local config = wezterm.config_builder()

local is_windows = os.getenv("OS") and os.getenv("OS"):lower():find("windows")
local is_macos = wezterm.target_triple:lower():find("darwin") ~= nil

wezterm.on("gui-startup", function(cmd)
  local tab, pane, window = wezterm.mux.spawn_window(cmd or {})
  pane:split({ direction = "Right" })
end)

local function split_new_tab(window, pane)
  local tab, new_pane, _ = window:mux_window():spawn_tab({})
  new_pane:split({ direction = "Right" })
end

wezterm.on("new-tab-button-click", function(window, pane, button, default_action)
  if button == "Left" then
    split_new_tab(window, pane)
    return false
  end
end)

config.color_scheme = "rose-pine-moon"
config.max_fps = 120
config.font = wezterm.font("Monaco")
config.window_decorations = "INTEGRATED_BUTTONS|RESIZE"
config.window_frame = {
  font = wezterm.font("Monaco"),
}
config.inactive_pane_hsb = {
  saturation = 0.0,
  brightness = 0.5,
}
config.keys = {
  {
    key = "t",
    mods = "CMD",
    action = wezterm.action_callback(split_new_tab),
  },
}

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
