local M = {
  _cfg = {
    output = 'append',
    python = 'python3',
  },
}

local result_prefix = '__NVIM_CALC_RESULT__\n'

local python_runner = [[
import ast
import contextlib
import io
import sys
import textwrap

namespace = {
    "__builtins__": __builtins__,
    "__name__": "__calc__",
}
exec("from math import *", namespace)

source = textwrap.dedent(sys.stdin.read())
tree = ast.parse(source, filename="<calc>", mode="exec")
last = tree.body[-1] if tree.body else None

if isinstance(last, ast.Expr):
    prefix = ast.Module(body=tree.body[:-1], type_ignores=[])
    prefix_code = compile(prefix, "<calc>", "exec")
    result_code = compile(ast.Expression(last.value), "<calc>", "eval")
    with contextlib.redirect_stdout(io.StringIO()):
        exec(prefix_code, namespace)
        result = eval(result_code, namespace)
        output = str(result)
    sys.stdout.write("__NVIM_CALC_RESULT__\n" + output)
else:
    with contextlib.redirect_stdout(io.StringIO()):
        exec(compile(tree, "<calc>", "exec"), namespace)
]]

local function notify_error(msg)
  vim.notify(msg, vim.log.levels.ERROR, { title = 'calc' })
end

local function normalize_output_mode(arg)
  local desired = arg
  if type(arg) == 'table' then desired = arg.output end
  if desired == 'replace' or desired == 'append' or desired == 'below' then
    return desired
  end
  return M._cfg.output or 'append'
end

