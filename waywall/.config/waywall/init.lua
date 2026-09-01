-- ==== WAYWALL GENERIC CONFIG ====
local main = require("main")

local remaps = require("remaps")

local cfg = {
	debug_text = false,

	-- ==== LOOKS ====
	resolution = { 1920, 1080 },

	bg_col = "#000000",
	toggle_bg_picture = false,
	text_col = "#FFFFFF",
	pie_chart_1 = "#EC6E4E",
	pie_chart_2 = "#46CE66",
	pie_chart_3 = "#E446C4",

	ninbot_anchor = {
		position = "topleft", -- topleft, top, topright, left, right, bottomleft, bottomright
		x = 0,
		y = 0, -- offset
	},
	ninbot_opacity = 1, -- 0 to 1

	-- ==== ALTERNATIVE RESOLUTIONS ====
	thin_res = { 340, 1080 },
	wide_res = { 1920, 300 },
	tall_res = { 384, 16384 },

	-- ==== MIRRORS ====
	e_count = { enabled = true, x = 1160, y = 300, size = 5, colorkey = true, show_c = false },

	thin_pie = { enabled = false, x = 1200, y = 400, size = 3, colorkey = true }, -- Turning off colorkeying also maintains the original pie chart's dimensions and shows the percentages
	tall_pie = { enabled = true, x = 1200, y = 400, size = 3, colorkey = true }, -- Leave same as thin for seamlessness

	thin_percent = { enabled = true, x = 1160, y = 680, size = 6 },
	tall_percent = { enabled = true, x = 1160, y = 680, size = 6 }, -- Leave same as thin for seamlessness
	percentages_match_text = false, -- Enabling this makes the percentages match the text color rather than the pie colors

	measuring_window = { x = 30, y = 340, size = 10 },
	stretched_measure = true,

	-- ==== MACROS ====
	-- resolution changes
	thin = { key = "*-T", f3_safe = false, ingame_only = false },
	wide = { key = "*-M", f3_safe = true, ingame_only = true },
	tall = { key = "*-H", f3_safe = false, ingame_only = false },

	-- startup actions
	toggle_fullscreen_key = "Shift-O",
	launch_paceman_key = "Shift-P",

	-- during game actions
	toggle_ninbot_key = "*-N",
	toggle_remaps_key = "Insert",

	-- ==== KEYBOARD ====
	xkb_config = { -- set any setting to nil if unwanted
		enabled = false,
		layout = "mc", -- ~/.config/xkb/symbols/mc
		rules = nil, -- ~/.config/xkb/rules/...
		variant = "basic",
		options = "caps:none",
	},
	remaps_text_config = { text = "chat mode", x = 100, y = 100, size = 2, color = "#000000" },

	-- ==== MISC ====
	sens_change = { enabled = true, normal = 6, tall = 0.1011891, raw_input = false }, -- setting raw_input to true will enable sens changing via maccel
	enable_resize_animations = false,
}

return main(cfg, remaps)
