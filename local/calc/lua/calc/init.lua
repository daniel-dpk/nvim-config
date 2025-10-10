local M = {
  _cfg = {
    output = 'append',
    debug = false,
  },
}

local function factorial(n)
  if type(n) ~= 'number' then
    error('factorial expects a number')
  end
  if n < 0 then
    error('factorial undefined for negative numbers')
  end
  if n % 1 ~= 0 then
    error('factorial expects an integer')
  end
  local result = 1
  for i = 2, n do
    result = result * i
  end
  return result
end

local function debug_log(...)
  if not M._cfg.debug then return end
  local parts = { '[calc-debug]' }
  for i = 1, select('#', ...) do
    local value = select(i, ...)
    if type(value) == 'table' then
      parts[#parts + 1] = vim.inspect(value)
    else
      parts[#parts + 1] = tostring(value)
    end
  end
  print(table.concat(parts, ' '))
end

local math_aliases = {
  'abs',
  'acos',
  'acosh',
  'asin',
  'asinh',
  'atan',
  'atan2',
  'atanh',
  'ceil',
  'cos',
  'cosh',
  'deg',
  'erf',
  'erfc',
  'exp',
  'floor',
  'fmod',
  'frexp',
  'gamma',
  'hypot',
  'ldexp',
  'log',
  'log10',
  'max',
  'min',
  'modf',
  'pow',
  'rad',
  'random',
  'sin',
  'sinh',
  'sqrt',
  'tan',
  'tanh',
}

local function make_environment()
  local env = {
    math = math,
    factorial = factorial,
    fact = factorial,
    pi = math.pi,
    tau = 2 * math.pi,
    e = math.exp(1),
    huge = math.huge,
    inf = math.huge,
    nan = 0 / 0,
  }
  for _, name in ipairs(math_aliases) do
    if math[name] then env[name] = math[name] end
  end
  if not env.atan2 and math.atan then
    env.atan2 = function(y, x)
      return math.atan(y, x)
    end
  end
  if not env.pow and math.sqrt then
    env.pow = function(a, b)
      return a ^ b
    end
  end
  if not env.hypot and math.sqrt then
    env.hypot = function(a, b)
      return math.sqrt(a * a + b * b)
    end
  end
  return env
end

local base_env = make_environment()
local eval_env = setmetatable({}, {
  __index = base_env,
  __newindex = function()
    error('calc expressions cannot assign values')
  end,
})

local valid_char_pattern = '[%w_%s%.%+%-%*%/%^%(%)%,]'

local float_hint_patterns = {
  'asin',
  'acos',
  'atan',
  'atan2',
  'cos',
  'cosh',
  'deg',
  'exp',
  'log',
  'log10',
  'pi',
  'rad',
  'sin',
  'sinh',
  'sqrt',
  'tan',
  'tanh',
}

local function preprocess(expr)
  expr = expr:gsub('%*%*', '^')
  return expr
end

local function should_force_decimal(expr_hint)
  if not expr_hint or expr_hint == '' then return false end
  local lowered = expr_hint:lower()
  for _, pat in ipairs(float_hint_patterns) do
    if lowered:find(pat, 1, true) then return true end
  end
  return false
end

local function format_result(result, expr_hint)
  if type(result) == 'number' then
    if result == math.huge or result == -math.huge or result ~= result then
      return tostring(result)
    end
    local formatted = string.format('%.17g', result)
    if formatted:match('^%-?%d+$') then
      if should_force_decimal(expr_hint) then
        return formatted .. '.0'
      end
      return formatted
    end
    if formatted:find('%.') then
      formatted = formatted:gsub('0+$', '')
      formatted = formatted:gsub('%.$', '.0')
    end
    return formatted
  end
  return tostring(result)
end

local function evaluate(expr)
  expr = preprocess(expr)
  local chunk, load_err = load('return ' .. expr, 'calc', 't', eval_env)
  if not chunk then return nil, load_err end
  local ok, result = pcall(chunk)
  if not ok then return nil, result end
  return result, nil
end

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

local function get_visual_selection()
  local mode = vim.fn.mode()
  local visual_mode = vim.fn.visualmode()
  debug_log('visual mode evaluate: current mode', mode, 'visualmode', visual_mode)

  local bufnr = vim.api.nvim_get_current_buf()
  local start_pos = vim.fn.getpos('v')
  local cursor_pos = vim.fn.getpos('.')
  debug_log('visual mode evaluate: raw marks', { start = start_pos, cursor = cursor_pos })

  local start_row = start_pos[2]
  local start_col = start_pos[3]
  local end_row = cursor_pos[2]
  local end_col = cursor_pos[3]

  if start_row == 0 or end_row == 0 then
    debug_log('visual mode evaluate: marks missing, aborting')
    return nil
  end

  if start_row > end_row or (start_row == end_row and start_col > end_col) then
    debug_log('visual mode evaluate: swapping marks', start_row, start_col, end_row, end_col)
    start_row, end_row = end_row, start_row
    start_col, end_col = end_col, start_col
  end

  start_row = start_row - 1
  end_row = end_row - 1
  start_col = math.max(start_col - 1, 0)

  if mode == 'V' then
    start_col = 0
    end_col = vim.api.nvim_buf_get_lines(bufnr, end_row, end_row + 1, true)[1]
    end_col = #(end_col or '')
    debug_log('visual mode evaluate: line-wise selection detected, updated range', start_row, start_col, end_row, end_col)
  else
    end_col = math.max(end_col, start_col + 1)
  end

  debug_log('visual mode evaluate: adjusted start/end (0-index)', start_row, start_col, end_row, end_col)

  local last_line = vim.api.nvim_buf_get_lines(bufnr, end_row, end_row + 1, true)[1] or ''
  end_col = math.min(end_col, #last_line)
  debug_log('visual mode evaluate: clamped end_col', end_col, 'line length', #last_line)

  local lines = vim.api.nvim_buf_get_text(bufnr, start_row, start_col, end_row, end_col, {})
  debug_log('visual mode evaluate: extracted lines', lines)
  if #lines == 0 then
    debug_log('visual mode evaluate: no lines captured')
    return nil
  end

  if #lines > 1 then
    notify_error('calc visual evaluation supports single-line selections only')
    debug_log('visual mode evaluate: multi-line selection rejected')
    return nil
  end

  local raw = lines[1]
  local selection = {
    bufnr = bufnr,
    start_row = start_row,
    start_col = start_col,
    end_row = end_row,
    end_col = end_col,
    raw = raw,
    expr = vim.trim(raw),
    indent = raw:match('^%s*') or '',
  }
  debug_log('visual mode evaluate: final selection', selection)

  if mode == 'v' or mode == 'V' or mode == '\022' or mode == 's' or mode == 'S' or mode == '\019' then
    debug_log('visual mode evaluate: leaving selection mode after capture')
    vim.cmd("normal! \\<Esc>")
  end

  return selection
end


local function apply_visual_result(selection, result_str, mode)
  local bufnr = selection.bufnr
  if mode == 'replace' then
    vim.api.nvim_buf_set_text(bufnr, selection.start_row, selection.start_col, selection.end_row, selection.end_col, { result_str })
    return
  end

  if mode == 'append' then
    local trimmed = selection.raw:gsub('%s+$', '')
    local replacement = trimmed .. ' = ' .. result_str
    vim.api.nvim_buf_set_text(bufnr, selection.start_row, selection.start_col, selection.end_row, selection.end_col, { replacement })
    return
  end

  -- below
  vim.api.nvim_buf_set_text(bufnr, selection.start_row, selection.start_col, selection.end_row, selection.end_col, { selection.raw })
  vim.api.nvim_buf_set_lines(bufnr, selection.end_row + 1, selection.end_row + 1, true, { selection.indent .. selection.expr .. ' = ' .. result_str })
end

local function extract_expression_from_line(line, col)
  if line == '' then return nil end

  local inside
  local previous
  local next_segment

  for start_idx, segment, end_idx in line:gmatch('()(' .. valid_char_pattern .. '+)()') do
    if segment:find('%S') then
      local seg_start = start_idx - 1
      local seg_end = end_idx - 1
      if col >= seg_start and col < seg_end then
        inside = { start_col = seg_start, end_col = seg_end }
        break
      elseif col < seg_start then
        next_segment = { start_col = seg_start, end_col = seg_end }
        break
      else
        previous = { start_col = seg_start, end_col = seg_end }
      end
    end
  end

  local candidate = inside or previous or next_segment
  if not candidate then return nil end

  local start_col = candidate.start_col
  local end_col = candidate.end_col

  local full_segment = line:sub(start_col + 1, end_col)
  local prefix, remainder = full_segment:match('^(%s*%*%s*)(.*)$')
  if prefix and remainder and remainder:find('%S') then
    local before = line:sub(1, start_col)
    if before:find('%S') == nil then
      start_col = start_col + #prefix
    end
  end

  local segment_text = line:sub(start_col + 1, end_col)
  local trimmed = vim.trim(segment_text)
  if trimmed == '' then return nil end

  local leading = segment_text:match('^%s*') or ''

  return {
    start_col = start_col,
    end_col = end_col,
    leading = leading,
    expr = trimmed,
  }
end

local function apply_line_result(bufnr, row, info, result_str, mode)
  local prefix = info.leading or ''
  if mode == 'replace' then
    local new_text = prefix .. result_str
    vim.api.nvim_buf_set_text(bufnr, row, info.start_col, row, info.end_col, { new_text })
    return
  end

  if mode == 'append' then
    local new_text = prefix .. info.expr .. ' = ' .. result_str
    vim.api.nvim_buf_set_text(bufnr, row, info.start_col, row, info.end_col, { new_text })
    return
  end

  local current_line = vim.api.nvim_buf_get_lines(bufnr, row, row + 1, true)[1]
  local indent = current_line:match('^%s*') or ''
  vim.api.nvim_buf_set_lines(bufnr, row + 1, row + 1, true, { indent .. result_str })
end

function M.evaluate_visual(opts)
  local selection = get_visual_selection()
  if not selection then return end
  local expr = selection.expr
  if expr == '' then
    notify_error('calc did not find an expression in the selection')
    return
  end
  local result, err = evaluate(expr)
  if not result then
    notify_error('calc evaluation error: ' .. tostring(err))
    return
  end
  local mode = normalize_output_mode(opts)
  apply_visual_result(selection, format_result(result, expr), mode)
end

function M.evaluate_line(opts)
  local bufnr = vim.api.nvim_get_current_buf()
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  row = row - 1
  local line = vim.api.nvim_buf_get_lines(bufnr, row, row + 1, true)[1]
  if not line then return end
  local info = extract_expression_from_line(line, col)
  if not info then
    notify_error('calc could not locate an expression on this line')
    return
  end
  local result, err = evaluate(info.expr)
  if not result then
    notify_error('calc evaluation error: ' .. tostring(err))
    return
  end
  local mode = normalize_output_mode(opts)
  apply_line_result(bufnr, row, info, format_result(result, info.expr), mode)
end

function M.setup(opts)
  if opts and opts.output then
    if opts.output == 'replace' or opts.output == 'append' or opts.output == 'below' then
      M._cfg.output = opts.output
    end
  end
end

return M
