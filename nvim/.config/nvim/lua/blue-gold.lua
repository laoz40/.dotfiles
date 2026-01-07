-- blue-gold.nvim
-- A vibe-coded blue & gold Neovim colorscheme
-- Full Treesitter + Neovim 0.11 highlight support

local M = {}

-- Color palette (restricted to blue & gold tones)
M.palette = {
	bg = "#0e2133",
	bg_alt = "#132a40",
	fg = "#c0caf5",
	fg_dim = "#8b95c9",
	selection = "#264f78",
	comment = "#3a415c",

	blue = "#6A95DF",
	blue_alt = "#4f73b8",
	blue_light = "#9DB9F5",

	gold = "#dfb46a",
	gold_alt = "#D39834",
	gold_light = "#F2D28B",

	red = "#e06c75",

	none = "NONE",
}

local function hl(group, opts)
	vim.api.nvim_set_hl(0, group, opts)
end

function M.colorscheme()
	vim.cmd("hi clear")
	if vim.fn.exists("syntax_on") == 1 then
		vim.cmd("syntax reset")
	end

	vim.o.termguicolors = true
	vim.g.colors_name = "blue-gold"

	local p = M.palette

	-----------------------------------------------------------------------------
	-- Core UI
	-----------------------------------------------------------------------------
	hl("Normal", { fg = p.fg, bg = p.none })
	hl("NormalNC", { fg = p.fg_dim, bg = p.none })
	hl("Visual", { bg = p.selection })
	hl("Cursor", { reverse = true })
	hl("CursorLine", { bg = p.selection })
	hl("CursorColumn", { bg = p.selection })
	hl("ColorColumn", { bg = p.selection })

	hl("LineNr", { fg = p.blue })
	hl("LineNrAbove", { fg = p.comment })
	hl("LineNrBelow", { fg = p.comment })
	hl("EndOfBuffer", { fg = p.bg })
	hl("CursorLineNr", { fg = p.gold, bold = true })
	hl("CursorLineFold", { fg = p.comment, bg = p.selection })
	hl("CursorLineSign", { fg = p.comment, bg = p.selection })
	hl("SignColumn", { bg = p.none })
	hl("Folded", { fg = p.fg_dim, bg = p.bg_alt })
	hl("FoldColumn", { fg = p.comment })

	hl("StatusLine", { fg = p.fg, bg = p.none })
	hl("StatusLineNC", { fg = p.fg_dim, bg = p.none })
	hl("WinSeparator", { fg = p.blue_alt })

	hl("Pmenu", { fg = p.fg, bg = p.none })
	hl("PmenuSel", { fg = p.bg, bg = p.gold })
	hl("PmenuSbar", { bg = p.none })
	hl("PmenuThumb", { bg = p.gold_alt })

	-- Floating windows
	hl("NormalFloat", { fg = p.fg, bg = p.none })
	hl("FloatBorder", { fg = p.blue_alt, bg = p.none })
	hl("FloatTitle", { fg = p.gold, bg = p.none, bold = true })

	hl("Search", { fg = p.bg, bg = p.gold })
	hl("IncSearch", { fg = p.bg, bg = p.gold_alt })
	hl("CurSearch", { fg = p.bg, bg = p.gold }) -- optional, for incremental search
	hl("SearchHL", { fg = p.bg, bg = p.gold }) -- some plugins use this
	hl("Directory", { fg = p.bg, bg = p.gold })

	hl("MatchParen", { fg = p.gold_alt, bold = true })

	hl("Special", { fg = p.blue })
	hl("ErrorMsg", { fg = p.red })

	-----------------------------------------------------------------------------
	-- Standard Syntax
	-----------------------------------------------------------------------------
	hl("Comment", { fg = p.comment, italic = true })
	hl("Keyword", { fg = p.blue })
	hl("Conditional", { fg = p.blue })
	hl("Repeat", { fg = p.blue })
	hl("Label", { fg = p.blue })
	hl("Operator", { fg = p.fg })
	hl("Delimiter", { fg = p.fg_dim })

	hl("String", { fg = p.gold_alt })
	hl("Character", { fg = p.gold_alt })
	hl("Number", { fg = p.gold })
	hl("Boolean", { fg = p.gold })
	hl("Float", { fg = p.gold })

	hl("Function", { fg = p.gold })
	hl("Identifier", { fg = p.blue_light })
	hl("Type", { fg = p.fg_dim })
	hl("StorageClass", { fg = p.fg_dim })
	hl("Structure", { fg = p.fg_dim })
	hl("Typedef", { fg = p.fg_dim })

	hl("Constant", { fg = p.gold })
	hl("PreProc", { fg = p.blue })
	hl("Include", { fg = p.blue })
	hl("Define", { fg = p.blue })
	hl("Macro", { fg = p.blue })

	hl("Todo", { fg = p.bg, bg = p.gold, bold = true })

	-----------------------------------------------------------------------------
	-- Treesitter (Complete @ captures)
	hl("@comment", { link = "Comment" })
	hl("@keyword", { fg = p.blue })
	hl("@keyword.function", { fg = p.blue })
	hl("@keyword.return", { fg = p.blue })
	hl("@conditional", { fg = p.blue })
	hl("@repeat", { fg = p.blue })
	hl("@operator", { fg = p.fg })

	hl("@string", { fg = p.gold_alt })
	hl("@string.escape", { fg = p.gold })
	hl("@string.special", { fg = p.gold })

	hl("@number", { fg = p.gold })
	hl("@float", { fg = p.gold })
	hl("@boolean", { fg = p.gold })

	hl("@function", { fg = p.gold })
	hl("@function.call", { fg = p.gold })
	hl("@function.builtin", { fg = p.gold_alt })
	hl("@method", { fg = p.gold })
	hl("@constructor", { fg = p.gold })

	hl("@variable", { fg = p.blue_light })
	hl("@variable.builtin", { fg = p.blue_alt })
	hl("@parameter", { fg = p.blue_light })
	hl("@field", { fg = p.fg })
	hl("@property", { fg = p.fg })

	hl("@type", { fg = p.fg_dim })
	hl("@type.builtin", { fg = p.fg_dim })
	hl("@type.definition", { fg = p.fg_dim })

	hl("@constant", { fg = p.gold })
	hl("@constant.builtin", { fg = p.gold_alt })
	hl("@constant.macro", { fg = p.gold })

	hl("@module", { fg = p.fg })
	hl("@namespace", { fg = p.fg })

	hl("@punctuation.delimiter", { fg = p.fg_dim })
	hl("@punctuation.bracket", { fg = p.fg_dim })
	hl("@punctuation.special", { fg = p.gold })

	-- HTML / JSX / TSX tags (critical for React)
	hl("@tag", { fg = p.blue })
	hl("@tag.builtin", { fg = p.blue_alt })
	hl("@tag.attribute", { fg = p.fg })
	hl("@tag.delimiter", { fg = p.fg_dim })

	-- JSX specific captures used by nvim-treesitter
	hl("@constructor.jsx", { fg = p.blue })
	hl("@tag.jsx", { fg = p.blue })
	hl("@tag.tsx", { fg = p.blue })
	hl("@tag.delimiter.jsx", { fg = p.fg_dim })
	hl("@tag.delimiter.tsx", { fg = p.fg_dim })
	hl("@tag.attribute.jsx", { fg = p.fg })
	hl("@tag.attribute.tsx", { fg = p.fg })

	-----------------------------------------------------------------------------
	-- Markdown / Help
	-----------------------------------------------------------------------------
	hl("markdownH1", { fg = p.gold, bold = true })
	hl("markdownH2", { fg = p.gold, bold = true })
	hl("markdownH3", { fg = p.gold })
	hl("markdownH4", { fg = p.gold })
	hl("markdownH5", { fg = p.gold })
	hl("markdownH6", { fg = p.gold })

	hl("@markup.heading", { fg = p.gold, bold = true })

	-- Bullet points
	hl("markdownListMarker", { fg = p.blue })
	hl("@markup.list", { fg = p.blue })

	-- Checkboxes
	hl("markdownCheckbox", { fg = p.gold })
	hl("@markup.checkbox", { fg = p.gold })

	hl("markdownCode", { fg = p.blue })
	hl("markdownCodeBlock", { fg = p.blue })
	hl("markdownCodeDelimiter", { fg = p.blue })

	-- Treesitter markdown code
	hl("@markup.raw", { fg = p.blue })
	hl("@markup.raw.block", { fg = p.blue })

	-- Quotes / blockquotes
	hl("markdownBlockquote", { fg = p.fg_dim })
	hl("@markup.quote", { fg = p.fg_dim })

	-----------------------------------------------------------------------------
	-- LSP semantic tokens (0.11+)
	hl("@lsp.type.function", { link = "@function" })
	hl("@lsp.type.method", { link = "@method" })
	hl("@lsp.type.variable", { link = "@variable" })
	hl("@lsp.type.parameter", { link = "@parameter" })
	hl("@lsp.type.property", { fg = p.fg })
	hl("@lsp.type.type", { link = "@type" })
	hl("@lsp.type.class", { link = "@type" })
	hl("@lsp.type.enum", { link = "@type" })
	hl("@lsp.type.interface", { link = "@type" })

	-----------------------------------------------------------------------------
	-- Diagnostics (Neovim 0.11)
	-----------------------------------------------------------------------------
	hl("DiagnosticError", { fg = p.red })
	hl("DiagnosticWarn", { fg = p.gold_alt })
	hl("DiagnosticInfo", { fg = p.comment })
	hl("DiagnosticHint", { fg = p.selection })

	hl("DiagnosticUnderlineError", { fg = p.red, undercurl = true })
	hl("DiagnosticUnderlineWarn", { sp = p.gold_alt, undercurl = true })
	hl("DiagnosticUnderlineInfo", { sp = p.comment, undercurl = true })
	hl("DiagnosticUnderlineHint", { sp = p.selection, undercurl = true })

	-----------------------------------------------------------------------------
	-- Diff
	-----------------------------------------------------------------------------
	hl("DiffAdd", { fg = p.blue_light }) -- added lines
	hl("DiffChange", { fg = p.gold_alt }) -- changed lines
	hl("DiffDelete", { fg = p.red }) -- deleted lines
	hl("DiffText", { fg = p.gold, bold = true }) -- changed text inside line

	-----------------------------------------------------------------------------
	-- TODO
	-----------------------------------------------------------------------------
	hl("TodoBgTODO", { fg = p.fg, bg = p.blue_alt, bold = true })
	hl("TodoFgTODO", { fg = p.blue_alt })
	hl("TodoSignTODO", { fg = p.blue_alt })

	-----------------------------------------------------------------------------
	-- Messages / Prompts
	-----------------------------------------------------------------------------
	hl("ModeMsg", { fg = p.blue }) -- "-- INSERT --"
	hl("MoreMsg", { fg = p.blue }) -- more-prompt
	hl("Question", { fg = p.blue }) -- hit-enter / y/n
	hl("WarningMsg", { fg = p.gold_alt }) -- warnings

	-----------------------------------------------------------------------------
	-- Quickfix
	-----------------------------------------------------------------------------
	hl("QuickFixLine", { bg = p.bg_alt, bold = true })

	-----------------------------------------------------------------------------
	-- Lualine support (transparent)
	-----------------------------------------------------------------------------
	hl("lualine_a_normal", { fg = p.bg, bg = p.blue, bold = true })
	hl("lualine_a_insert", { fg = p.bg, bg = p.gold, bold = true })
	hl("lualine_a_visual", { fg = p.bg, bg = p.gold_alt, bold = true })
	hl("lualine_a_replace", { fg = p.bg, bg = p.blue_alt, bold = true })
	hl("lualine_a_command", { fg = p.bg, bg = p.gold, bold = true })

	hl("lualine_b_normal", { fg = p.fg, bg = p.bg_alt })
	hl("lualine_c_normal", { fg = p.fg, bg = p.none })

	hl("lualine_b_insert", { fg = p.fg, bg = p.bg_alt })
	hl("lualine_c_insert", { fg = p.fg, bg = p.none })

	hl("lualine_b_visual", { fg = p.fg, bg = p.bg_alt })
	hl("lualine_c_visual", { fg = p.fg, bg = p.none })

	hl("lualine_b_replace", { fg = p.fg, bg = p.bg_alt })
	hl("lualine_c_replace", { fg = p.fg, bg = p.none })

	hl("lualine_b_command", { fg = p.fg, bg = p.none })
	hl("lualine_c_command", { fg = p.fg, bg = p.none })

	local segments = { "a", "b", "c", "x", "y", "z" }
	local modes = { "normal", "insert", "visual", "replace", "inactive" }

	-- Diagnostics colors
	local diagnostics = {
		error = p.red,
		warn = p.gold_alt,
		info = p.comment,
		hint = p.selection,
	}

	for _, seg in ipairs(segments) do
		for _, mode in ipairs(modes) do
			for sev, color in pairs(diagnostics) do
				hl("lualine_" .. seg .. "_diagnostics_" .. sev .. "_" .. mode, { fg = color, bg = p.none })
			end
		end
	end

	-- Git diff colors
	local diffs = {
		added = p.blue_light,
		modified = p.gold_alt,
		removed = p.red,
	}

	for _, seg in ipairs(segments) do
		for _, mode in ipairs(modes) do
			for diff, color in pairs(diffs) do
				hl("lualine_" .. seg .. "_diff_" .. diff .. "_" .. mode, { fg = color, bg = p.none })
			end
		end
	end

	-----------------------------------------------------------------------------
	-- Mini.files support
	-----------------------------------------------------------------------------
	hl("MiniFilesDirectory", { fg = p.gold }) -- folder icons
	hl("MiniFilesFile", { fg = p.blue_light }) -- folder/file names

	-----------------------------------------------------------------------------
	-- render-markdown.nvim
	-----------------------------------------------------------------------------
	hl("RenderMarkdownH1Bg", { bg = p.selection })
	hl("RenderMarkdownH2Bg", { bg = p.bg_alt })
	hl("RenderMarkdownH3Bg", { bg = p.none })
	hl("RenderMarkdownH4Bg", { bg = p.none })
	hl("RenderMarkdownH5Bg", { bg = p.none })
	hl("RenderMarkdownH6Bg", { bg = p.none })

	hl("RenderMarkdownBullet", { fg = p.blue })

	hl("RenderMarkdownBold", { fg = p.blue, bold = true })
	hl("RenderMarkdownBold", { fg = p.blue_light, bold = true })

	hl("RenderMarkdownCode", { bg = p.comment })

	hl("RenderMarkdownLink", { fg = p.blue_alt })

	-- NOTE → informational, calm blue
	hl("RenderMarkdownInfo", {
		fg = p.blue,
		bg = p.none,
		bold = true,
	})

	-- TIP → positive / success → gold_light reads well here
	hl("RenderMarkdownSuccess", {
		fg = p.blue_alt,
		bg = p.none,
		bold = true,
	})

	-- IMPORTANT → emphasis but not danger → solid gold
	hl("RenderMarkdownHint", {
		fg = p.blue_light,
		bg = p.none,
		bold = true,
	})

	-- WARNING → cautionary → gold_alt
	hl("RenderMarkdownWarn", {
		fg = p.red,
		bg = p.none,
		bold = true,
	})

	-- CAUTION / ERROR → true danger → red
	hl("RenderMarkdownError", {
		fg = p.gold_alt,
		bg = p.none,
		bold = true,
	})

	-----------------------------------------------------------------------------
	-- Snacks Picker
	-----------------------------------------------------------------------------

	hl("SnacksPickerMatch", { fg = p.blue })
	hl("SnacksPickerPrompt", { fg = p.blue })

	-- Diff (+ core diff)
	hl("DiffAdd", { fg = p.blue, bg = p.none })
	hl("SnacksDiffAdd", { fg = p.blue, bg = p.none })

	hl("DiffDelete", { fg = p.red, bg = p.none })
	hl("SnacksDiffDelete", { fg = p.red, bg = p.none })

	hl("DiffChange", { fg = p.fg, bg = p.none })
	hl("SnacksDiffChange", { fg = p.fg, bg = p.none })

	-- Conflict
	hl("SnacksDiffConflict", { fg = p.fg, bg = p.none, bold = true })

	-- Optional: changed text inside changed lines
	hl("DiffText", { fg = p.fg, bg = p.none, bold = true })
end

return M
