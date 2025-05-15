-- change the select scratch buffer keymap so that it is possible to delete the scratch buffers.

return {
  "snacks.nvim",
  keys = {
    {
      "<leader>S",
      function()
        require("utils.snacks.scratch").select_scratch()
      end,
      desc = "Select Scratch Buffer",
    },
  },
}
