return {
	"folke/snacks.nvim",
	priority = 1000,
	lazy = false,
	opts = {
		bigfile = { enabled = true },

		picker = {
			layout = "sidebar_up",
			layouts = {
				sidebar_up = {
					preview = "main",
					reverse = true,
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
				sidebar_down = {
					preview = "main",
					reverse = false,
					layout = {
						backdrop = false,
						width = 40,
						min_width = 40,
						height = 0,
						position = "left",
						border = "none",
						box = "vertical",
						{
							win = "input",
							height = 1,
							border = "top_bottom",
							title = "{title} {live} {flags}",
							title_pos = "left",
						},
						{ win = "list", border = "none" },
						{ win = "preview", title = "{preview}", height = 0.4, border = "top" },
					},
				},
			},
			formatters = {
				file = {
					filename_first = true, -- display filename before the file path
					truncate = "center",
					min_width = 40, -- minimum length of the truncated path
				},
			},
			matcher = {
				frecency = true, -- frecency bonus
			},
			sources = {
				lsp_symbols = { layout = "sidebar_down" },
				lsp_references = { layout = "sidebar_down" },
				diagnostics = { layout = "sidebar_down" },
				git_log = { layout = "sidebar_down" },
				undo = { layout = "sidebar_down" },
				grep_word = { layout = "sidebar_down" },
			},
		},

		quickfile = { enabled = true },
		rename = { enabled = true },
		gitbrowse = { enabled = true },
	},
}