local function evaluate(source)
  local python = vim.fn.exepath(M._cfg.python)
  if python == '' then
    return nil, 'could not find ' .. M._cfg.python .. ' in PATH'
  end

  local result = vim.system(
    { python, '-c', python_runner },
    { stdin = source, text = true }
  ):wait()

  if result.code ~= 0 then
    local err = vim.trim(result.stderr or '')
    if err == '' then err = 'python exited with status ' .. result.code end
    return nil, err
  end

  local output = result.stdout or ''
  if output:sub(1, #result_prefix) ~= result_prefix then
    return nil, 'python code did not end with an expression'
  end

  return output:sub(#result_prefix + 1), nil
end

local function split_result(result)
  return vim.split(result, '\n', { plain = true })
end

local function prefixed_lines(lines, prefix, first)
  local result = {}
  for i, line in ipairs(lines) do
    result[i] = (i == 1 and not first) and line or prefix .. line
  end
  return result
end

local function strip_comment(source)
  local before, after = vim.bo.commentstring:match('^(.-)%%s(.-)$')
  if not before then return source end

  before = vim.trim(before)
  after = vim.trim(after)
  if before == '' or not vim.startswith(source, before) then
    return source
  end

  local body = vim.trim(source:sub(#before + 1))
  if after ~= '' then
    if not vim.endswith(body, after) then return source end
    body = vim.trim(body:sub(1, #body - #after))
  end
  return body
end

local function byte_after_position(bufnr, pos)
  local row = pos[2] - 1
  local line = vim.api.nvim_buf_get_lines(bufnr, row, row + 1, true)[1]
    or ''
  local col = math.max(pos[3] - 1, 0)
  if col >= #line then return #line end

  local byte = line:byte(col + 1)
  local width = 1
  if byte >= 0xF0 then
    width = 4
  elseif byte >= 0xE0 then
    width = 3
  elseif byte >= 0xC0 then
    width = 2
  end
  return math.min(col + width, #line)
end

local function get_line_selection()
  local bufnr = vim.api.nvim_get_current_buf()
  local row = vim.api.nvim_win_get_cursor(0)[1] - 1
  local line = vim.api.nvim_buf_get_lines(bufnr, row, row + 1, true)[1]
  if not line then return nil end

  local indent = line:match('^%s*') or ''
  local source = strip_comment(vim.trim(line))
  if source == '' then return nil end

  return {
    bufnr = bufnr,
    source = source,
    indent = indent,
    start_row = row,
    start_col = #indent,
    end_row = row,
    end_col = #line,
  }
end

local visual_types = {
  s = 'v',
  S = 'V',
  ['\019'] = '\022',
}

local function get_visual_selection()
  local mode = vim.fn.mode()
  local visual_type = visual_types[mode] or mode
  local start_pos = vim.fn.getpos('v')
  local end_pos = vim.fn.getpos('.')
  local opts = {
    type = visual_type,
    exclusive = false,
    eol = true,
  }
  local lines = vim.fn.getregion(start_pos, end_pos, opts)
  local positions = vim.fn.getregionpos(start_pos, end_pos, opts)
  if #lines == 0 or #positions == 0 then return nil end

  local bufnr = vim.api.nvim_get_current_buf()
  local first = positions[1][1]
  local last = positions[#positions][2]
  local first_line = vim.api.nvim_buf_get_lines(
    bufnr,
    first[2] - 1,
    first[2],
    true
  )[1] or ''

  vim.cmd("normal! \\<Esc>")

  return {
    bufnr = bufnr,
    source = table.concat(lines, '\n'),
    indent = first_line:match('^%s*') or '',
    visual_type = visual_type,
    positions = positions,
    start_row = first[2] - 1,
    start_col = math.max(first[3] - 1, 0),
    end_row = last[2] - 1,
    end_col = byte_after_position(bufnr, last),
  }
end

local function apply_below(selection, lines)
  local output = prefixed_lines(lines, selection.indent, true)
  vim.api.nvim_buf_set_lines(
    selection.bufnr,
    selection.end_row + 1,
    selection.end_row + 1,
    true,
    output
  )
end

local function apply_append(selection, lines)
  local output = { ' = ' .. lines[1] }
  for i = 2, #lines do
    output[i] = selection.indent .. lines[i]
  end
  vim.api.nvim_buf_set_text(
    selection.bufnr,
    selection.end_row,
    selection.end_col,
    selection.end_row,
    selection.end_col,
    output
  )
end

local function apply_block_replace(selection, lines)
  for i = #selection.positions, 1, -1 do
    local segment = selection.positions[i]
    local start_pos = segment[1]
    local end_pos = segment[2]
    local row = start_pos[2] - 1
    vim.api.nvim_buf_set_text(
      selection.bufnr,
      row,
      math.max(start_pos[3] - 1, 0),
      row,
      byte_after_position(selection.bufnr, end_pos),
      {}
    )
  end

  local output = prefixed_lines(lines, selection.indent, false)
  vim.api.nvim_buf_set_text(
    selection.bufnr,
    selection.start_row,
    selection.start_col,
    selection.start_row,
    selection.start_col,
    output
  )
end

local function apply_replace(selection, lines)
  if selection.visual_type == '\022' then
    apply_block_replace(selection, lines)
    return
  end

  local output = lines
  if selection.visual_type == 'V' then
    output = prefixed_lines(lines, selection.indent, true)
  elseif #lines > 1 then
    output = prefixed_lines(lines, selection.indent, false)
  end
  vim.api.nvim_buf_set_text(
    selection.bufnr,
    selection.start_row,
    selection.start_col,
    selection.end_row,
    selection.end_col,
    output
  )
end

local function apply_result(selection, result, mode)
  local lines = split_result(result)
  if mode == 'below' then
    apply_below(selection, lines)
  elseif mode == 'append' then
    apply_append(selection, lines)
  else
    apply_replace(selection, lines)
  end
end

local function evaluate_selection(selection, opts)
  if not selection then
    notify_error('calc did not find code to evaluate')
    return
  end

  local result, err = evaluate(selection.source)
  if result == nil then
    notify_error('calc evaluation error: ' .. tostring(err))
    return
  end

  apply_result(selection, result, normalize_output_mode(opts))
end

function M.evaluate_visual(opts)
  evaluate_selection(get_visual_selection(), opts)
end

function M.evaluate_line(opts)
  evaluate_selection(get_line_selection(), opts)
end

function M.setup(opts)
  opts = opts or {}
  if opts.output == 'replace'
      or opts.output == 'append'
      or opts.output == 'below' then
    M._cfg.output = opts.output
  end
  if opts.python and opts.python ~= '' then
    M._cfg.python = opts.python
  end
end

return M
