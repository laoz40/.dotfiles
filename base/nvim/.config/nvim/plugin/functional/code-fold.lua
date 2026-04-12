vim.pack.add({
	{ src = "https://github.com/kevinhwang91/promise-async" },
	{ src = "https://github.com/kevinhwang91/nvim-ufo" },
})

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.foldingRange = {
	dynamicRegistration = false,
	lineFoldingOnly = true,
}

vim.lsp.config("*", {
	capabilities = capabilities,
})

require("ufo").setup()

local augroup = vim.api.nvim_create_augroup("config.folds", { clear = true })

vim.opt.viewoptions = { "folds", "cursor" }
vim.g.ignored_view_filetypes = {}

vim.api.nvim_create_autocmd("BufWinLeave", {
	group = augroup,
	pattern = "?*",
	desc = "Save view",
	callback = function(args)
		local buftype = vim.api.nvim_get_option_value("buftype", { buf = args.buf })
		local filetype = vim.api.nvim_get_option_value("filetype", { buf = args.buf })

		if buftype ~= "" or filetype == "" then
			return
		end

		if string.match(vim.api.nvim_buf_get_name(args.buf), "^/tmp") then
			return
		end

		if vim.tbl_contains(vim.g.ignored_view_filetypes, filetype) then
			return
		end

		vim.cmd.mkview({ mods = { emsg_silent = true } })
	end,
})

vim.api.nvim_create_autocmd("BufWinEnter", {
	group = augroup,
	pattern = "?*",
	desc = "Restore view",
	command = "silent! loadview",
})
