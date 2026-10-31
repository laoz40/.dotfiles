vim.pack.add({
	{ src = "https://github.com/lewis6991/gitsigns.nvim" },
})

local gitsigns = require("gitsigns")
gitsigns.setup({
	linehl = false,
	word_diff = false,
})

vim.keymap.set("n", "<leader>gd", gitsigns.toggle_linehl, { desc = "Toggle Git line highlights" })
