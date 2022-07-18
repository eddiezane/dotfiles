vim.keymap.set('n', '<leader>l', ':setlocal list!<cr>')

vim.keymap.set('n', '<leader>w', function()
  if vim.opt.wrap:get() == true then
    vim.opt.wrap = false
    vim.opt.linebreak = false
    print('wrap off')
  else
    vim.opt.wrap = true
    vim.opt.linebreak = true
    print('wrap on')
  end
end, { desc = 'Toggle line wrapping' })

vim.keymap.set('', '<leader>/', '<plug>NERDCommenterToggle<cr>', { remap = true })
vim.keymap.set('i', '<leader>/', '<esc><plug>NERDCommenterToggle<cr>i', { remap = true })
vim.keymap.set('n', '<leader>n', '<cmd>NERDTreeToggle<cr>')

vim.keymap.set('n', '<leader>t', ':Telescope<cr>', { remap = true })
vim.keymap.set('n', '<leader>f', ':Telescope find_files<cr>', { remap = true })
