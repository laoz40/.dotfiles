return {
	{
		"neovim/nvim-lspconfig",
		dependencies = { "mason-org/mason.nvim" },
		opts = {
			servers = {

				lua_ls = {
					settings = {
						Lua = {
							diagnostics = {
								globals = { "vim" },
							},
							workspace = {
								library = vim.api.nvim_get_runtime_file("", true),
							},
						},
					},
				},

				ts_ls = {
					on_attach = function(client, bufnr)
						require("workspace-diagnostics").populate_workspace_diagnostics(client, bufnr)
					end,
				},

				html = {},
				cssls = {},
				tailwindcss = {},
				eslint = {},
				marksman = {},
				bashls = {},
			},
		},

		config = function(_, opts)
			require("mason").setup()
			for server, config in pairs(opts.servers) do
				vim.lsp.config(server, config)
				vim.lsp.enable(server)
			end
		end,
	},
}
