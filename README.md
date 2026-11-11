# 💤 LazyVim

Personal NEOVIM configuration using starter template for [LazyVim](https://github.com/LazyVim/LazyVim).
Refer to the [documentation](https://lazyvim.github.io/installation).

## Markdown linting

Markdown line length is unlimited in Neovim: `.markdownlint.jsonc` disables
MD013 for both linting and formatting. Project configs can override this default.
Restart Neovim after changing the plugin configuration.

## blink.cmp (snippets) notes

Currently uses blink.cmp for snippets.
By default, blink.cmp checks `$NEOVIM_CONFIG_DIR/snippets/` for custom snippets
so this is where they are currently located.

For more info go to [blink.cmp documentation](https://cmp.saghen.dev/configuration/snippets.html) and [VsCode snippets reference](https://code.visualstudio.com/docs/editing/userdefinedsnippets).
