-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")

-- Enable syntax highlighting
vim.cmd("syntax enable")
-- Enable filetype detection, plugin loading, and automatic indentation
vim.cmd("filetype plugin indent on")
-- disable perl
vim.g.loaded_perl_provider = 0

require("colorizer").setup()

-- setup must be called before loading
vim.cmd.colorscheme("gruvbox")
