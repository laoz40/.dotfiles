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
				keymaps = {
					accept_suggestion = "<leader>y",
					clear_suggestion = "<leader>c",
					accept_word = "<leader>w",
				},
				disable_inline_completion = false, -- disables inline completion for use with cmp
				disable_keymaps = false, -- disables the default keymaps
				log_level = "off",
			})
		end,
	},
}
