local ls = require('luasnip')
local s = ls.snippet
local fmt = require('luasnip.extras.fmt').fmt

local ls_utils = require('utils.luasnip_utils')
local dyn_sel = ls_utils.dyn_sel

return {
  s({ trig = 'tmp', desc = 'Temporary/debug code', priority = 10000 }, fmt([[
    # TODO: TMP TMP TMP {{
    {}
    # TODO: }} TMP TMP TMP
  ]], {
    dyn_sel(1, '...'),
  })),

}
