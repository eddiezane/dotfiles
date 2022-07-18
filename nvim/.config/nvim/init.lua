require('plugins')
require('lsp')
require('completion')
require('snippets')
require('keymap')
require('dapdebug')


require('catppuccin').setup()

-- vim.cmd('colorscheme zenburn')
vim.cmd('colorscheme catppuccin')

vim.opt.number = true
vim.opt.scrolloff = 5
vim.opt.wrap = false
vim.opt.linebreak = false
vim.opt.relativenumber = true

vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.softtabstop = 2
vim.opt.tabstop = 2

vim.opt.listchars = { tab = '▸ ', eol = '¬', space = '.' }

vim.opt.laststatus = 3
vim.cmd('highlight WinSeparator guibg=None')



vim.g.NERDRemoveExtraSpaces = 1
vim.g.NERDTreeShowHidden = 1
vim.g.NERDSpaceDelims = 1

require('nvim-treesitter.configs').setup({
  ensure_installed = 'all',
  auto_install = true,
  highlight = {
    enable = true,
    additional_vim_regex_highlighting = false,
  },
  indent = {
    enable = true,
  },
})

require('lualine').setup()

require('telescope').setup({})
require('telescope').load_extension('fzf')

require("nvim-autopairs").setup {}
