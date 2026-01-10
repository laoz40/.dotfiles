return {
	{
		"kevinhwang91/nvim-ufo",
		dependencies = { "kevinhwang91/promise-async" },
		config = function()
			local capabilities = vim.lsp.protocol.make_client_capabilities()
			capabilities.textDocument.foldingRange = {
				dynamicRegistration = false,
				lineFoldingOnly = true,
			}
			local language_servers = vim.lsp.get_clients()
			for _, ls in ipairs(language_servers) do
				require("lspconfig")[ls].setup({
					capabilities = capabilities,
				})
			end
			require("ufo").setup()

			-- https://github.com/kevinhwang91/nvim-ufo/issues/312#issuecomment-3703855304

			local augroup = vim.api.nvim_create_augroup("config.folds", { clear = true })
			-- Only save folds and cursor position in view file
			vim.opt.viewoptions = { "folds", "cursor" }
			-- Initialize list of manually excluded filetypes (set in corresponding ftplugin)
			vim.g.ignored_view_filetypes = {}
			-- Save views automatically
			vim.api.nvim_create_autocmd("BufWinLeave", {
				group = augroup,
				pattern = "?*",
				desc = "Save view",
				callback = function(args)
					local buftype = vim.api.nvim_get_option_value("buftype", { buf = args.buf })
					local filetype = vim.api.nvim_get_option_value("filetype", { buf = args.buf })
					if
						buftype == ""
						and filetype ~= "" -- check if real file buffer
						and not string.match(vim.api.nvim_buf_get_name(args.buf), "^/tmp") -- check if not a temp file
						and not vim.tbl_contains(vim.g.ignored_view_filetypes, filetype)
					then -- check if not explicitly excluded
						vim.cmd.mkview({ mods = { emsg_silent = true } })
					end
				end,
			})
			-- Restore views automatically
			vim.api.nvim_create_autocmd("BufWinEnter", {
				group = augroup,
				pattern = "?*",
				desc = "Restore view",
				command = "silent! loadview",
			})
		end,
	},
}
