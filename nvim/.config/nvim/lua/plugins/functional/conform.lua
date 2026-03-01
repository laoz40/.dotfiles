return {
	{
		"stevearc/conform.nvim",
		config = function()
			require("conform").setup({
				formatters_by_ft = {
					lua = { "stylua" },
					javascript = { "oxfmt" },
					typescript = { "oxfmt" },
					typescriptreact = { "oxfmt" },
					vue = { "oxfmt" },
					css = { "oxfmt" },
					scss = { "oxfmt" },
					less = { "oxfmt" },
					html = { "oxfmt" },
					json = { "oxfmt" },
					jsonc = { "oxfmt" },
					yaml = { "oxfmt" },
					markdown = { "oxfmt" },
					graphql = { "oxfmt" },
					handlebars = { "oxfmt" },
					toml = { "oxfmt" },
					svelte = { "prettier" },
				},
			})
		end,
	},
}
