return {
	-- HTML Autotag
	{
		"windwp/nvim-ts-autotag",
		config = function()
			require("nvim-ts-autotag").setup({
				opts = {
					enable_close = true, -- Auto close tags
					enable_rename = true, -- Auto rename pairs of tags
					enable_close_on_slash = false, -- Auto close on trailing </
				},
				per_filetype = {
					["html"] = {
						enable_close = true,
					},
				},
			})
		end,
	},
	-- CSS Colorizer
	{
		"catgoose/nvim-colorizer.lua",
		event = "BufReadPre", -- loads after startup
		opts = { -- set to setup table
		},
		config = function()
			require("colorizer").setup({
				filetypes = { "*" }, -- Filetype options.  Accepts table like `user_default_options`
				user_default_options = {
					names = true, -- "Name" codes like Blue or red.  Added from `vim.api.nvim_get_color_map()`
					names_opts = { -- options for mutating/filtering names.
						lowercase = true, -- name:lower(), highlight `blue` and `red`
						camelcase = true, -- name, highlight `Blue` and `Red`
						uppercase = false, -- name:upper(), highlight `BLUE` and `RED`
						strip_digits = false, -- ignore names with digits,
						-- highlight `blue` and `red`, but not `blue3` and `red4`
					},
					names_custom = false, -- Custom names to be highlighted: table|function|false
					RGB = true, -- #RGB hex codes
					RGBA = true, -- #RGBA hex codes
					RRGGBB = true, -- #RRGGBB hex codes
					RRGGBBAA = true, -- #RRGGBBAA hex codes
					AARRGGBB = true, -- 0xAARRGGBB hex codes
					rgb_fn = true, -- CSS rgb() and rgba() functions
					hsl_fn = true, -- CSS hsl() and hsla() functions
					oklch_fn = true, -- CSS oklch() function
					css = true, -- Enable all CSS *features*:
					-- names, RGB, RGBA, RRGGBB, RRGGBBAA, AARRGGBB, rgb_fn, hsl_fn, oklch_fn
					css_fn = true, -- Enable all CSS *functions*: rgb_fn, hsl_fn, oklch_fn
					-- Tailwind colors.  boolean|'normal'|'lsp'|'both'.  True sets to 'normal'
					tailwind = true, -- Enable tailwind colors
					tailwind_opts = { -- Options for highlighting tailwind names
						update_names = true, -- When using tailwind = 'both', update tailwind names from LSP results.  See tailwind section
					},
					-- parsers can contain values used in `user_default_options`
					sass = { enable = true, parsers = { "css" } }, -- Enable sass colors
					xterm = true, -- Enable xterm 256-color codes (#xNN, \e[38;5;NNNm)
					-- Highlighting mode.  'background'|'foreground'|'virtualtext'
					mode = "virtualtext", -- Set the display mode
					-- Virtualtext character to use
					virtualtext = "■",
					-- Display virtualtext inline with color.  boolean|'before'|'after'.  True sets to 'after'
					virtualtext_inline = "before",
					-- Virtualtext highlight mode: 'background'|'foreground'
					virtualtext_mode = "foreground",
				},
			})
		end,
	},
	-- Convert css units
	{
		"cjodo/convert.nvim",
		dependencies = {
			"MunifTanjim/nui.nvim",
		},
	},
	-- TODO comments
	{
		"folke/todo-comments.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
		opts = {},
	},
}
