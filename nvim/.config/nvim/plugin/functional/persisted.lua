vim.pack.add({
	{ src = "https://github.com/olimorris/persisted.nvim" },
})

require("persisted").setup({
	autostart = true,
	autoload = true,
	use_git_branch = true,
})
