vim.pack.add({
	{ src = "https://github.com/laoz40/git-worktree.nvim" },
})

require("git-worktree").setup({ auto_install = true, auto_switch = false })
