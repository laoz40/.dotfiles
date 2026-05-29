vim.pack.add({
	{ src = "https://github.com/kevinhwang91/promise-async" },
	{ src = "https://github.com/kevinhwang91/nvim-ufo" },
})

-- Tell language servers that Neovim wants fold information.
-- This lets nvim-ufo make smarter folds than plain indent-based folding.
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.foldingRange = {
	dynamicRegistration = false,
	lineFoldingOnly = true,
}

-- Use fold settings for every LSP server.
vim.lsp.config("*", {
	capabilities = capabilities,
})

require("ufo").setup()

-- Put the fold save/restore commands in one group.
-- Clearing the group prevents duplicates if this file is loaded again.
local augroup = vim.api.nvim_create_augroup("config.folds", { clear = true })

-- Save and restore only folds and the cursor position.
vim.opt.viewoptions = { "folds", "cursor" }
vim.g.ignored_view_filetypes = {}

vim.api.nvim_create_autocmd("BufWinLeave", {
	group = augroup,
	pattern = "?*",
	desc = "Save view",
	callback = function(args)
		local buftype = vim.api.nvim_get_option_value("buftype", { buf = args.buf })
		local filetype = vim.api.nvim_get_option_value("filetype", { buf = args.buf })

		-- Only save normal files that have a filetype.
		-- Skip terminals, help pages, prompts, and unnamed buffers.
		if buftype ~= "" or filetype == "" then
			return
		end

		-- Do not save views for temporary files.
		if string.match(vim.api.nvim_buf_get_name(args.buf), "^/tmp") then
			return
		end

		-- Skip filetypes listed above.
		if vim.tbl_contains(vim.g.ignored_view_filetypes, filetype) then
			return
		end

		-- Save the folds and cursor position for this window.
		-- Hide errors, for example if Neovim cannot write the view file.
		vim.cmd.mkview({ mods = { emsg_silent = true } })
	end,
})

vim.api.nvim_create_autocmd("BufWinEnter", {
	group = augroup,
	pattern = "?*",
	desc = "Restore view",
	-- Restore folds and cursor position when opening a file.
	-- Ignore the error if there is no saved view yet.
	command = "silent! loadview",
})
