vim.pack.add({
	{ src = "https://github.com/nvim-lualine/lualine.nvim" },
})

local colors = require("blue-gold")

require("lualine").setup({
	options = {
		icons_enabled = true,
		disabled_filetypes = {
			statusline = { "snacks_picker_input" },
			winbar = { "snacks_picker_input" },
		},
		theme = colors.lualine_theme,
		component_separators = { left = "", right = "" },
		section_separators = { left = "", right = "" },
	},
	sections = {
		lualine_a = { "mode" },
		lualine_b = { "filename" },
		lualine_c = {
			{ "diagnostics", sections = { "error", "warn" } },
		},

		lualine_x = {
			"searchcount",
			{
				"diagnostics",
				sources = { "nvim_workspace_diagnostic" },
				sections = { "error", "warn" },
			},
			-- "filetype",
			"diff",
			"branch",
		},
		lualine_y = {},
		lualine_z = {},
	},
	inactive_sections = {
		lualine_a = {},
		lualine_b = {},
		lualine_c = { "filename" },
		lualine_x = {},
		lualine_y = {},
		lualine_z = {},
	},
})
