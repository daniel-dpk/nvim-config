local ls = require('luasnip')
local s = ls.snippet
local sn = ls.snippet_node
local t = ls.text_node
local i = ls.insert_node
local c = ls.choice_node
local fmta = require('luasnip.extras.fmt').fmta
local rep = require('luasnip.extras').rep

local ls_utils = require('utils.luasnip_utils')
local dyn_sel = ls_utils.dyn_sel

return {
  s({ trig = 'todo', desc = '\\todo{...}' }, fmta([[
    \todo{<>}
  ]], { dyn_sel(1, '...') })),

  s({ trig = 'todo:', desc = '\\todo{...}' }, fmta([[
    % TODO: <>
  ]], { dyn_sel(1, '...') })),

  s({ trig = 'up', desc = '\\usepackage{...}' }, fmta([[
    \usepackage<>{<>}
  ]], {
    c(1, { sn(nil, { t('['), i(1), t(']') }), t('') }),
    dyn_sel(2, '...'),
  })),

  s({ trig = 'enum', desc = 'enumerate block' }, fmta([[
    \begin{enumerate}
      \item <>
    \end{enumerate}
  ]], { dyn_sel(1) }, { indent_string = '  ' })),

  s({ trig = 'item', desc = 'itemize block', priority = 1000 }, fmta([[
    \begin{itemize}
      \item <>
    \end{itemize}
  ]], { dyn_sel(1) }, { indent_string = '  ' })),

  s({ trig = 'i', desc = '\\item ...', priority = 99 }, fmta([[
    \item <>
  ]], { dyn_sel(1) })),

  s({ trig = 'big(' }, fmta('\\big( <> \\big)', { dyn_sel(1) })),
  s({ trig = 'big[' }, fmta('\\big[ <> \\big]', { dyn_sel(1) })),
  s({ trig = 'big{' }, fmta('\\big\\{ <> \\big\\}', { dyn_sel(1) })),
  s({ trig = 'Big(' }, fmta('\\Big( <> \\Big)', { dyn_sel(1) })),
  s({ trig = 'Big[' }, fmta('\\Big[ <> \\Big]', { dyn_sel(1) })),
  s({ trig = 'Big{' }, fmta('\\Big\\{ <> \\Big\\}', { dyn_sel(1) })),

  s({ trig = 'lr<' }, fmta('\\langle <> \\rangle', { dyn_sel(1) })),

  s({ trig = 'fr', desc = '\\frac{}{}' }, fmta('\\frac{<>}{<>}', {
    dyn_sel(1), i(2)
  })),

  s({ trig = 'tfr', desc = '\\tfrac{}{}' }, fmta('\\tfrac{<>}{<>}', {
    dyn_sel(1), i(2)
  })),

  s({ trig = 'b', desc = 'begin-end block', priority = 1000 }, fmta([[
    \begin{<>}
      <>
    \end{<>}
  ]], { i(1), dyn_sel(2), rep(1) }, { indent_string = '  ' })),

  s({ trig = 'eq', desc = 'Equation', priority = 1000 }, fmta([[
    \begin{equation}\label{eq:<>}
      <>
    \end{equation}
  ]], { i(1, 'name'), dyn_sel(2) }, { indent_string = '  ' })),

  s({ trig = 'eq*', desc = 'Equation', priority = 1001 }, fmta([[
    \begin{equation*}
      <>
    \end{equation*}
  ]], { dyn_sel(1) }, { indent_string = '  ' })),

}
