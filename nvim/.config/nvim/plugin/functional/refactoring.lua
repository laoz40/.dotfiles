vim.pack.add({
	{ src = "https://github.com/ThePrimeagen/refactoring.nvim" },
	{ src = "https://github.com/nvim-lua/plenary.nvim" },
	{ src = "https://github.com/nvim-treesitter/nvim-treesitter" },
})

require("refactoring").setup()
