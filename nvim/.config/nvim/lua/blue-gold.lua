-- A vibe-coded blue & gold Neovim colorscheme

local M = {}

-------------------------------------------------------------------------------
-- Palette
-------------------------------------------------------------------------------

M.palette = {
	bg = "#0B1C2B",
	bg_alt = "#132a40",
	fg = "#c0caf5",
	fg_dim = "#9aa8d6",
	selection = "#123f66",
	comment = "#6f7eaa",
	code_bg = "#10263a",

	blue = "#6A95DF",
	blue_alt = "#2A69B5",
	blue_light = "#9DB9F5",

	gold = "#dfb46a",
	gold_alt = "#D39834",
	gold_light = "#F2D28B",

	red = "#e06c75",

	none = "NONE",
}

-------------------------------------------------------------------------------
-- Helpers
-------------------------------------------------------------------------------

local function hl(group, opts)
	vim.api.nvim_set_hl(0, group, opts)
end

-------------------------------------------------------------------------------
-- Plugin: lualine.nvim
-------------------------------------------------------------------------------

local function lualine_theme(p)
	local transparent = { fg = p.fg, bg = p.none }
	local inactive = { fg = p.fg_dim, bg = p.none }
	local active = { fg = p.fg, bg = p.none, gui = "bold" }

	return {
		normal = { a = active, b = transparent, c = transparent },
		insert = { a = active, b = transparent, c = transparent },
		visual = { a = active, b = transparent, c = transparent },
		replace = { a = active, b = transparent, c = transparent },
		command = { a = active, b = transparent, c = transparent },
		inactive = { a = inactive, b = inactive, c = inactive },
	}
end

M.lualine_theme = lualine_theme(M.palette)

-------------------------------------------------------------------------------
-- Colorscheme
-------------------------------------------------------------------------------

