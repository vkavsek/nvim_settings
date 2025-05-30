local M = {}

local column_widths = { 0, 0, 0, 0 }

local function update_column_widths(item)
  column_widths[1] = math.max(column_widths[1], vim.api.nvim_strwidth(item.cwd))
  column_widths[2] = math.max(column_widths[2], vim.api.nvim_strwidth(item.icon))
  column_widths[3] = math.max(column_widths[3], vim.api.nvim_strwidth(item.name))
  column_widths[4] = math.max(column_widths[4], vim.api.nvim_strwidth(item.branch))
end

local function process_item(item)
  item._path = item.file
  item.branch = item.branch and ("branch:%s"):format(item.branch) or ""
  item.cwd = item.cwd and vim.fn.fnamemodify(item.cwd, ":p:~") or ""
  item.icon = item.icon or Snacks.util.icon(item.ft, "filetype")
  item.preview = { text = item.file }
  item.name = "Scratch"
  update_column_widths(item)
end

local function process_items(items)
  for _, item in ipairs(items) do
    process_item(item)
  end
end

local function format_item_text(item)
  local parts = { item.cwd, item.icon, item.name, item.branch }
  for i, part in ipairs(parts) do
    parts[i] = part .. string.rep(" ", column_widths[i] - vim.api.nvim_strwidth(part))
  end
  return table.concat(parts, " ")
end

function M.select_scratch()
  local items = Snacks.scratch.list()
  process_items(items)

  Snacks.picker.pick({
    source = "scratch",
    items = items,
    format = "text",
    layout = {
      layout = { title = " Select Scratch Buffer: " },
      preview = true,
      preset = function()
        return vim.o.columns >= 120 and "default" or "vertical"
      end,
    },
    on_change = function()
      vim.cmd.startinsert()
    end,
    transform = function(item)
      item.text = format_item_text(item)
    end,
    win = {
      input = {
        keys = {
          ["<c-x>"] = { "delete", mode = { "i", "n" } },
        },
      },
    },
    actions = {
      delete = function(picker, item)
        for _, entry in ipairs(items) do
          if entry.cwd == item.cwd then
            os.remove(item.file)
          end
        end
        picker:close()

        vim.schedule(function()
          M.select_scratch()
        end)
      end,
    },
    confirm = function(picker, item)
      if item then
        picker:close()
        Snacks.scratch.open({ icon = item.icon, file = item.file, name = item.name, ft = item.ft })
      end
    end,
  })
end

return M
