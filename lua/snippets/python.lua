local ls = require('luasnip')
local s, sn, t, i, d = ls.snippet, ls.snippet_node, ls.text_node, ls.insert_node, ls.dynamic_node
local l = require("luasnip.extras").lambda
local dl = require("luasnip.extras").dynamic_lambda

local function indent_width(line)
  local indent = line:match('^%s*') or ''
  return vim.api.nvim_strwidth(indent)
end

local function fallback_method_kind()
  local cursor = vim.api.nvim_win_get_cursor(0)
  local row = cursor[1]
  if row <= 1 then return nil end

  local current = vim.api.nvim_buf_get_lines(0, row - 1, row, false)[1] or ''
  local initial_indent = indent_width(current)
  local target_indent = initial_indent
  local decorator = nil

  for idx = row - 2, 0, -1 do
    local line = vim.api.nvim_buf_get_lines(0, idx, idx + 1, false)[1]
    if not line then break end
    if line:match('%S') then
      local indent = indent_width(line)
      if indent <= target_indent then
        target_indent = indent
        local trimmed = vim.trim(line)
        if indent < initial_indent then
          if trimmed:match('^@classmethod') then
            decorator = 'classmethod'
          elseif trimmed:match('^@staticmethod') then
            decorator = 'staticmethod'
          elseif trimmed:match('^def%s+') then
            local params = trimmed:match('%(([^)]*)')
            local first = ''
            if params then
              first = params:match('^%s*([^,%s]+)') or ''
            end
            if decorator == 'classmethod' or first == 'cls' then return 'classmethod' end
            if decorator == 'staticmethod' then return 'function' end
            if first == 'self' then return 'instance' end
            return 'function'
          elseif trimmed:match('^class%s+') then
            return 'classbody'
          end
        else
          if trimmed:match('^class%s+') then return 'classbody' end
        end
      end
    end
  end

  return nil
end

local function method_kind()
  local ok = pcall(vim.treesitter.get_parser, 0, 'python')
  if not ok then return fallback_method_kind() or 'module' end

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
      local txt = (vim.treesitter.get_node_text(params, 0) or ''):gsub('^%(', ''):gsub('%)$', '')
      local first = (vim.split(txt, ',', { trimempty = true })[1] or '')
      first = vim.trim(first:gsub(':.*', ''):gsub('=.*', ''))
      if first == 'self' then return 'instance' end
      if first == 'cls' then return 'classmethod' end
    end
    return 'function'
  end

  local fallback = fallback_method_kind()
  if fallback then return fallback end
  return in_class and 'classbody' or 'module'
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
      return sn(nil, { t(out) })
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
      table.insert(nodes, t({ ':', '\t' }))
      table.insert(nodes, i(4, '...'))
      return sn(nil, nodes)
    end)
  ),

  s({ trig = "m", desc = "self.m = m" }, {
    t('self.'), i(1, 'param'), t(' = '),
    dl(2, l._1:gsub("^_", ""), 1),
  }),
}
