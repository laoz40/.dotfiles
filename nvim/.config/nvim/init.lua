-- leader key
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

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
vim.lsp.document_color.enable(true, nil, { style = "virtual" })
vim.o.confirm = true

-- native tabline: show only file names
vim.o.showtabline = 1
vim.o.tabline = "%!v:lua.TabLine()"

function _G.TabLine()
	local s = ""
	local current_tab = vim.fn.tabpagenr()
	local last_tab = vim.fn.tabpagenr("$")

	for i = 1, last_tab do
		local winnr = vim.fn.tabpagewinnr(i)
		local bufnr = vim.fn.tabpagebuflist(i)[winnr]
		local name = vim.fn.fnamemodify(vim.fn.bufname(bufnr), ":t")

		if name == "" then
			name = "New Tab"
		end

		if i == current_tab then
			s = s .. "%#TabLineSel#"
		else
			s = s .. "%#TabLine#"
		end

		s = s .. " " .. i .. ":" .. name .. " "
	end

	s = s .. "%#TabLineFill#"
	return s
end

-- tab/indent stuff
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
vim.keymap.set("n", "<leader>d", vim.diagnostic.open_float, { desc = "Show diagnostics popup" })

vim.diagnostic.config({
	virtual_lines = false,
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

-- save
vim.keymap.set("n", "<leader>w", "<Cmd>w<CR>", { desc = "Save file" })

-- esc remap
vim.keymap.set({ "i", "v" }, "<C-c>", "<Esc>")

-- tab management (note: <C-w>+c to close tab)
vim.keymap.set("n", "<C-t>", "<Cmd>tab split<CR>", { desc = "Duplicate current window in new tab" })
-- tab switching
for i = 1, 9 do
	vim.keymap.set("n", "<leader>" .. i, function()
		vim.cmd(i .. "tabnext")
	end, { desc = "Go to tab " .. i })
end

-- center screen on jumps
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Half page up and center" })
vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Half page down and center" })
vim.keymap.set("n", "n", "nzz", { desc = "Next search match and center" })
vim.keymap.set("n", "N", "Nzz", { desc = "Previous search match and center" })

-- move keys in insert mode
vim.keymap.set("i", "<C-h>", "<Left>")
vim.keymap.set("i", "<C-j>", "<Down>")
vim.keymap.set("i", "<C-k>", "<Up>")
vim.keymap.set("i", "<C-l>", "<Right>")

-- lsp
vim.keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, {})
vim.keymap.set("n", "<F2>", vim.lsp.buf.rename, { desc = "LSP rename" })

-- css convert
vim.keymap.set("n", "<leader>co", function()
	vim.lsp.document_color.color_presentation()
end, { desc = "Colour value convert" })
