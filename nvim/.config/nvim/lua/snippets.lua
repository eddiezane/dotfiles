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
      snip('iferr', {
        text({'if err != nil {', ''}),
        text '\t',
        insert(0),
        text({'', '}'})
      }),
    },
})

vim.keymap.set({ 'i', 's' }, "<c-k>", function()
  if ls.expand_or_jumpable() then
    ls.expand_or_jump()
  end
end)
