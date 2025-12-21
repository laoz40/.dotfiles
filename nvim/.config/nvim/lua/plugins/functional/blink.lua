return {
	{
		"saghen/blink.cmp",
		dependencies = {
			"L3MON4D3/LuaSnip",
			"rafamadriz/friendly-snippets",
			{ "mlaursen/vim-react-snippets", opts = {} },
		},
		version = "1.*",
		opts = {
			keymap = {
				preset = "default",
				["<C-a>"] = { "show", "show_documentation" },
				["<C-d>"] = { "cancel" },
			},
			completion = {
				documentation = {
					auto_show = true,
				},
				menu = {
					auto_show = true,
					draw = {
						columns = {
							{ "label", "label_description", gap = 1 },
							{ "kind" },
						},
					},
				},
				ghost_text = { enabled = false },
				trigger = { prefetch_on_insert = false },
			},
			sources = {
				default = {
					"lsp",
					"path",
					"snippets",
					"buffer",
				},
			},
			snippets = { preset = "luasnip" },
			fuzzy = { implementation = "lua" },
		},
		opts_extend = { "sources.default" },
	},
	{
		"L3MON4D3/LuaSnip",
		-- follow latest release.
		version = "v2.*", -- Replace <CurrentMajor> by the latest released major (first number of latest release)
		config = function()
			require("luasnip.loaders.from_vscode").lazy_load()
		end,
	},
}
