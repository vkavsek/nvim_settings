vim.env.SSH_CONNECTION = nil
vim.env.SSH_TTY = nil
vim.env.TMUX = nil
package.loaded["config.wsl"] = true

local function configure()
  dofile("lua/config/options.lua")
end

configure()
assert(vim.g.clipboard == nil, "local clipboard provider changed")

vim.env.SSH_CONNECTION = "test"
vim.g.clipboard = false
configure()
assert(vim.g.clipboard == false, "explicit clipboard provider changed")

vim.g.clipboard = nil
configure()
assert(vim.g.clipboard == "osc52", "SSH should use OSC 52")

vim.env.SSH_CONNECTION = nil
vim.env.SSH_TTY = "/dev/test"
vim.env.TMUX = "test"
vim.g.clipboard = nil
configure()
assert(vim.g.clipboard == "tmux" and vim.o.clipboard == "", "SSH inside tmux should use the tmux provider")

local copies = {}
vim.g.clipboard = {
  copy = {
    ["+"] = function(lines)
      copies[#copies + 1] = table.concat(lines, "\n")
    end,
  },
  paste = vim.empty_dict(),
}
vim.api.nvim_buf_set_lines(0, 0, -1, false, { "clipboard ž test", "delete me", "named register" })
vim.cmd("normal! yy")
assert(#copies == 0, "headless yank copied to clipboard")

vim.api.nvim_list_uis = function()
  return { {} }
end
vim.cmd("normal! yy")
assert(#copies == 1 and copies[1] == "clipboard ž test\n", "linewise yank did not preserve the newline")
vim.cmd('normal! jdd"ayy')
assert(#copies == 1, "delete or named yank copied to clipboard")
vim.cmd("normal! 0veyep")
assert(#copies == 2 and copies[2] == "named", "visual yank did not copy its selection")
assert(vim.api.nvim_get_current_line() == "namednamed register", "normal paste changed")

print("SSH clipboard checks passed")
