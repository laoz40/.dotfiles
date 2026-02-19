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
				disable_default_keymaps = true, -- disables default keymaps
				log_level = "off",
			})
		end,
	},
	-- {
	-- 	-- to set up auth for copilot
	-- 	"github/copilot.vim",
	-- }
	{
		"NickvanDyke/opencode.nvim",
		dependencies = {
			{ "folke/snacks.nvim", opts = { input = {}, picker = {}, terminal = {} } },
		},
		config = function()
			vim.g.opencode_opts = {
				provider = {
					enabled = "tmux",
					tmux = {},
				},
			}
			vim.o.autoread = true
			vim.keymap.set({ "n", "x" }, "<leader>oa", function()
				require("opencode").ask("@this: ", { submit = true })
			end, { desc = "Ask opencode…" })

			vim.keymap.set({ "n", "x" }, "<leader>ox", function()
				require("opencode").select()
			end, { desc = "Select opencode action" })

			vim.keymap.set({ "n", "x" }, "go", function()
				return require("opencode").operator("@this ")
			end, { desc = "Add range to opencode", expr = true })
			vim.keymap.set("n", "goo", function()
				return require("opencode").operator("@this ") .. "_"
			end, { desc = "Add line to opencode", expr = true })
		end,
	},
	{
		"404pilo/aicommits.nvim",
		config = function()
			require("aicommits").setup({
				active_provider = "gemini-api",
				providers = {
					["gemini-api"] = {
						enabled = true,
						model = "gemini-2.5-flash",
						max_length = 50,
						generate = 2,
						temperature = 0.7,
						max_tokens = 200,
						thinking_budget = 0, -- 0 = disabled (default, faster/cheaper), -1 = dynamic, 1-24576 = manual
					},
				},
				integrations = {
					neogit = { enabled = false },
				},
			})
		end,
	},
}
