-- nvim-config/lua/neotree.lua
-- Disable netrw (recommended when using file explorers)
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

require("neo-tree").setup({
  sources = { "filesystem", "buffers", "git_status" },
  default_component_configs = {
    indent = { padding = 1 },
    icon = { folder_closed = "", folder_open = "", folder_empty = "" },
    git_status = { symbols = { added = "✚", modified = "", deleted = "✖", renamed = "" } },
  },
  filesystem = {
    follow_current_file = { enabled = true },
    use_libuv_file_watcher = true,
    hijack_netrw_behavior = "open_current",
    filtered_items = {
      hide_dotfiles = false,
      hide_gitignored = true,
    },
  },
  window = {
    width = 34,
    mappings = {
      ["<space>"] = "toggle_node",
      ["<cr>"] = "open",
      ["l"] = "open",
      ["h"] = "close_node",
      ["s"] = "open_split",
      ["v"] = "open_vsplit",
    },
  },
})

-- Keymaps
vim.keymap.set("n", "<leader>e", "<cmd>Neotree toggle<CR>", { silent = true, desc = "Neo-tree: Toggle" })
vim.keymap.set("n", "<leader>o", "<cmd>Neotree focus<CR>",  { silent = true, desc = "Neo-tree: Focus" })
