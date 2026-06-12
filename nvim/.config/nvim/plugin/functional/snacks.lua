vim.pack.add({ "https://github.com/folke/snacks.nvim" })
require("snacks").setup({
		bigfile = { enabled = true, notify = false },

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
				git_worktrees = { layout = "vscode" },
				lsp_symbols = { layout = "sidebar_down" },
				lsp_references = { layout = "sidebar_down" },
				diagnostics = { layout = "sidebar_down" },
				git_log = { layout = "sidebar_down" },
				undo = { layout = "sidebar_down" },
				grep_word = { layout = "sidebar_down" },
				grep = {
					follow = true,
					hidden = true,
					root = false,
				},
			},
		},

		quickfile = { enabled = true },
		rename = { enabled = true },
		gitbrowse = { enabled = true },
		input = { enabled = true },
	}
)

vim.keymap.set("n", "<C-P>", function()
	Snacks.picker.smart({ title = "Search" })
end, { desc = "Smart Find Files" })

vim.keymap.set("n", "<leader>ff", function()
	Snacks.picker.grep()
end, { desc = "Grep" })

vim.keymap.set({ "n", "v" }, "<leader>ft", function()
	Snacks.picker.grep_word()
end, { desc = "Grep word" })

vim.keymap.set("n", "<leader>fr", function()
	Snacks.picker.lsp_references()
end, { desc = "References" })

vim.keymap.set("n", "<leader>fd", function()
	Snacks.picker.diagnostics()
end, { desc = "Diagnostics" })

vim.keymap.set("n", "<leader>fs", function()
	Snacks.picker.lsp_symbols()
end, { desc = "LSP Symbols" })

vim.keymap.set("n", "<leader>fu", function()
	Snacks.picker.undo()
end, { desc = "Undo history" })

vim.keymap.set("n", "<leader>?", function()
	Snacks.picker.help()
end, { desc = "Search help docs" })

vim.keymap.set("n", "<leader>km", function()
	Snacks.picker.keymaps()
end, { desc = "Keymaps" })

vim.keymap.set("n", "<leader>fg", function()
	Snacks.picker.git_files()
end, { desc = "Git files" })

vim.keymap.set("n", "<leader>gl", function()
	Snacks.picker.git_log()
end, { desc = "Git log" })

vim.keymap.set("n", "<leader>gh", function()
	Snacks.gitbrowse()
end, { desc = "Open file in git repo browser " })
