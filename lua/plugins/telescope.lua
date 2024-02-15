-- plugins/telescope.lua:
return {
  "nvim-telescope/telescope.nvim",
  tag = "0.1.x",
  -- or                              , branch = '0.1.x',
  dependencies = { "nvim-lua/plenary.nvim" },
  -- add telescope-fzf-native
  --
  {
    "telescope.nvim",
    dependencies = {
      "nvim-telescope/telescope-fzf-native.nvim",
      build = "make",
      config = function()
        require("telescope").load_extension("fzf")
      end,
    },
  },
}
