vim.pack.add({
	{ src = "https://github.com/nvim-lualine/lualine.nvim" },
})

local colors = require("blue-gold")

local function diagnostic_count(severity, icon)
	local count = vim.diagnostic.count(nil)[severity] or 0
	if count == 0 then
		return ""
	end

	return icon .. " " .. count
end

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
				function()
					return diagnostic_count(vim.diagnostic.severity.ERROR, "󰅚")
				end,
				color = { fg = colors.palette.red },
			},
			{
				function()
					return diagnostic_count(vim.diagnostic.severity.WARN, "󰀪")
				end,
				color = { fg = colors.palette.gold_alt },
			},
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
