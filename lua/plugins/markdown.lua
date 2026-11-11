local markdownlint_args = { "--config", vim.fn.stdpath("config") .. "/.markdownlint.jsonc" }

return {
  {
    "mfussenegger/nvim-lint",
    opts = {
      linters = {
        ["markdownlint-cli2"] = { prepend_args = markdownlint_args },
      },
    },
  },
  {
    "stevearc/conform.nvim",
    opts = {
      formatters = {
        ["markdownlint-cli2"] = { prepend_args = markdownlint_args },
      },
    },
  },
}
