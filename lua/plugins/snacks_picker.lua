-- set snacks picker to use frecency

return {
  "snacks.nvim",
  opts = {
    picker = {
      matcher = {
        frecency = true,
      },
    },
  },
}
