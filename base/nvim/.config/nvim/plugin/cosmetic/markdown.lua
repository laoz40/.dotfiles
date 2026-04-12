vim.pack.add({
	{ src = "https://github.com/MeanderingProgrammer/render-markdown.nvim" },
	{ src = "https://github.com/iamcco/markdown-preview.nvim" },
})

vim.g.mkdp_filetypes = { "markdown" }

vim.api.nvim_create_autocmd("PackChanged", {
	callback = function(ev)
		local name, kind = ev.data.spec.name, ev.data.kind
		if name ~= "markdown-preview.nvim" or (kind ~= "install" and kind ~= "update") then
			return
		end

		if vim.fn.executable("npm") == 0 then
			vim.notify("markdown-preview.nvim requires npm to build", vim.log.levels.WARN)
			return
		end

		vim.system({ "npm", "install" }, { cwd = ev.data.path .. "/app" }):wait()
	end,
})

require("render-markdown").setup({
	sign = {
		enabled = false,
	},
	heading = {
		icons = { "󰄾 ", "󰘍 ", " ", " ", " ", " " },
		width = "block",
	},
})
