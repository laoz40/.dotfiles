vim.pack.add({
	{ src = "https://github.com/youyoumu/pretty-ts-errors.nvim" },
})

require("pretty-ts-errors").setup({
	executable = "pretty-ts-errors-markdown",
	float_opts = {
		border = "rounded",
		max_width = 80,
		max_height = 20,
		wrap = false,
	},
	auto_open = true,
	lazy_window = false,
})

vim.keymap.set("n", "<leader>te", function()
	require("pretty-ts-errors").show_formatted_error()
end, { desc = "Show TS error" })

