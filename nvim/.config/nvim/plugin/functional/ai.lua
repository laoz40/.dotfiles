vim.pack.add({
	{ src = "https://github.com/nvim-lua/plenary.nvim" },
	{ src = "https://github.com/MunifTanjim/nui.nvim" },
	{ src = "https://github.com/piersolenski/wtf.nvim" },

	{ src = "https://github.com/zbirenbaum/copilot.lua" },
})

require("wtf").setup({
	provider = "copilot",
	popup_type = "vertical",
})

require("copilot").setup({
	suggestion = {
		auto_trigger = false,
		keymap = {
			accept = "<A-y>",
			accept_word = "<A-w>",
			dismiss = "<A-d>",
		},
	},
})

