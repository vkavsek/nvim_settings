-- Run from the config directory: nvim --headless -u NONE -i NONE -l tests/wsl.lua
local original = {
  has = vim.fn.has,
  executable = vim.fn.executable,
  exepath = vim.fn.exepath,
  system = vim.system,
  open = vim.ui.open,
  clipboard = vim.g.clipboard,
  ssh = vim.env.SSH_CONNECTION,
  ssh_tty = vim.env.SSH_TTY,
}

local calls, native_calls, conversion, spawn_error
local process = {
  wait = function()
    return { code = 0 }
  end,
}
local function native_open(path, opts)
  native_calls[#native_calls + 1] = { path, opts }
  return process, "native result"
end

local function configure(opts)
  opts = opts or {}
  calls, native_calls = {}, {}
  conversion = { code = 0, stdout = "C:\\path with spaces\\árvíz.txt\n", stderr = "" }
  spawn_error = nil
  vim.fn.has = function(feature)
    if feature == "wsl" then
      return opts.wsl == false and 0 or 1
    end
    return original.has(feature)
  end
  local tools = opts.tools or { ["powershell.exe"] = true, wslpath = true }
  vim.fn.executable = function(cmd)
    return tools[cmd] and 1 or 0
  end
  vim.fn.exepath = function(cmd)
    return tools[cmd] and "/tools/" .. cmd or ""
  end
  vim.env.SSH_CONNECTION = opts.ssh
  vim.env.SSH_TTY = opts.ssh_tty
  vim.g.clipboard = opts.clipboard
  vim.ui.open = native_open
  vim.system = function(cmd, job_opts)
    calls[#calls + 1] = { cmd = cmd, opts = job_opts }
    if spawn_error then
      error(spawn_error)
    end
    if cmd[1] == "wslpath" then
      return {
        wait = function()
          return conversion
        end,
      }
    end
    return process
  end
  dofile("lua/config/wsl.lua")
end

local function script(cmd)
  assert(cmd[1] == "powershell.exe" and cmd[5] == "-EncodedCommand")
  return vim.iconv(vim.base64.decode(cmd[6]), "utf-16le", "utf-8")
end

local function check()
  for _, opts in ipairs({ { wsl = false }, { ssh = "remote connection" }, { ssh_tty = "/dev/pts/1" } }) do
    configure(opts)
    assert(vim.g.clipboard == nil and vim.ui.open == native_open, "native/SSH behavior changed")
  end
  configure({ tools = {} })
  assert(vim.g.clipboard == nil and vim.ui.open == native_open, "missing tools changed defaults")

  configure({ tools = { ["win32yank.exe"] = true } })
  assert(vim.g.clipboard.name == "WSL win32yank")
  assert(vim.deep_equal(vim.g.clipboard.copy["+"], { "/tools/win32yank.exe", "-i", "--crlf" }))
  assert(vim.deep_equal(vim.g.clipboard.paste["*"], { "/tools/win32yank.exe", "-o", "--lf" }))
  assert(vim.ui.open == native_open, "opener needs PowerShell and wslpath")

  configure({ tools = { ["win32yank.exe"] = true, ["powershell.exe"] = true, wslpath = true } })
  assert(vim.g.clipboard.name == "WSL win32yank", "win32yank should take precedence")

  configure({ tools = { ["powershell.exe"] = true } })
  assert(vim.g.clipboard.name == "WSL PowerShell" and vim.ui.open == native_open)
  assert(script(vim.g.clipboard.copy["+"]):find("[Console]::In.ReadToEnd()", 1, true))
  assert(script(vim.g.clipboard.paste["+"]):find("Get-Clipboard -Raw", 1, true))
  assert(script(vim.g.clipboard.paste["+"]):find("$ProgressPreference = 'SilentlyContinue'", 1, true))
  assert(vim.deep_equal(vim.g.clipboard.copy["+"], vim.g.clipboard.copy["*"]))
  assert(vim.deep_equal(vim.g.clipboard.paste["+"], vim.g.clipboard.paste["*"]))
  assert(vim.g.clipboard.cache_enabled == 0, "external clipboard changes must be visible")

  for _, clipboard in ipairs({ "osc52", false, { name = "custom provider" } }) do
    configure({ clipboard = clipboard })
    assert(vim.deep_equal(vim.g.clipboard, clipboard), "explicit clipboard override changed")
  end

  for _, target in ipairs({
    "https://example.com/?a=1&b=2#fragment",
    "https://example.com/árvíz?q=';$env:TEMP;$(Get-Date)`\"",
    "mailto:someone@example.com",
    "C:\\Program Files\\app\\file.txt",
    "\\\\server\\share\\file.txt",
  }) do
    configure()
    local result, err = vim.ui.open(target)
    assert(result == process and err == nil, "opener return contract changed")
    assert(#calls == 1 and calls[1].opts.detach, "URI/Windows path should open directly")
    assert(
      script(calls[1].cmd)
        == "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue'; Start-Process -FilePath '"
          .. target:gsub("'", "''")
          .. "'",
      "target must be a literal PowerShell string"
    )
  end

  configure()
  assert(vim.ui.open("./path with spaces/árvíz's.txt") == process)
  assert(calls[1].cmd[1] == "wslpath" and calls[1].cmd[2] == "-w")
  assert(calls[1].cmd[3] == vim.fn.getcwd() .. "/path with spaces/árvíz's.txt")
  assert(script(calls[2].cmd):find("'C:\\path with spaces\\árvíz.txt'", 1, true))

  configure()
  local opts = { cmd = { "custom-opener", "--flag" } }
  local result, err = vim.ui.open("./file", opts)
  assert(result == process and err == "native result" and #calls == 0)
  assert(native_calls[1][1] == "./file" and native_calls[1][2] == opts)

  configure()
  conversion = { code = 1, stderr = "cannot translate path", stdout = "" }
  result, err = vim.ui.open("./file")
  assert(result == nil and err:find("cannot translate path", 1, true) and #calls == 1)

  for _, target in ipairs({ "./file", "https://example.com" }) do
    configure()
    spawn_error = "interop unavailable"
    result, err = vim.ui.open(target)
    assert(result == nil and err:find("interop unavailable", 1, true), "spawn failure was hidden")
  end
end

local ok, err = xpcall(check, debug.traceback)
vim.fn.has = original.has
vim.fn.executable = original.executable
vim.fn.exepath = original.exepath
vim.system = original.system
vim.ui.open = original.open
vim.g.clipboard = original.clipboard
vim.env.SSH_CONNECTION = original.ssh
vim.env.SSH_TTY = original.ssh_tty
assert(ok, err)
print("WSL configuration checks passed")
