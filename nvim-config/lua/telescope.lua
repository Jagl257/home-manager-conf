local telescope = require("telescope")

telescope.setup({
  defaults = {
    layout_strategy = "horizontal",
    layout_config = {
      width = 0.9,
      height = 0.8,
    },
    sorting_strategy = "ascending",
    scroll_strategy = "cycle",
  },
})

-- Load fzf extension (optional)
pcall(function()
  telescope.load_extension("fzf")
end)
