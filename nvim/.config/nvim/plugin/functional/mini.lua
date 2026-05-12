vim.pack.add({
	{ src = "https://github.com/nvim-mini/mini.nvim" },
})

require("mini.files").setup({})
vim.api.nvim_create_autocmd("User", {
	pattern = "MiniFilesActionRename",
	callback = function(event)
		Snacks.rename.on_rename_file(event.data.from, event.data.to)
	end,
})

require("mini.icons").setup({})
require("mini.comment").setup({})
require("mini.trailspace").setup({})
require("mini.diff").setup({
	view = {
		-- Visualization style. Possible values are 'sign' and 'number'.
		-- Default: 'number' if line numbers are enabled, 'sign' otherwise.
		style = "sign",
		-- Signs used for hunks with 'sign' view
		signs = { add = "▒", change = "▒", delete = "▒" },
	},
 mappings = {
    apply = '',
    reset = '',
    textobject = '',
    goto_first = '',
    goto_prev = '',
    goto_next = '',
    goto_last = '',
  },
})
