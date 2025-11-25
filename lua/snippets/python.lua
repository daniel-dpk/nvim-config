local ls = require('luasnip')
local s, sn, t, i, d = ls.snippet, ls.snippet_node, ls.text_node, ls.insert_node, ls.dynamic_node
local f, c = ls.function_node, ls.choice_node
local l = require('luasnip.extras').lambda
local dl = require('luasnip.extras').dynamic_lambda
local fmt = require('luasnip.extras.fmt').fmt
local ps = ls.parser.parse_snippet

local ls_utils = require('utils.luasnip_utils')
local dyn_args = ls_utils.dyn_args
local dyn_sel = ls_utils.dyn_sel


return {
  -- '.' -> 'self.'
  s({ trig = '.', wordTrig = false, desc = 'self.' },
    d(1, function()
      local kind = ls_utils.method_kind()
      local out = '.'
      if kind == 'classmethod' then
        out = 'cls.'
      else
        out = 'self.'
      end
      return sn(nil, { t(out) })
    end, {})
  ),

  -- 'def' -> 'def func(self) -> type:'
  s({ trig = 'def', desc = 'def func(self) -> None', priority = 10000 }, fmt([[
    def {func}({args}) -> {ret}:
    {body}
  ]], {
      func = i(1, 'func'),
      args = dyn_args(2),
      ret = i(3, 'None'),
      body = dyn_sel(4, '...', '\t'),
  }, { indent_string = '  ' })),

  s({ trig = 'm', desc = 'self.m = m' }, {
    t('self.'), i(1, 'param'), t(' = '),
    dl(2, l._1:gsub('^_', ''), 1),
  }),

  s({ trig = 'sec', desc = 'Section in docs (NumPy style)' }, fmt([[
    {title}
    {sep}
    {body}
  ]], {
    title = i(1, 'Section'),
    sep = f(function(args) return ('-'):rep(math.max(3, args[1][1]:len())) end, { 1 }),
    body = dyn_sel(2, '...'),
  })),

  s({ trig = 'sub', desc = 'Subsection in docs (NumPy style)' }, fmt([[
    {title}
    {sep}
    {body}
  ]], {
    title = i(1, 'Section'),
    sep = f(function(args) return ('~'):rep(math.max(3, args[1][1]:len())) end, { 1 }),
    body = dyn_sel(2, '...'),
  })),

  s({ trig = 'code', desc = 'code block (Sphinx style)', priority = 10000 }, fmt([[
    .. code-block:: python

    {code}
  ]], {
      code = dyn_sel(1, '...', '\t'),
  }, { indent_string = '  ' })),

  s({ trig = '$$', desc = 'LaTeX, display (Sphinx style)', priority = 10001 }, fmt([[
      .. math::

      {}
  ]], {
      dyn_sel(1, '...', '\t'),
  }, { indent_string = '  ' })),

  s({ trig = '$', desc = 'sphinx: math' }, { t(':math:`'), i(1), t('`') }),

  s({ trig = '`', desc = 'sphinx: code' }, { t('``'), i(1), t('``') }),

  s({ trig = 'lc', desc = 'link to a class (reST)', priority = 10000 }, fmt([[
    :class:`{}`
  ]], { dyn_sel(1, '...') })),

  s({ trig = 'lf', desc = 'link to a function (reST)', priority = 10000 }, fmt([[
    :func:`{}`
  ]], { dyn_sel(1, '...') })),

  s({ trig = 'lm', desc = 'link to a module (reST)', priority = 10000 }, fmt([[
    :mod:`{}`
  ]], { dyn_sel(1, '...') })),

  s({ trig = 'ld', desc = 'link to a document (reST)', priority = 10000 }, fmt([[
    :doc:`{}`
  ]], { dyn_sel(1, '...') })),

  s({ trig = 'le', desc = 'external link (reST)', priority = 10000 }, fmt([[
    `{} <{}>`_
  ]], { dyn_sel(1, '...'), i(2, 'https://...') })),

  s({ trig = 'l', desc = 'internal link (reST)', priority = 10000 }, fmt([[
    :ref:`{}{}`
  ]], {
    dyn_sel(1, '...'),
    c(2, { sn(nil, { t(' <'), i(1, 'label-name'), t('>') }), t('') }),
  })),

  s({ trig = 'tryff', desc = 'Try / Finally', priority = 10000 }, fmt([[
    try:
    {}
    finally:
      {}
  ]], {
      dyn_sel(1, '...', '\t'),
      i(2, '...'),
  }, { indent_string = '  ' })),

  s({ trig = 'tmp', desc = 'Temporary/debug code', priority = 10000 }, fmt([[
    # TODO: TMP TMP TMP {{
    {}
    # TODO: }} TMP TMP TMP
  ]], {
    dyn_sel(1, 'temp_code()'),
  })),

  ps('todo', '# TODO: ${1:...}'),

  ps('bp', 'import ipdb; ipdb.set_trace()'),
  ps('aa', 'assert ${1:arr} == approx(${2:expected})'),
  ps('aanp', 'assert ${1:arr} == approx(${2:array([${3:expected}])}${4:, abs=0})'),

  ps('raise', 'raise ${1:Runtime}Error(f"${2:Message}")'),

}
