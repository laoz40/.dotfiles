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
				"marksman",
				"bashls"
			})
		end,
	},
}

