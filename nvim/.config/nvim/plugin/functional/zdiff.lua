vim.pack.add({
	{ src = "https://github.com/martindur/zdiff.nvim" },
})

vim.keymap.set("n", "<leader>zd", "<cmd>Zdiff<cr>", { desc = "Zdiff (uncommitted)" })
vim.keymap.set("n", "<leader>zD", "<cmd>Zdiff main<cr>", { desc = "Zdiff (vs main)" })

vim.api.nvim_create_autocmd("FileType", {
	group = vim.api.nvim_create_augroup("ZdiffKeymaps", { clear = true }),
	pattern = "zdiff",
	callback = function(event)
		local opts = { buffer = event.buf, silent = true }
		vim.keymap.set("n", "<CR>", "<cmd>ZdiffToggle<cr>", opts)
		vim.keymap.set("n", "o", "<cmd>ZdiffOpen<cr>", opts)
		vim.keymap.set("n", "R", "<cmd>ZdiffRefresh<cr>", opts)
		vim.keymap.set("n", "q", "<cmd>bdelete<cr>", opts)
	end,
})
