-- local embedded_sql = vim.treesitter.query.parse(
--   "rust",
--   [[
-- (call_expression
--   (scoped_identifier
--     path: (identifier) @path (#eq? @path "sqlx")
--     name: (identifier) @name (#eq? @name "query")
--   )
--   (arguments
--     (raw_string_literal) @sql)
--     (#offset! @sql 1 0 -1 0)
-- )
-- ]]
-- )
--
-- local get_root = function(bufnr)
--   local parser = vim.treesitter.get_parser(bufnr, "rust", {})
--   local tree = parser:parse()[1]https://neovim.io/doc/user/options.html#option-summary
--   return tree:root()
-- end
--
-- local format_dat_sql = function(bufnr)
--   bufnr = bufnr or vim.api.nvim_get_current_buf()
--
--   if vim.bo[bufnr].filetype ~= "rust" then
--     vim.notify("can only be used in Rust")
--     return
--   end
--
--   local root = get_root(bufnr)
--
--   local changes = {}
--
--   for id, node in embedded_sql:iter_captures(root, bufnr, 0, -1) do
--     local name = embedded_sql.captures[id]
--     if name == "sql" then
--       -- {start row, start col, end row, end col }
--       local range = { node:range() }
--       local indentation = string.rep(" ", range[2])
--
--       -- Run the formatter based on the node text
--       -- local formatter = run_formatter()
--     end
--   end
-- end
--
return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      if type(opts.ensure_installed) == "table" then
        vim.list_extend(opts.ensure_installed, { "sql" })
      end
    end,
  },
}
