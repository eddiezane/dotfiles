local ls = require('luasnip')
local snip = ls.snippet
local node = ls.snippet_node
local text = ls.text_node
local insert = ls.insert_node
local func = ls.function_node
local choice = ls.choice_node
local dynamicn = ls.dynamic_node

local date = function() return {os.date('%Y-%m-%d')} end

local iferr = function() return {'if err != nil {\n \n}'} end

ls.add_snippets(nil, {
    go = {
      snip('pmain', {
        text({'package main', '', 'func main() {', '\t'}),
        insert(0),
        text({'', '}'})
      }),
      snip('iferr', {
        text({'if err != nil {', ''}),
        text '\t',
        insert(0),
        text({'', '}'})
      }),
      snip('for', {
        text('for '),
        insert(1),
        text({' {', '\t'}),
        insert(0),
        text({'', '}'}),
      }),
      snip('forr', {
        text('for '),
        insert(2, '_'),
        text(', '),
        insert(3, 'item'),
        text(' := range '),
        insert(1, "slice"),
        text({' {', '\t'}),
        insert(0),
        text({'', '}'})
      })
    },
})

vim.keymap.set({ "i", "s" }, "<c-j>", function()
  if ls.expand_or_jumpable() then
    ls.expand_or_jump()
  end
end, { silent = true })

vim.keymap.set({ "i", "s" }, "<c-k>", function()
  if ls.jumpable(-1) then
    ls.jump(-1)
  end
end, { silent = true })

vim.keymap.set("i", "<c-l>", function()
  if ls.choice_active() then
    ls.change_choice(1)
  end
end)

vim.keymap.set("i", "<c-u>", require "luasnip.extras.select_choice")

-- shorcut to source my luasnips file again, which will reload my snippets
vim.keymap.set("n", "<leader><leader>s", "<cmd>source ~/.config/nvim/after/plugin/luasnip.lua<CR>")
