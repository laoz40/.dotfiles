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
vim.keymap.set("n", "gh", vim.lsp.buf.hover, {})
vim.keymap.set("n", "gd", vim.lsp.buf.definition, {})
vim.keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, {})
vim.keymap.set("n", "gr", vim.lsp.buf.rename, {})

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
local harpoon = require("harpoon")
vim.keymap.set("n", "<leader>ha", function()
	harpoon:list():add()
end)
vim.keymap.set("n", "<C-h>", function()
	harpoon.ui:toggle_quick_menu(harpoon:list())
end)
vim.keymap.set("n", "<leader>1", function()
	harpoon:list():select(1)
end)
vim.keymap.set("n", "<leader>2", function()
	harpoon:list():select(2)
end)
vim.keymap.set("n", "<leader>3", function()
	harpoon:list():select(3)
end)
vim.keymap.set("n", "<leader>4", function()
	harpoon:list():select(4)
end)
vim.keymap.set("n", "<leader>5", function()
	harpoon:list():select(5)
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
vim.keymap.set("n", "<leader>co", "<cmd>ConvertFindCurrent<CR>", { desc = "Find convertable unit in current line" })

-- colorizer
vim.keymap.set("n", "<leader>ct", ":ColorizerToggle<CR>", { noremap = true, silent = true })

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
