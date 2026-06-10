-- Native neovim 0.11+ LSP config API (replaces deprecated lspconfig framework)
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = vim.tbl_deep_extend(
  "force",
  capabilities,
  require("cmp_nvim_lsp").default_capabilities()
)

vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
  callback = function(event)
    local map = function(keys, func, desc)
      vim.keymap.set('n', keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
    end

    map('gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')
    map('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
    map('gI', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')
	map('gl', vim.diagnostic.open_float, 'Line dia[g]nostic f[lo]at')
    map('<leader>D', require('telescope.builtin').lsp_type_definitions, 'Type [D]efinition')
    map('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
    map('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')
    map('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
    map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')
    map('K', vim.lsp.buf.hover, 'Hover Documentation')
    map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
	map('<leader>lh', function()
		if vim.lsp.inlay_hint and vim.lsp.inlay_hint.is_enabled then
			vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
		end
	end, "[L]ua: toggle inlay [H]ints")

    local client = vim.lsp.get_client_by_id(event.data.client_id)
    if client and client.server_capabilities.documentHighlightProvider then
      local highlight_augroup = vim.api.nvim_create_augroup('kickstart-lsp-highlight', { clear = false })
		vim.api.nvim_create_autocmd("CursorHold", {
		  callback = function()
		    vim.diagnostic.open_float(nil, { focus = false, border = "rounded" })
		  end,
		})
      vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
        buffer = event.buf,
        group = highlight_augroup,
        callback = vim.lsp.buf.document_highlight,
      })

      vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
        buffer = event.buf,
        group = highlight_augroup,
        callback = vim.lsp.buf.clear_references,
      })

      vim.api.nvim_create_autocmd('LspDetach', {
        group = vim.api.nvim_create_augroup('kickstart-lsp-detach', { clear = true }),
        callback = function(event2)
          vim.lsp.buf.clear_references()
          vim.api.nvim_clear_autocmds { group = 'kickstart-lsp-highlight', buffer = event2.buf }
        end,
      })
    end

    if client and client.server_capabilities.inlayHintProvider and vim.lsp.inlay_hint then
      map('<leader>th', function()
        vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
      end, '[T]oggle Inlay [H]ints')
    end
  end,
})

-- Apply capabilities globally to all servers
vim.lsp.config('*', { capabilities = capabilities })

vim.lsp.config('lua_ls', {
  cmd = { "lua-language-server" },
  root_markers = { ".git", ".luarc.json", ".luacheckrc" },
  filetypes = { "lua" },
  settings = {
    Lua = {
      runtime = { version = "LuaJIT" },
      diagnostics = {
        globals = { "vim" },
      },
      workspace = {
        checkThirdParty = false,
        library = vim.api.nvim_get_runtime_file("", true),
      },
      completion = { callSnippet = "Replace" },
      hint = { enable = true },
      telemetry = { enable = false },
      format = { enable = true },
    },
  },
})
vim.lsp.enable('lua_ls')

vim.lsp.config('terraformls', {
  cmd = { 'terraform-ls', 'serve' },
  filetypes = { 'terraform', 'tf', 'hcl' },
  root_markers = { '.terraform', '.git' },
  settings = {
    terraform = {
      lint = { enable = true },
      indexing = { enable = true },
      formatting = { enable = true },
    },
  },
})
vim.lsp.enable('terraformls')

vim.lsp.config('yamlls', {
  filetypes = { 'yaml', 'yml' },
  settings = {
    yaml = {
      validate = true,
      hover = true,
      completion = true,
      schemas = {
        ['https://json.schemastore.org/github-workflow.json'] = '.github/workflows/*',
        ['https://json.schemastore.org/kubernetes.json'] = 'k8s/*.yaml',
        ['https://json.schemastore.org/ansible-playbook.json'] = 'playbooks/*.yml',
      },
    },
  },
})
vim.lsp.enable('yamlls')

vim.lsp.enable('ts_ls')

vim.lsp.config('pylsp', {})
vim.lsp.enable('pylsp')

vim.lsp.config('gopls', {})
vim.lsp.enable('gopls')

vim.lsp.config('nil_ls', {})
vim.lsp.enable('nil_ls')

pcall(function()
  vim.lsp.config('astro', {
    cmd = { "astro-ls", "--stdio" },
    filetypes = { "astro" },
    root_markers = { "package.json", "tsconfig.json", "jsconfig.json", ".git" },
  })
  vim.lsp.enable('astro')
end)