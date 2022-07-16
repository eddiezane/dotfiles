local ls = require('luasnip')

local s = ls.s

local fmt = require('luasnip.extras.fmt').fmt

local i = ls.insert_node

local rep = require('luasnip.extras').rep

ls.snippets = {
  lua = {
    ls.parser.parse_snippet('lf', 'local $1 = function($2)\n $0\nend'),
  }
}
