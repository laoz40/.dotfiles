vim.pack.add({
	{ src = "https://github.com/rachartier/tiny-inline-diagnostic.nvim" },
	{ src = "https://github.com/dmmulroy/ts-error-translator.nvim" },
})

require("ts-error-translator").setup({
	auto_attach = true,
	servers = {
		"astro",
		"svelte",
		"ts_ls",
		"tsserver",
		"typescript-tools",
		"volar",
		"vtsls",
	},
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
