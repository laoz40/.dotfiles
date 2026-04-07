require("notes-backup")

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

-- leader key
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- esc remap
vim.keymap.set({ "i", "v" }, "<C-c>", "<Esc>")

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
vim.keymap.set("n", "gd", vim.lsp.buf.definition, {})
vim.keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, {})
vim.keymap.set("n", "gr", vim.lsp.buf.rename, {})

vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("UserLspKeymaps", { clear = true }),
	desc = "Attach LSP buffer-local keymaps",
	callback = function(event)
		local opts = { buffer = event.buf, silent = true }
		vim.keymap.set("n", "gh", vim.lsp.buf.hover, vim.tbl_extend("force", opts, { desc = "LSP hover" }))
	end,
})

-- format
vim.keymap.set("n", "<leader>fo", function()
	require("conform").format({
		timeout_ms = 500,
		lsp_format = "fallback",
	})
end, { desc = "Format file with Conform" })

-- mini.files, open at current file
vim.keymap.set("n", "<leader>e", function()
	MiniFiles.open(vim.api.nvim_buf_get_name(0), false)
	MiniFiles.reveal_cwd()
end)

vim.keymap.set("n", "<leader>gd", function()
	MiniDiff.toggle_overlay()
end)

-- Snacks
vim.keymap.set("n", "<C-P>", function()
	Snacks.picker.smart({ title = "Search" })
end, { desc = "Smart Find Files" })
vim.keymap.set("n", "<leader>ff", function()
	Snacks.picker.grep()
end, { desc = "Grep" })
vim.keymap.set({ "n", "v" }, "<leader>ft", function()
	Snacks.picker.grep_word()
end, { desc = "Grep word" })
vim.keymap.set("n", "<leader>fr", function()
	Snacks.picker.lsp_references()
end, { desc = "References" })
vim.keymap.set("n", "<leader>fd", function()
	Snacks.picker.diagnostics()
end, { desc = "Diagnostics" })
vim.keymap.set("n", "<leader>fs", function()
	Snacks.picker.lsp_symbols()
end, { desc = "LSP Symbols" })
vim.keymap.set("n", "<leader>fu", function()
	Snacks.picker.undo()
end, { desc = "Undo history" })
vim.keymap.set("n", "<leader>?", function()
	Snacks.picker.help()
end, { desc = "Search help docs" })
vim.keymap.set("n", "<leader>km", function()
	Snacks.picker.keymaps()
end, { desc = "Keymaps" })
vim.keymap.set("n", "<leader>fg", function()
	Snacks.picker.git_files()
end, { desc = "Git files" })
vim.keymap.set("n", "<leader>gl", function()
	Snacks.picker.git_log()
end, { desc = "Git log" })
vim.keymap.set("n", "<leader>gh", function()
	Snacks.gitbrowse()
end, { desc = "Open file in git repo browser " })

-- harpoon
vim.keymap.set("n", "<leader>ha", function()
	require("harpoon"):list():add()
end)
vim.keymap.set("n", "<C-h>", function()
	require("harpoon").ui:toggle_quick_menu(require("harpoon"):list())
end)
vim.keymap.set("n", "<leader>1", function()
	require("harpoon"):list():select(1)
end)
vim.keymap.set("n", "<leader>2", function()
	require("harpoon"):list():select(2)
end)
vim.keymap.set("n", "<leader>3", function()
	require("harpoon"):list():select(3)
end)
vim.keymap.set("n", "<leader>4", function()
	require("harpoon"):list():select(4)
end)
vim.keymap.set("n", "<leader>5", function()
	require("harpoon"):list():select(5)
end)

-- refactoring
vim.keymap.set("x", "<leader>re", function()
	require("refactoring").select_refactor()
end)
vim.keymap.set({ "x", "n" }, "<leader>rp", function()
	require("refactoring").debug.print_var()
end)
vim.keymap.set("n", "<leader>rc", function()
	require("refactoring").debug.cleanup({})
end)

-- css convert
vim.keymap.set("n", "<leader>co", function()
	vim.lsp.document_color.color_presentation()
end, { desc = "Colour value convert" })

-- Supermaven
vim.keymap.set("i", "<A-y>", function()
	require("supermaven-nvim.completion_preview").on_accept_suggestion()
end, { desc = "Supermaven Accept" })
vim.keymap.set("i", "<A-e>", function()
	require("supermaven-nvim.completion_preview").on_accept_word()
end, { desc = "Supermaven Accept Word" })
vim.keymap.set("i", "<A-c>", function()
	require("supermaven-nvim.completion_preview").on_dispose_inlay_hint()
end, { desc = "Supermaven Clear" })

-- copy line number range to clipboard for llms
vim.keymap.set("v", "<leader>lr", function()
	local s = vim.fn.line("'<")
	local e = vim.fn.line("'>")
	local file = vim.fn.expand("%:t")

	local range = (s == e) and tostring(s) or (s .. "-" .. e)
	local text = file .. ":" .. range

	vim.fn.setreg("+", text)
	print(text)
end, { desc = "Copy file name with line range" })
