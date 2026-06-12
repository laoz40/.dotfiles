vim.pack.add({
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

