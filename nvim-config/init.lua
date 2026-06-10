vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.cmd.colorscheme("dracula")

require("completion")
require("options")
require("treesitter")
require("telescope_config")
require("telescope_mappings")
require("neotree")
require("lsp")
