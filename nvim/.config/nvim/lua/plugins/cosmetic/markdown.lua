return {
	{
		"MeanderingProgrammer/render-markdown.nvim",
		config = function()
			require("render-markdown").setup({
				sign = {
					enabled = false,
				},
				heading = {
					width = "block",
				},
			})
		end,
	},
}
