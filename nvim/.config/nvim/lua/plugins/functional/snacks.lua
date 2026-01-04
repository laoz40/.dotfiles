return {
	"folke/snacks.nvim",
	priority = 1000,
	lazy = false,
	opts = {
		bigfile = { enabled = true },

		picker = {
			layout = "custom",
			layouts = {
				custom = {
					preview = "main",
					reverse = "true",
					layout = {
						backdrop = false,
						width = 40,
						min_width = 40,
						height = 0,
						position = "left",
						border = "none",
						box = "vertical",
						{ win = "list", border = "none" },
						{
							win = "input",
							height = 1,
							border = "top",
							title = "{title} {live} {flags}",
							title_pos = "left",
						},
						{ win = "preview", title = "{preview}", height = 0.4, border = "top" },
					},
				},
			},
			formatters = {
				file = {
					filename_first = true, -- display filename before the file path
					--- * left: truncate the beginning of the path
					--- * center: truncate the middle of the path
					--- * right: truncate the end of the path
					---@type "left"|"center"|"right"
					truncate = "center",
					min_width = 40, -- minimum length of the truncated path
				},
			},
		},

		quickfile = { enabled = true },
		rename = { enabled = true },
		gitbrowse = { enabled = true },
	},
}
