vim.pack.add({
	{ src = "https://github.com/rachartier/tiny-inline-diagnostic.nvim" },
	{ src = "https://github.com/artemave/workspace-diagnostics.nvim" },
})

-- shadcn files live in components/ui. Ignore diagnostics from there.
local function is_shadcn_ui_path(path)
	return path:match("[/\\]components[/\\]ui[/\\]") ~= nil
end

-- Hide diagnostics if they come from a components/ui buffer.
-- This also covers files that are already open.
local diagnostic_set = vim.diagnostic.set
rawset(vim.diagnostic, "set", function(namespace, bufnr, diagnostics, opts)
	if is_shadcn_ui_path(vim.api.nvim_buf_get_name(bufnr)) then
		diagnostics = {}
	end

	return diagnostic_set(namespace, bufnr, diagnostics, opts)
end)

require("workspace-diagnostics").setup({
	workspace_files = function()
		local root = vim.fs.root(0, ".git") or vim.uv.cwd()
		local files = vim.fn.systemlist({ "git", "-C", root, "ls-files" })

		-- Do not scan components/ui when loading project-wide diagnostics.
		return vim.tbl_filter(function(file)
			return not is_shadcn_ui_path(root .. "/" .. file)
		end, files)
	end,
})

vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("WorkspaceDiagnostics", { clear = true }),
	desc = "Populate project-wide LSP diagnostics",
	callback = function(event)
		local client = vim.lsp.get_client_by_id(event.data.client_id)
		if not client then
			return
		end

		require("workspace-diagnostics").populate_workspace_diagnostics(client, event.buf)
	end,
})

require("tiny-inline-diagnostic").setup({
	preset = "powerline", -- minimal, powerline
	transparent_bg = false,
	transparent_cursorline = false,
	options = {
		add_messages = {
			-- display_count = true,
		},
		multilines = {
			-- enabled = true,
		},
		show_source = {
			enabled = true,
		},
		overflow = {
			mode = "wrap", -- "wrap": split into lines, "none": no truncation, "oneline": keep single line
			padding = 10, -- Extra characters to trigger wrapping earlier
		},
		break_line = {
			enabled = true, -- Enable automatic line breaking
			after = 30, -- Number of characters before inserting a line break
		},
		use_icons_from_diagnostic = true,
		set_arrow_to_diag_color = true,
	},
})
