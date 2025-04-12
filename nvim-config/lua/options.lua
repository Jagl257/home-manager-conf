vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

vim.opt.number = true

vim.opt.clipboard = 'unnamedplus'

vim.opt.breakindent = true


vim.opt.termguicolors = true

vim.cmd.colorscheme("dracula")

vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

vim.api.nvim_create_autocmd('FileType', {
	pattern = { 'lua', 'javascript', 'typescript', 'yaml', 'nix', 'terraform', 'json', 'tf' },
	callback = function()
		vim.bo.tabstop = 2
		vim.bo.softtabstop = 2
		vim.bo.shiftwidth = 2
	end,
})

vim.api.nvim_create_autocmd('FileType', {
	pattern = { 'python' },
	callback = function()
		vim.bo.tabstop = 4
		vim.bo.softtabstop = 4
		vim.bo.shiftwidth = 4
	end,
})