function M.colorscheme()
	vim.cmd("hi clear")
	if vim.fn.exists("syntax_on") == 1 then
		vim.cmd("syntax reset")
	end

	vim.o.termguicolors = true
	vim.g.colors_name = "blue-gold"

	local p = M.palette
	local diff = {
		add = p.blue,
		change = p.gold_alt,
		delete = p.red,
	}

	---------------------------------------------------------------------------
	-- Editor UI
	---------------------------------------------------------------------------

	-- Base surfaces
	hl("Normal", { fg = p.fg, bg = p.none })
	hl("NormalNC", { fg = p.fg_dim, bg = p.none })
	hl("EndOfBuffer", { fg = p.bg })
	hl("ColorColumn", { bg = p.selection })
	hl("Cursor", { reverse = true })
	hl("CursorLine", { bg = p.selection })
	hl("CursorColumn", { bg = p.selection })

	-- Line numbers, signs, folds
	hl("LineNr", { fg = p.blue })
	hl("LineNrAbove", { fg = p.comment })
	hl("LineNrBelow", { fg = p.comment })
	hl("CursorLineNr", { fg = p.gold, bold = true })
	hl("CursorLineFold", { fg = p.comment, bg = p.selection })
	hl("CursorLineSign", { fg = p.comment, bg = p.selection })
	hl("SignColumn", { bg = p.none })
	hl("Folded", { fg = p.fg_dim, bg = p.bg_alt })
	hl("FoldColumn", { fg = p.comment })

	-- Splits and statusline
	hl("StatusLine", { fg = p.fg, bg = p.none })
	hl("StatusLineNC", { fg = p.fg_dim, bg = p.none })
	hl("WinSeparator", { fg = p.blue_alt })

	-- Floating windows
	hl("NormalFloat", { fg = p.fg, bg = p.none })
	hl("FloatBorder", { fg = p.blue_alt, bg = p.none })
	hl("FloatTitle", { fg = p.gold, bg = p.none, bold = true })

	-- Completion menus
	hl("Pmenu", { fg = p.fg, bg = p.none })
	hl("PmenuSel", { fg = p.bg, bg = p.gold })
	hl("PmenuSbar", { bg = p.none })
	hl("PmenuThumb", { bg = p.gold_alt })

	-- Search and selection
	hl("Visual", { bg = p.selection })
	hl("Search", { fg = p.bg, bg = p.gold })
	hl("IncSearch", { fg = p.bg, bg = p.gold_alt })
	hl("CurSearch", { fg = p.bg, bg = p.gold })
	hl("SearchHL", { fg = p.bg, bg = p.gold })
	hl("MatchParen", { fg = p.gold_alt, bold = true })

	-- Misc editor groups
	hl("Directory", { fg = p.bg, bg = p.gold })
	hl("Special", { fg = p.blue })
	hl("ErrorMsg", { fg = p.red })
	hl("ModeMsg", { fg = p.blue })
	hl("MoreMsg", { fg = p.blue })
	hl("Question", { fg = p.blue })
	hl("WarningMsg", { fg = p.gold_alt })
	hl("QuickFixLine", { bg = p.bg_alt, bold = true })

	---------------------------------------------------------------------------
	-- Standard Syntax
	---------------------------------------------------------------------------

	-- Comments and todos
	hl("Comment", { fg = p.comment, italic = true })
	hl("Todo", { fg = p.bg, bg = p.gold, bold = true })

	-- Keywords and operators
	hl("Keyword", { fg = p.fg })
	hl("Conditional", { fg = p.fg })
	hl("Repeat", { fg = p.fg })
	hl("Label", { fg = p.fg })
	hl("Operator", { fg = p.fg })
	hl("Delimiter", { fg = p.fg_dim })

	-- Literals
	hl("String", { fg = p.gold_alt })
	hl("Character", { fg = p.gold_alt })
	hl("Number", { fg = p.gold })
	hl("Boolean", { fg = p.gold })
	hl("Float", { fg = p.gold })
	hl("Constant", { fg = p.blue_alt })

	-- Identifiers and types
	hl("Function", { fg = p.gold })
	hl("Identifier", { fg = p.blue })
	hl("Type", { fg = p.fg_dim })
	hl("StorageClass", { fg = p.fg_dim })
	hl("Structure", { fg = p.fg_dim })
	hl("Typedef", { fg = p.fg_dim })

	-- Preprocessor
	hl("PreProc", { fg = p.blue })
	hl("Include", { fg = p.blue })
	hl("Define", { fg = p.blue })
	hl("Macro", { fg = p.blue })

	---------------------------------------------------------------------------
	-- Treesitter
	---------------------------------------------------------------------------

	-- Comments, keywords, operators
	hl("@comment", { link = "Comment" })
	hl("@keyword", { fg = p.fg })
	hl("@keyword.function", { fg = p.fg })
	hl("@keyword.return", { fg = p.fg })
	hl("@conditional", { fg = p.fg })
	hl("@repeat", { fg = p.fg })
	hl("@operator", { fg = p.fg })

	-- Literals
	hl("@string", { fg = p.gold_alt })
	hl("@string.escape", { fg = p.gold })
	hl("@string.special", { fg = p.gold })
	hl("@number", { fg = p.gold })
	hl("@float", { fg = p.gold })
	hl("@boolean", { fg = p.gold })
	hl("@constant", { fg = p.blue_alt })
	hl("@constant.builtin", { fg = p.blue_alt })
	hl("@constant.macro", { fg = p.blue_alt })
	hl("@constant.javascript", { fg = p.blue_alt })
	hl("@constant.typescript", { fg = p.blue_alt })
	hl("@constant.tsx", { fg = p.blue_alt })
	hl("@constant.lua", { fg = p.blue_alt })

	-- Functions and variables
	hl("@function", { fg = p.gold })
	hl("@function.call", { fg = p.gold })
	hl("@function.builtin", { fg = p.gold })
	hl("@method", { fg = p.gold })
	hl("@constructor", { fg = p.gold })
	hl("@variable", { fg = p.blue })
	hl("@variable.builtin", { fg = p.blue_alt })
	hl("@parameter", { fg = p.blue_light })
	hl("@field", { fg = p.blue_light })
	hl("@property", { fg = p.blue_light })

	-- Types and namespaces
	hl("@type", { fg = p.fg_dim })
	hl("@type.builtin", { fg = p.fg_dim })
	hl("@type.definition", { fg = p.fg_dim })
	hl("@module", { fg = p.fg })
	hl("@namespace", { fg = p.fg })

	-- Punctuation
	hl("@punctuation.delimiter", { fg = p.fg_dim })
	hl("@punctuation.bracket", { fg = p.fg_dim })
	hl("@punctuation.special", { fg = p.gold })

	-- HTML / JSX / TSX tags
	hl("@tag", { fg = p.blue })
	hl("@tag.builtin", { fg = p.blue_alt })
	hl("@tag.attribute", { fg = p.fg })
	hl("@tag.delimiter", { fg = p.fg_dim })
	hl("@constructor.jsx", { fg = p.gold })
	hl("@tag.jsx", { fg = p.gold })
	hl("@tag.tsx", { fg = p.gold })
	hl("@tag.delimiter.jsx", { fg = p.fg_dim })
	hl("@tag.delimiter.tsx", { fg = p.fg_dim })
	hl("@tag.attribute.jsx", { fg = p.fg })
	hl("@tag.attribute.tsx", { fg = p.fg })

	-- CSS selectors / class names
	hl("cssClassName", { fg = p.gold })
	hl("cssClassNameDot", { fg = p.gold })
	hl("@type.css", { fg = p.gold })
	hl("@property.class.css", { fg = p.gold })
	hl("@tag.attribute.class.css", { fg = p.gold })

	-- CSS IDs
	hl("cssIdentifier", { fg = p.gold_alt })
	hl("cssIdentifierChar", { fg = p.gold_alt })
	hl("cssIDSelector", { fg = p.gold_alt })
	hl("@constant.css", { fg = p.gold_alt })
	hl("@constant.scss", { fg = p.gold_alt })
	hl("@property.id.css", { fg = p.gold_alt })
	hl("@tag.attribute.id.css", { fg = p.gold_alt })

	-- CSS at-rules
	hl("cssAtRule", { fg = p.fg })
	hl("cssMedia", { fg = p.fg })
	hl("@keyword.directive.css", { fg = p.fg })
	hl("@keyword.directive.scss", { fg = p.fg })

	---------------------------------------------------------------------------
	-- Markdown / Help
	---------------------------------------------------------------------------

	-- Headings
	hl("markdownH1", { fg = p.gold, bold = true })
	hl("markdownH2", { fg = p.gold, bold = true })
	hl("markdownH3", { fg = p.gold })
	hl("markdownH4", { fg = p.gold })
	hl("markdownH5", { fg = p.gold })
	hl("markdownH6", { fg = p.gold })
	hl("@markup.heading", { fg = p.gold, bold = true })

	-- Lists and checkboxes
	hl("markdownListMarker", { fg = p.blue })
	hl("@markup.list", { fg = p.blue })
	hl("markdownCheckbox", { fg = p.gold })
	hl("@markup.checkbox", { fg = p.gold })

	-- Code blocks and inline code
	hl("markdownCode", { fg = p.blue })
	hl("markdownCodeBlock", { fg = p.blue })
	hl("markdownCodeDelimiter", { fg = p.blue })
	hl("@markup.raw", { fg = p.blue })
	hl("@markup.raw.block", { fg = p.blue })

	-- Quotes
	hl("markdownBlockquote", { fg = p.fg_dim })
	hl("@markup.quote", { fg = p.fg_dim })

	---------------------------------------------------------------------------
	-- LSP And Diagnostics
	---------------------------------------------------------------------------

	-- Semantic tokens
	hl("@lsp.type.function", { link = "@function" })
	hl("@lsp.type.method", { link = "@method" })
	hl("@lsp.type.variable", { fg = p.blue })
	hl("@lsp.type.parameter", { link = "@parameter" })
	hl("@lsp.mod.readonly", { fg = p.blue })
	hl("@lsp.typemod.variable.readonly", { fg = p.blue })
	hl("@lsp.typemod.parameter.readonly", { fg = p.blue })
	hl("@lsp.typemod.property.readonly", { fg = p.blue_light })
	hl("@lsp.type.property", { fg = p.blue_light })
	hl("@lsp.type.type", { link = "@type" })
	hl("@lsp.type.class", { link = "@type" })
	hl("@lsp.type.enum", { link = "@type" })
	hl("@lsp.type.interface", { link = "@type" })

	-- Diagnostics
	hl("DiagnosticError", { fg = p.red })
	hl("DiagnosticWarn", { fg = p.gold_alt })
	hl("DiagnosticInfo", { fg = p.comment })
	hl("DiagnosticHint", { fg = p.selection })
	hl("DiagnosticUnderlineError", { fg = p.red, undercurl = true })
	hl("DiagnosticUnderlineWarn", { sp = p.gold_alt, undercurl = true })
	hl("DiagnosticUnderlineInfo", { sp = p.comment, undercurl = true })
	hl("DiagnosticUnderlineHint", { sp = p.selection, undercurl = true })

	---------------------------------------------------------------------------
	-- Diff And Git
	---------------------------------------------------------------------------

	-- Native diff groups
	hl("Added", { fg = diff.add, bg = p.none })
	hl("Changed", { fg = diff.change, bg = p.none })
	hl("Removed", { fg = diff.delete, bg = p.none })
	hl("diffAdded", { fg = diff.add, bg = p.none })
	hl("diffChanged", { fg = diff.change, bg = p.none })
	hl("diffRemoved", { fg = diff.delete, bg = p.none })
	hl("DiffAdd", { fg = diff.add, bg = p.none })
	hl("DiffChange", { fg = diff.change, bg = p.none })
	hl("DiffDelete", { fg = diff.delete, bg = p.none })
	hl("DiffText", { fg = diff.change, bg = p.none, bold = true })

	-- Lualine diff groups
	hl("LuaLineDiffAdd", { fg = diff.add, bg = p.none })
	hl("LuaLineDiffChange", { fg = diff.change, bg = p.none })
	hl("LuaLineDiffDelete", { fg = diff.delete, bg = p.none })

	---------------------------------------------------------------------------
	-- Plugin: lualine.nvim
	---------------------------------------------------------------------------

	local segments = { "a", "b", "c", "x", "y", "z" }
	local modes = { "normal", "insert", "visual", "replace", "inactive" }
	local diagnostics = {
		error = p.red,
		warn = p.gold_alt,
		info = p.comment,
		hint = p.selection,
	}
	local diffs = {
		added = diff.add,
		modified = diff.change,
		removed = diff.delete,
	}

	for _, seg in ipairs(segments) do
		for _, mode in ipairs(modes) do
			for sev, color in pairs(diagnostics) do
				hl("lualine_" .. seg .. "_diagnostics_" .. sev .. "_" .. mode, { fg = color, bg = p.none })
			end

			for diff_name, color in pairs(diffs) do
				hl("lualine_" .. seg .. "_diff_" .. diff_name .. "_" .. mode, { fg = color, bg = p.none })
			end
		end
	end

	---------------------------------------------------------------------------
	-- Plugin: mini.nvim
	---------------------------------------------------------------------------

	-- mini.indentscope
	hl("MiniIndentscopeSymbol", { link = "Comment" })
	hl("MiniIndentscopeSymbolOff", { link = "Comment" })

	-- mini.diff
	hl("MiniDiffSignAdd", { fg = diff.add, bg = p.none })
	hl("MiniDiffSignChange", { fg = diff.change, bg = p.none })
	hl("MiniDiffSignDelete", { fg = diff.delete, bg = p.none })
	hl("MiniDiffOverAdd", { fg = diff.add, bg = p.none, bold = true })
	hl("MiniDiffOverChange", { fg = diff.change, bg = p.none, bold = true })
	hl("MiniDiffOverChangeBuf", { fg = diff.change, bg = p.none, bold = true })
	hl("MiniDiffOverContext", { fg = p.fg_dim, bg = p.none })
	hl("MiniDiffOverContextBuf", { fg = p.fg_dim, bg = p.none })
	hl("MiniDiffOverDelete", { fg = diff.delete, bg = p.none, bold = true })

	-- mini.files
	hl("MiniFilesDirectory", { fg = p.gold })
	hl("MiniFilesFile", { fg = p.blue_light })

	---------------------------------------------------------------------------
	-- Plugin: todo-comments.nvim
	---------------------------------------------------------------------------

	hl("TodoBgTODO", { fg = p.fg, bg = p.blue_alt, bold = true })
	hl("TodoFgTODO", { fg = p.blue_alt })
	hl("TodoSignTODO", { fg = p.blue_alt })

	---------------------------------------------------------------------------
	-- Plugin: render-markdown.nvim
	---------------------------------------------------------------------------

	-- Headings and bullets
	hl("RenderMarkdownH1Bg", { bg = p.selection })
	hl("RenderMarkdownH2Bg", { bg = p.bg_alt })
	hl("RenderMarkdownH3Bg", { bg = p.none })
	hl("RenderMarkdownH4Bg", { bg = p.none })
	hl("RenderMarkdownH5Bg", { bg = p.none })
	hl("RenderMarkdownH6Bg", { bg = p.none })
	hl("RenderMarkdownBullet", { fg = p.blue })

	-- Inline styles and links
	hl("RenderMarkdownBold", { fg = p.blue_light, bold = true })
	hl("RenderMarkdownCode", { bg = p.code_bg })
	hl("RenderMarkdownLink", { fg = p.blue_alt })

	-- Callouts
	hl("RenderMarkdownInfo", { fg = p.blue, bg = p.none, bold = true })
	hl("RenderMarkdownSuccess", { fg = p.blue_alt, bg = p.none, bold = true })
	hl("RenderMarkdownHint", { fg = p.blue_light, bg = p.none, bold = true })
	hl("RenderMarkdownWarn", { fg = p.red, bg = p.none, bold = true })
	hl("RenderMarkdownError", { fg = p.gold_alt, bg = p.none, bold = true })

	---------------------------------------------------------------------------
	-- Plugin: snacks.nvim
	---------------------------------------------------------------------------

	-- Picker
	hl("SnacksPickerMatch", { fg = p.blue })
	hl("SnacksPickerPrompt", { fg = p.blue })

	-- Diff
	hl("SnacksDiffAdd", { fg = diff.add, bg = p.none, bold = true })
	hl("SnacksDiffChange", { fg = diff.change, bg = p.none, bold = true })
	hl("SnacksDiffDelete", { fg = diff.delete, bg = p.none, bold = true })
	hl("SnacksDiffContext", { fg = diff.change, bg = p.none })
	hl("SnacksDiffHeader", { fg = p.blue_light, bg = p.none, bold = true })
	hl("SnacksDiffLabel", { fg = p.gold, bg = p.none, bold = true })
	hl("SnacksDiffConflict", { fg = p.fg, bg = p.none, bold = true })
end

return M
