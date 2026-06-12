vim.pack.add({
	{ src = "https://github.com/laoz40/git-worktree.nvim" },
})

require("git-worktree").setup({ auto_install = true, auto_switch = false })

vim.keymap.set("n", "<leader>gw", function()
	require("git-worktree").switch()
end, { desc = "Git worktree switch" })

vim.keymap.set("n", "<leader>gW", function()
	require("git-worktree").create()
end, { desc = "Git worktree create" })
