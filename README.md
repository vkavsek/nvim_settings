# 💤 LazyVim

Personal NEOVIM configuration using starter template for [LazyVim](https://github.com/LazyVim/LazyVim).
Refer to the [documentation](https://lazyvim.github.io/installation).

## Clipboard over SSH

Restart Neovim in your SSH session, yank with `yy` or Visual mode `y`, then
paste into an app on your local machine. Your local terminal needs OSC 52
clipboard writes enabled. Inside tmux, Neovim uses tmux's clipboard command
(tmux 3.2+). Normal `p` still pastes from Neovim's registers. To paste from the
local clipboard, use your terminal's paste shortcut in Insert mode.

If copying from a tmux pane on the SSH host fails, run `tmux info | rg 'Ms:'`
in that pane. If `Ms` is missing, add
`set -as terminal-features ',YOUR_TERM:clipboard'` to your tmux config. Replace
`YOUR_TERM` with the value of `$TERM` from outside that tmux server. Run
`tmux source-file ~/.tmux.conf` and reattach. If you launched SSH from tmux on
your local machine, its configuration needs `set -s set-clipboard on` and a
working `Ms` capability to forward OSC 52. [tmux clipboard documentation](https://github.com/tmux/tmux/wiki/Clipboard)

Run `nvim --headless -u NONE -i NONE -l tests/ssh_clipboard.lua` from this
configuration directory to check the SSH clipboard behavior.

## Clipboard and opening links on WSL

Local WSL sessions use the Windows clipboard for ordinary yanks and pastes.
An existing `win32yank.exe` on PATH is preferred; otherwise the built-in
`powershell.exe` handles copying and pasting, including Unicode text. PowerShell
can be slower than win32yank. Explicit `vim.g.clipboard` settings are respected.

`gx` in normal or visual mode opens links and files with their Windows default
application. This uses `powershell.exe` and `wslpath` on PATH, translating Linux
paths to Windows paths automatically. Plugins using `vim.ui.open` share this
behavior; explicit custom opener commands are respected.

Restart Neovim after updating the configuration. The Windows integration applies
to local WSL sessions when the necessary tools are available. Windows interop
must be enabled in WSL.
No additional plugin or utility installation is required.

Diagnostics in Neovim:

- `:set clipboard?` should show `unnamedplus` in a local session.
- `:lua print(vim.fn['provider#clipboard#Executable']())` shows the active provider.
- `:checkhealth vim.provider` checks clipboard support.
- `:lua print(vim.fn.executable('powershell.exe'), vim.fn.executable('wslpath'))`
  should print `1 1` for the WSL opener. If PowerShell is missing, check Windows
  interop and Windows PATH inheritance in WSL; its directory must be on PATH.
- `:lua local p, e = vim.ui.open('https://neovim.io'); print(e or vim.inspect(p:wait()))`
  opens a test URL and reports the opener result.

Run the host-independent checks from this configuration directory:

```sh
nvim --headless -u NONE -i NONE -l tests/wsl.lua
```

## Justfiles

[vim-just](https://github.com/NoahTheDuke/vim-just) provides syntax highlighting
and loads automatically for the `just` filetype.

## Markdown linting

Markdown line length is unlimited in Neovim: `.markdownlint.jsonc` disables
MD013 for both linting and formatting. Project configs can override this default.
Restart Neovim after changing the plugin configuration.

## blink.cmp (snippets) notes

Currently uses blink.cmp for snippets.
By default, blink.cmp checks `$NEOVIM_CONFIG_DIR/snippets/` for custom snippets
so this is where they are currently located.

For more info go to [blink.cmp documentation](https://cmp.saghen.dev/configuration/snippets.html) and [VsCode snippets reference](https://code.visualstudio.com/docs/editing/userdefinedsnippets).
