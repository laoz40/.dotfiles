return {
	{
		"nvim-mini/mini.nvim",
		version = false,
		config = function()
			require("mini.files").setup({})
			vim.api.nvim_create_autocmd("User", {
				pattern = "MiniFilesActionRename",
				callback = function(event)
					Snacks.rename.on_rename_file(event.data.from, event.data.to)
				end,
			})

			require("mini.icons").setup({})
			require("mini.comment").setup({})
			require("mini.pairs").setup({})
			require("mini.trailspace").setup({})
		end,
	},
}
