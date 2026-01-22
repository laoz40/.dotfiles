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
				log_level = "off",
			})
		end,
	},
}
