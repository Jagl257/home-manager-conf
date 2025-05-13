vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.cmd.colorscheme("dracula")

require("options")
require("telescope")
require("telescope_mappings")
require("lsp")

require("CopilotChat").setup()
