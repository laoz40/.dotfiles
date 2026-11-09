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

  tsgo = {
    on_attach = function(client)
      -- Use Treesitter highlighting for TypeScript.
      client.server_capabilities.semanticTokensProvider = nil
    end,
  },

  html = {},
	markuplint = {},

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
  oxlint = {
    cmd = function(dispatchers, config)
      local cmd = { "oxlint", "--lsp" }
      if config.root_dir then
        local bin_dir = vim.fs.joinpath(config.root_dir, "node_modules", ".bin")
        local effect_tsgo = vim.fs.joinpath(bin_dir, "effect-tsgo")
        local oxlint = vim.fs.joinpath(bin_dir, "oxlint")
        if vim.fn.executable(effect_tsgo) == 1 then
          cmd = { effect_tsgo, "oxlint", "--lsp" }
        elseif vim.fn.executable(oxlint) == 1 then
          cmd = { oxlint, "--lsp" }
        end
      end
      return vim.lsp.rpc.start(cmd, dispatchers)
    end,
  },
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
