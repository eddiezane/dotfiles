local luasnip = require('luasnip')
local snip = luasnip.snippet
local node = luasnip.snippet_node
local text = luasnip.text_node
local insert = luasnip.insert_node
local func = luasnip.function_node
local choice = luasnip.choice_node
local dynamicn = luasnip.dynamic_node

luasnip.add_snippets(nil, {
    go = {
      snip({
          trig = 'pmain',
          name = 'init package main',
          dscr = 'Initialize a new main package with a main func',
      }, {
        text({'package main', '', 'func main() {', '\t'}),
        insert(0),
        text({'', '}'})
      }),
      snip({
          trig = 'iferr',
          name = 'if error',
          dscr = 'if statement to handle err'
      }, {
        text({'if err != nil {', ''}),
        text '\t',
        insert(0),
        text({'', '}'})
      }),
      snip({
          trig = 'iferrp',
          name = 'if error panic',
          dscr = 'if statement to panic an error'
      }, {
        text({'if err != nil {', ''}),
        text '\t',
        text 'panic(err)',
        text({'', '}'})
      }),
    },
})
