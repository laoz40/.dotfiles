vim.pack.add({
	{ src = "https://github.com/saghen/blink.cmp", version = vim.version.range("1") },
	{ src = "https://github.com/L3MON4D3/LuaSnip", version = vim.version.range("2") },
	{ src = "https://github.com/rafamadriz/friendly-snippets" },
	{ src = "https://github.com/mlaursen/vim-react-snippets" },
	{ src = "https://github.com/huijiro/blink-cmp-supermaven" },
})

require("blink.cmp").setup({
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
			"supermaven",
		},
		providers = {
			supermaven = {
				name = "supermaven",
				module = "blink-cmp-supermaven",
				async = true,
			},
		},
	},
	snippets = { preset = "luasnip" },
	fuzzy = { implementation = "lua" },
})

require("vim-react-snippets").setup({})
require("luasnip.loaders.from_vscode").lazy_load()
