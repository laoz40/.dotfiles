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
				cssls = {
					settings = {
						css = {
							lint = {
								unknownAtRules = "ignore",
							},
						},
						scss = {
							lint = {
								unknownAtRules = "ignore",
							},
						},
						less = {
							lint = {
								unknownAtRules = "ignore",
							},
						},
					},
				},
				tailwindcss = {},
				eslint = {},
				oxlint = {},
				oxfmt = {},

				marksman = {},
				bashls = {},
				astro = {},
				svelte = {},

				basedpyright = {},
				ruff = {
					cmd = { "ruff", "server" },
				},
			},
		},

		config = function(_, opts)
			require("mason").setup()
			for lsp, config in pairs(opts.servers) do
				vim.lsp.config(lsp, config)
				vim.lsp.enable(lsp)
			end
		end,
	},
}
