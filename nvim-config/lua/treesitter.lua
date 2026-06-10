-- nvim-treesitter v0.10+ removed the configs module.
-- Highlight and indent are now handled via neovim's built-in vim.treesitter.
-- Parsers are pre-bundled via Nix - no auto_install/ensure_installed needed.
vim.api.nvim_create_autocmd('FileType', {
  callback = function(args)
    local buf = args.buf
    pcall(vim.treesitter.start, buf)
    pcall(function()
      vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
    end)
  end,
})