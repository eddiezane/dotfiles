vim.keymap.set('n', '<leader>l', ':setlocal list!<cr>')

vim.keymap.set('n', '<leader>w', function()
  vim.api.nvim_command('set wrap!')
  vim.api.nvim_command('set linebreak!')
end, { desc = 'Toggle line wrapping' })

vim.keymap.set('', '<leader>/', '<plug>NERDCommenterToggle<cr>', { remap = true })
vim.keymap.set('i', '<leader>/', '<esc><plug>NERDCommenterToggle<cr>i', { remap = true })
vim.keymap.set('n', '<leader>n', '<cmd>NERDTreeToggle<cr>')

vim.keymap.set('n', '<leader>t', ':Telescope<cr>', { remap = true })
vim.keymap.set('n', '<leader>f', ':Telescope find_files<cr>', { remap = true })
