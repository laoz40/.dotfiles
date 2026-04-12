-- QOL
vim.o.clipboard = "unnamedplus"
vim.o.mouse = "a"
vim.o.history = 100
vim.o.autoread = true
vim.o.backup = false
vim.o.swapfile = false
vim.o.undofile = true
vim.o.scrolloff = 10
vim.o.foldenable = true
vim.o.foldmethod = "manual"
vim.o.foldcolumn = "0"
vim.o.foldlevel = 99
vim.o.foldlevelstart = 99
vim.o.sessionoptions = "curdir,folds,globals,help,tabpages,terminal,winsize"

-- ui
vim.opt.background = "dark"
vim.o.termguicolors = true
require("blue-gold").colorscheme()
vim.o.winborder = "rounded"
vim.o.number = true
vim.o.relativenumber = true
vim.o.signcolumn = "yes:1"
vim.opt.showmode = false
vim.o.laststatus = 3
vim.o.cmdheight = 0
vim.opt.ruler = false
vim.opt.guicursor = "n-v-i-c:block-Cursor"
vim.api.nvim_set_hl(0, "Cursor", { bg = "#ffd700" })

-- tab stuff
vim.o.expandtab = false
vim.o.shiftwidth = 2
vim.o.tabstop = 2
vim.o.softtabstop = 2
vim.o.smartindent = true

-- highlight behaviour
vim.o.hlsearch = true
vim.o.incsearch = true
vim.api.nvim_create_autocmd("TextYankPost", {
	pattern = "*",
	callback = function()
		vim.highlight.on_yank({ higroup = "IncSearch", timeout = 200 })
	end,
})

-- diagnostics
vim.diagnostic.config({
	virtual_lines = false, -- using tiny-inline-diagnostics
	virtual_text = false,
	underline = true,
	update_in_insert = false,
	severity_sort = true,
	float = {
		border = "rounded",
		source = true,
	},
	signs = {
		text = {
			[vim.diagnostic.severity.ERROR] = "󰅚 ",
			[vim.diagnostic.severity.WARN] = "󰀪 ",
			[vim.diagnostic.severity.INFO] = "󰋽 ",
			[vim.diagnostic.severity.HINT] = "󰌶 ",
		},
		numhl = {
			[vim.diagnostic.severity.ERROR] = "ErrorMsg",
			[vim.diagnostic.severity.WARN] = "WarningMsg",
		},
	},
})
-- Undercurl
vim.cmd([[let &t_Cs = "\e[4:3m"]])
vim.cmd([[let &t_Ce = "\e[4:0m"]])

-- ide like highlight when stopping cursor
vim.api.nvim_create_autocmd("CursorMoved", {
	group = vim.api.nvim_create_augroup("LspReferenceHighlight", { clear = true }),
	desc = "Highlight references under cursor",
	callback = function()
		if vim.fn.mode() ~= "i" then
			local clients = vim.lsp.get_clients({ bufnr = 0 })
			local supports_highlight = false
			for _, client in ipairs(clients) do
				if client.server_capabilities.documentHighlightProvider then
					supports_highlight = true
					break
				end
			end
			if supports_highlight then
				vim.lsp.buf.clear_references()
				vim.lsp.buf.document_highlight()
			end
		end
	end,
})
vim.api.nvim_create_autocmd("CursorMovedI", {
	group = "LspReferenceHighlight",
	desc = "Clear highlights when entering insert mode",
	callback = function()
		vim.lsp.buf.clear_references()
	end,
})

-- no auto continue comments on new line
vim.api.nvim_create_autocmd("FileType", {
	group = vim.api.nvim_create_augroup("no_auto_comment", {}),
	callback = function()
		vim.opt_local.formatoptions:remove({ "c", "r", "o" })
	end,
})

-- Show command line when recording macro
local cmdheight_group = vim.api.nvim_create_augroup("CmdHeightToggle", { clear = true })
vim.api.nvim_create_autocmd("RecordingEnter", {
	group = cmdheight_group,
	pattern = "*",
	command = "set cmdheight=1",
})
vim.api.nvim_create_autocmd("RecordingLeave", {
	group = cmdheight_group,
	pattern = "*",
	command = "set cmdheight=0",
})
