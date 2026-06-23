vim.pack.add({
	{ src = "https://github.com/nvim-mini/mini.nvim" },
})

require("mini.diff").setup({
	view = {
		-- Visualization style. Possible values are 'sign' and 'number'.
		-- Default: 'number' if line numbers are enabled, 'sign' otherwise.
		style = "sign",
		-- Signs used for hunks with 'sign' view
		signs = { add = "│", change = "│", delete = "│" },
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

vim.keymap.set("n", "<leader>gd", function()
	MiniDiff.toggle_overlay()
end)

require("mini.indentscope").setup({
	draw = {
		animation = require("mini.indentscope").gen_animation.none(),
	},
	symbol = "│",
})

require("mini.icons").setup({})
require("mini.comment").setup({})
require("mini.trailspace").setup({})
