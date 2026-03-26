return {
	{
		"piersolenski/wtf.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"MunifTanjim/nui.nvim",
		},
		opts = {
			provider = "copilot",
			popup_type = "vertical",
		},
	},
	{
		"supermaven-inc/supermaven-nvim",
		config = function()
			require("supermaven-nvim").setup({
				disable_inline_completion = false, -- disables inline completion for use with cmp
				disable_default_keymaps = true, -- disables default keymaps
				log_level = "off",
			})
		end,
	},
	{
		"404pilo/aicommits.nvim",
		config = function()
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
						thinking_budget = 0, -- 0 = disabled (default, faster/cheaper), -1 = dynamic, 1-24576 = manual
					},
				},
				integrations = {
					neogit = { enabled = false },
				},
			})
		end,
	},
}
