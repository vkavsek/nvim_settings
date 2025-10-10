return {
  "neovim/nvim-lspconfig",
  setup = {
    slintlsp = function()
      local lspconfig = require("lspconfig")
      vim.cmd([[ autocmd BufRead,BufNewFile *.slint set filetype=slint ]])
      lspconfig.slint_lsp.setup({})
    end,
  },
}
