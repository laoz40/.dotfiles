return {
	"olimorris/persisted.nvim",
	config = function()
		require("persisted").setup({
			autostart = true, -- Automatically start session saving
			autoload = true, -- Automatically load session on startup
			use_git_branch = true, -- Create separate sessions per git branch
		})
	end,
}
