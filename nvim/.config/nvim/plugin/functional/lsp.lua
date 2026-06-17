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
          globals = { "vim", "hl" },
        },
        workspace = {
          checkThirdParty = false,
          library = {
            vim.env.VIMRUNTIME,
          },
        },
        telemetry = {
          enable = false,
        },
      },
    },
  },

  ts_ls = {
    init_options = {
      maxTsServerMemory = 4096,
    },
    on_attach = function(client)
      -- Use Treesitter highlighting for TypeScript.
      client.server_capabilities.semanticTokensProvider = nil
    end,
  },

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
