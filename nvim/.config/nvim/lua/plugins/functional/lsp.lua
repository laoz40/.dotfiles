return {
	{
		"neovim/nvim-lspconfig",
		config = function()
			vim.lsp.enable({
				"lua_ls",
				"ts_ls",
				"html",
				"cssls",
				"tailwindcss",
				"eslint",
				"marksman"
			})
		end,
	},
	{
		"j-hui/fidget.nvim",
		opts = {},
	},
}

