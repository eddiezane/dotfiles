require('nvim-lsp-installer').setup({
  automatic_installation = true,
})
local lspconfig = require('lspconfig')
local capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities())

lspconfig.gopls.setup {
  on_attach = function()
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, { buffer = 0 })
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, { buffer = 0 })
    vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, { buffer = 0 })
    vim.keymap.set('n', 'gT', vim.lsp.buf.type_definition, { buffer = 0 })
    vim.keymap.set('n', 'gI', vim.lsp.buf.implementation, { buffer = 0 })
    vim.keymap.set('n', '<f2>', vim.lsp.buf.rename, { buffer = 0 })
    vim.keymap.set('n', '<leader>[', vim.diagnostic.goto_next, { buffer = 0 })
    vim.keymap.set('n', '<leader>]', vim.diagnostic.goto_next, { buffer = 0 })

    require('lsp_signature').on_attach()
  end,
  capabilities = capabilities,
}
lspconfig.sumneko_lua.setup({
  on_attach = function()
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, { buffer = 0 })
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, { buffer = 0 })
    vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, { buffer = 0 })
    vim.keymap.set('n', 'gT', vim.lsp.buf.type_definition, { buffer = 0 })
    vim.keymap.set('n', 'gI', vim.lsp.buf.implementation, { buffer = 0 })
    vim.keymap.set('n', '<f2>', vim.lsp.buf.rename, { buffer = 0 })
    vim.keymap.set('n', '<leader>[', vim.diagnostic.goto_next, { buffer = 0 })
    vim.keymap.set('n', '<leader>]', vim.diagnostic.goto_next, { buffer = 0 })
  end,
  capabilities = capabilities,
  settings = {
    Lua = {
      diagnostics = {
        globals = { 'vim' },
      },
    },
  },
})
