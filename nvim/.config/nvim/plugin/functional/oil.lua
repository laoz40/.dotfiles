vim.pack.add({
	"https://github.com/stevearc/oil.nvim",
	"https://github.com/malewicz1337/oil-git.nvim",
	"https://github.com/JezerM/oil-lsp-diagnostics.nvim",
})

require("oil").setup({
	delete_to_trash = true,
	keymaps = {
		["h"] = "actions.parent",
		["l"] = "actions.select",
	},
	view_options = {
		show_hidden = true,
	},
})

vim.keymap.set("n", "<leader>e", "<CMD>Oil<CR>", { desc = "Oil" })

-- Notify Snacks/LSP when Oil renames or moves files so imports/references can be updated.
vim.api.nvim_create_autocmd("User", {
	pattern = "OilActionsPost",
	callback = function(event)
		if not Snacks or not Snacks.rename then
			return
		end

		for _, action in ipairs(event.data.actions) do
			if action.type == "move" then
				Snacks.rename.on_rename_file(action.src_url, action.dest_url)
			end
		end
	end,
})

require("oil-lsp-diagnostics").setup()
