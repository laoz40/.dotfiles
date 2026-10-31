vim.pack.add({
	{ src = "https://github.com/nvim-mini/mini.nvim" },
})

require("mini.indentscope").setup({
	draw = {
		animation = require("mini.indentscope").gen_animation.none(),
	},
	symbol = "│",
})

require("mini.icons").setup({})
require("mini.comment").setup({})
require("mini.trailspace").setup({})
