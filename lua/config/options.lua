-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
require("config.wsl")

if not (vim.env.SSH_CONNECTION or vim.env.SSH_TTY) or vim.g.clipboard ~= nil then
  return
end

vim.opt.clipboard = ""
vim.g.clipboard = vim.env.TMUX and "tmux" or "osc52"
vim.api.nvim_create_autocmd("TextYankPost", {
  group = vim.api.nvim_create_augroup("ssh_clipboard", { clear = true }),
  desc = "Copy SSH yanks to the local clipboard",
  callback = function()
    local yank = vim.v.event
    if yank.operator == "y" and yank.regname == "" and vim.o.clipboard == "" and #vim.api.nvim_list_uis() > 0 then
      vim.fn.setreg("+", yank.regcontents, yank.regtype)
    end
  end,
})
