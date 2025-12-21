return {
	{
		"rachartier/tiny-inline-diagnostic.nvim",
		event = "VeryLazy",
		priority = 1000,
		config = function()
			require("tiny-inline-diagnostic").setup({
				preset = "powerline", -- minimal, powerline
				transparent_bg = false,
				transparent_cursorline = false,
				options = {
					add_messages = {
						-- display_count = true,
					},
					multilines = {
						-- enabled = true,
					},
					show_source = {
						enabled = true,
					},
					overflow = {
						mode = "wrap", -- "wrap": split into lines, "none": no truncation, "oneline": keep single line
						padding = 10, -- Extra characters to trigger wrapping earlier
					},
					break_line = {
						enabled = true, -- Enable automatic line breaking
						after = 30, -- Number of characters before inserting a line break
					},
					use_icons_from_diagnostic = true,
					set_arrow_to_diag_color = true,
				},
			})
		end,
	},
	{
		"artemave/workspace-diagnostics.nvim"
	}
}
