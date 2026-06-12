vim.pack.add({
	{ src = "https://github.com/nvim-lua/plenary.nvim" },
	{ src = "https://github.com/MunifTanjim/nui.nvim" },
	{ src = "https://github.com/piersolenski/wtf.nvim" },

	{ src = "https://github.com/supermaven-inc/supermaven-nvim" },

	{ src = "https://github.com/404pilo/aicommits.nvim" },
})

require("wtf").setup({
	provider = "copilot",
	popup_type = "vertical",
})

require("supermaven-nvim").setup({
	disable_inline_completion = false,
	disable_default_keymaps = true,
	log_level = "off",
})

require("aicommits").setup({
	active_provider = "gemini-api",
	providers = {
		["gemini-api"] = {
			enabled = true,
			model = "gemini-2.5-flash",
			max_length = 50,
			generate = 2,
			temperature = 0.7,
			max_tokens = 200,
			thinking_budget = 0,
		},
	},
	integrations = {
		neogit = { enabled = false },
	},
})

vim.keymap.set("i", "<A-y>", function()
	require("supermaven-nvim.completion_preview").on_accept_suggestion()
end, { desc = "Supermaven Accept" })

vim.keymap.set("i", "<A-e>", function()
	require("supermaven-nvim.completion_preview").on_accept_word()
end, { desc = "Supermaven Accept Word" })

vim.keymap.set("i", "<A-c>", function()
	require("supermaven-nvim.completion_preview").on_dispose_inlay_hint()
end, { desc = "Supermaven Clear" })
