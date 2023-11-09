-- Pull in the wezterm API
local wezterm = require 'wezterm'
local mux = wezterm.mux
local act = wezterm.action
local config = wezterm.config_builder();

-- General
config.use_dead_keys = false
config.scrollback_lines = 5000
config.enable_wayland = false

-- Color Scheme
config.color_scheme = 'Vs Code Dark+ (Gogh)'

-- Terminal appearance
config.font = wezterm.font 'JetBrains Mono'
config.font_size = 11
config.line_height = 1.25
config.default_cursor_style = "BlinkingBlock"
config.text_background_opacity = 1

-- Window appearance
config.enable_scroll_bar = true
config.initial_cols = 120
config.initial_rows = 30
config.window_background_opacity = 0.9
config.adjust_window_size_when_changing_font_size = false

-- Tab bar appearance
config.tab_bar_at_bottom = true
config.hide_tab_bar_if_only_one_tab = false
config.window_frame = {
    font = wezterm.font {
        family = 'Noto Sans',
        weight = 'Regular',
        stretch = 'Normal',
    },
    font_size = 11,
    active_titlebar_bg = '#333333',
    inactive_titlebar_bg = '#333333',
}

-- The filled in variant of the < symbol
local SOLID_LEFT_ARROW = wezterm.nerdfonts.ple_left_half_circle_thick

-- The filled in variant of the > symbol
local SOLID_RIGHT_ARROW = wezterm.nerdfonts.ple_right_half_circle_thick

-- This function returns the suggested title for a tab.
-- It prefers the title that was set via `tab:set_title()`
-- or `wezterm cli set-tab-title`, but falls back to the
-- title of the active pane in that tab.
function tab_title(tab_info)
  local title = tab_info.tab_title
  -- if the tab title is explicitly set, take that
  if title and #title > 0 then
    return title
  end
  -- Otherwise, use the title from the active pane
  -- in that tab
  return tab_info.active_pane.title
end

wezterm.on(
  'format-tab-title',
  function(tab, tabs, panes, config, hover, max_width)
    local edge_background = '#333333'
    local background = '#333333'
    local foreground = '#808080'

    if tab.is_active then
      background = '#555555'
      foreground = '#F0F0F0'
    -- elseif hover then
    --   background = '#444444'
    --   foreground = '#909090'
    end

    local edge_foreground = background

    local title = tab_title(tab)

    return {
      { Background = { Color = edge_background } },
      { Foreground = { Color = edge_foreground } },
      { Text = SOLID_LEFT_ARROW },
      { Background = { Color = background } },
      { Foreground = { Color = foreground } },
      { Text = title },
      { Background = { Color = edge_background } },
      { Foreground = { Color = edge_foreground } },
      { Text = SOLID_RIGHT_ARROW },
    }
  end
)




-- Shell profiles
config.default_cwd = "~"
config.default_prog = { '/usr/bin/pwsh', '-NoLogo' }

config.launch_menu = {
    {
        label = 'PowerShell Core',
        args = { '/usr/bin/pwsh', '-NoLogo' },
    },
    {
        label = 'Bash',
        args = { '/usr/bin/bash', '--login' },
    }
}

-- Key Bindings
config.keys = {
    { key = 'UpArrow', mods = 'SHIFT', action = act.ScrollToPrompt(-1) },
    { key = 'DownArrow', mods = 'SHIFT', action = act.ScrollToPrompt(1) },
    { key = 'L', mods = 'CTRL', action = wezterm.action.ShowDebugOverlay },
    { key = 'T', mods = 'CTRL|SHIFT', action = act.ShowLauncher },
}

-- return the config to wezterm
return config