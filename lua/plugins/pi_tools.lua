return {
  {
    "mason-org/mason.nvim",
    opts = {
      PATH = "append",
    },
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        clangd = {
          mason = false,
          cmd = { "/usr/bin/clangd" },
        },
      },
    },
  },
}
