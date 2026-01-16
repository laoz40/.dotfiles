local wezterm = require("wezterm")
local config = wezterm.config_builder()

-- shell
-- config.default_prog = { 'pwsh.exe' }
config.default_domain = 'WSL:Ubuntu'

-- font
config.font = wezterm.font("JetBrains Mono NL", { italic = false })
config.font_size = 20
config.line_height = 1
config.dpi = 100

-- colour
config.colors = {
	foreground = "#c0caf5",
  background = "#0e2133",
	cursor_bg = "gold",
	cursor_border = "gold",
  selection_fg = "#c0caf5",
  selection_bg = "#264f78",

  ansi = {
    "#0e2133", -- black
    "#e06c75", -- red
    "#6A95DF", -- green
    "#D39834", -- yellow
    "#6A95DF", -- blue
    "#4f73b8", -- magenta
    "#6A95DF", -- cyan
    "#c0caf5", -- white
  },

  brights = {
    "#132a40", -- bright black
    "#e06c75", -- bright red
    "#9DB9F5", -- bright green
    "#F2D28B", -- bright yellow
    "#9DB9F5", -- bright blue
    "#6A95DF", -- bright magenta
    "#9DB9F5", -- bright cyan
    "#ffffff", -- bright white
  },
}

-- window
config.window_background_opacity = 0.95
config.window_decorations = "RESIZE"
config.adjust_window_size_when_changing_font_size = false
config.enable_tab_bar = false
config.hide_tab_bar_if_only_one_tab = true
config.use_fancy_tab_bar = false
config.tab_bar_at_bottom = false
config.window_padding = {
	left = 8,
	right = 0,
	top = 0,
	bottom = 0
}
config.enable_scroll_bar = false
config.max_fps = 60
config.prefer_egl = true

return config
