local ls = require('luasnip')
local s, sn, t, i, d = ls.snippet, ls.snippet_node, ls.text_node, ls.insert_node, ls.dynamic_node
local l = require("luasnip.extras").lambda
local dl = require("luasnip.extras").dynamic_lambda

local function method_kind()
  local ok = pcall(vim.treesitter.get_parser, 0, "python")
  if not ok then return "module" end

  local node = vim.treesitter.get_node()
  local in_class = false
  local func = nil

  while node do
    local tp = node:type()
    if not func and tp == 'function_definition' then func = node end
    if tp == 'class_definition' then in_class = true end
    node = node:parent()
  end

  if func then
    local params = func:field('parameters')[1]
    if params then
      local txt = (vim.treesitter.get_node_text(params, 0) or ""):gsub("^%(", ""):gsub("%)$", "")
      local first = (vim.split(txt, ",", { trimempty = true })[1] or "")
      first = vim.trim(first:gsub(":.*", ""):gsub("=.*", ""))
      if first == "self" then return "instance" end
      if first == "cls" then return "classmethod" end
    end
    return "function"
  end
  return in_class and "classbody" or "module"
end

return {
  -- "." -> "self."
  s({ trig = ".", wordTrig = false, desc = "self." },
    d(1, function()
      local kind = method_kind()
      local out = '.'
      if kind == 'instance' then
        out = 'self.'
      elseif kind == 'classmethod' then
        out = 'cls.'
      end
      return sn(nil, {t(out)})
    end, {})
  ),

  -- "def" -> "def func(self) -> type:"
  s({ trig = "def", desc = "def func(self) -> None", priority = 10000 },
    d(1, function()
      local kind = method_kind()
      local nodes = {}
      table.insert(nodes, t('def '))
      table.insert(nodes, i(1, 'func'))
      table.insert(nodes, t('('))
      if kind == 'classbody' then
        table.insert(nodes, t('self'))
      end
      table.insert(nodes, i(2, ''))
      table.insert(nodes, t(') -> '))
      table.insert(nodes, i(3, 'None'))
      table.insert(nodes, t({':', '\t'}))
      table.insert(nodes, i(4, '...'))
      return sn(nil, nodes)
    end)
  ),

  s({ trig = "m", desc = "self.m = m" }, {
    t('self.'), i(1, 'param'), t(' = '),
    dl(2, l._1:gsub("^_", ""), 1),
  }),
}
