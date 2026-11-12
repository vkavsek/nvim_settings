if vim.fn.has("wsl") ~= 1 or vim.env.SSH_CONNECTION or vim.env.SSH_TTY then
  return
end

local function powershell(script)
  -- Neovim's clipboard provider merges stderr, including PowerShell's CLIXML progress, into pasted text.
  script = "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue'; " .. script
  return {
    "powershell.exe",
    "-NoLogo",
    "-NoProfile",
    "-NonInteractive",
    "-EncodedCommand",
    vim.base64.encode(vim.iconv(script, "utf-8", "utf-16le")),
  }
end

local has_powershell = vim.fn.executable("powershell.exe") == 1
if vim.g.clipboard == nil then
  local copy, paste, name
  local win32yank = vim.fn.exepath("win32yank.exe")
  if win32yank ~= "" then
    win32yank = vim.fn.resolve(win32yank)
    copy = { win32yank, "-i", "--crlf" }
    paste = { win32yank, "-o", "--lf" }
    name = "WSL win32yank"
  elseif has_powershell then
    copy = powershell([[
      [Console]::InputEncoding = [System.Text.UTF8Encoding]::new($false)
      $text = [Console]::In.ReadToEnd()
      if ($text.Length) {
        Set-Clipboard -Value $text
      } else {
        Add-Type -AssemblyName System.Windows.Forms
        [System.Windows.Forms.Clipboard]::Clear()
      }
    ]])
    paste = powershell([[
      [Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)
      [Console]::Out.Write(([string](Get-Clipboard -Raw)).Replace("`r`n", "`n"))
    ]])
    name = "WSL PowerShell"
  end
  if copy then
    vim.g.clipboard = {
      name = name,
      copy = { ["+"] = copy, ["*"] = copy },
      paste = { ["+"] = paste, ["*"] = paste },
      cache_enabled = 0,
    }
  end
end

if not has_powershell or vim.fn.executable("wslpath") ~= 1 then
  return
end

local open = vim.ui.open
vim.ui.open = function(path, opts)
  if opts and opts.cmd then
    return open(path, opts)
  end
  vim.validate("path", path, "string")

  -- Windows paths and URIs already have a scheme/drive or a UNC prefix.
  if not path:match("^%a[%w+.-]*:") and not path:match("^[/\\][/\\]") then
    local ok, process = pcall(vim.system, {
      "wslpath",
      "-w",
      vim.fn.fnamemodify(vim.fs.normalize(path), ":p"),
    }, { text = true })
    if not ok then
      return nil, "vim.ui.open: " .. tostring(process)
    end
    local result = process:wait()
    if result.code ~= 0 then
      return nil, "vim.ui.open: wslpath failed: " .. result.stderr
    end
    path = result.stdout:gsub("\r?\n$", "")
  end

  local ok, process = pcall(vim.system, powershell("Start-Process -FilePath '" .. path:gsub("'", "''") .. "'"), {
    text = true,
    detach = true,
  })
  if not ok then
    return nil, "vim.ui.open: " .. tostring(process)
  end
  return process, nil
end
