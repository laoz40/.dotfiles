vim.pack.add({
  { src = "https://github.com/neovim/nvim-lspconfig" },
  { src = "https://github.com/mason-org/mason.nvim" },
})

require("mason").setup()

local servers = {
  lua_ls = {
    settings = {
      Lua = {
        diagnostics = {
          globals = { "vim" },
        },
        workspace = {
          library = vim.api.nvim_get_runtime_file("", true),
        },
      },
    },
  },

  ts_ls = {},

  html = {},

  cssls = {
    settings = {
      css = {
        lint = {
          unknownAtRules = "ignore",
        },
      },
      scss = {
        lint = {
          unknownAtRules = "ignore",
        },
      },
      less = {
        lint = {
          unknownAtRules = "ignore",
        },
      },
    },
  },

  tailwindcss = {},
  eslint = {},
  oxlint = {},
  oxfmt = {},
  marksman = {},
	tinymist = {},
  bashls = {},
  astro = {},
  svelte = {},

  pyrefly = {},

  ruff = {
    cmd = { "ruff", "server" },
  },
}

for name, config in pairs(servers) do
  vim.lsp.config(name, config)
  vim.lsp.enable(name)
end
