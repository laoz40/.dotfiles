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
					layout = {
						box = "vertical",
						backdrop = false,
						width = 0,
						height = 0.4,
						position = "bottom",
						border = "top",
						title = " {title} {live} {flags}",
						title_pos = "left",
						{ win = "input", height = 1, border = "none" },
						{
							box = "horizontal",
							{ win = "list", border = "top" },
							{ win = "preview", title = "{preview}", width = 0.6, border = "none" },
						},
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
			}
		},
		quickfile = { enabled = true },
		rename = { enabled = true },
		gitbrowse = { enabled = true },
	},
}
