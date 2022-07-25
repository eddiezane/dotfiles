require('nvim-lsp-installer').setup({
  automatic_installation = true,
})
local lspconfig = require('lspconfig')
local capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities())

local servers = {
  clangd = {},
  rust_analyzer = {},
  pyright = {},
  gopls = {
    cmd = {
      "gopls", "-remote=auto",
    },
  },
  bashls = {},
  tsserver = {},
  yamlls = {},
  sumneko_lua = {
    settings = {
      Lua = {
        diagnostics = {
          globals = { 'vim' },
        },
      },
    },
  },
}

for lsp, config in pairs(servers) do
  local tab = {
    on_attach = function(_, bufnr)
      local bufopts = { buffer = bufnr }
      vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts)
      vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
      vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, bufopts)
      vim.keymap.set('n', 'gT', vim.lsp.buf.type_definition, bufopts)
      vim.keymap.set('n', 'gI', vim.lsp.buf.implementation, bufopts)
      vim.keymap.set('n', 'gr', vim.lsp.buf.references, bufopts)
      vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, bufopts)
      vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, bufopts)
      vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, bufopts)

      vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, bufopts)
      vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, bufopts)
      vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, bufopts)
      vim.keymap.set('n', ']d', vim.diagnostic.goto_next, bufopts)
      vim.keymap.set('n', '<leader>qf', vim.lsp.buf.formatting, bufopts)

      vim.diagnostic.config({
        update_in_insert = true,
      })

      require('lsp_signature').on_attach()

      if config['on_attach'] then
        config['on_attach']()
      end
    end,
    capabilities = capabilities,
  }
  if config['settings'] then
    tab['settings'] = config['settings']
  end
  if config['cmd'] then
    tab['cmd'] = config['cmd']
  end
  lspconfig[lsp].setup(tab)
end
