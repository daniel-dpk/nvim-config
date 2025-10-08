local M = {}

local debug_enabled = false

local function debug_print(...)
  if not debug_enabled then return end
  local parts = {}
  for i = 1, select('#', ...) do
    parts[i] = tostring(select(i, ...))
  end
  print('[window_resize]', table.concat(parts, ' '))
end

function M.set_debug(enabled)
  debug_enabled = not not enabled
end

local function get_option(name, opts)
  local ok, value = pcall(vim.api.nvim_get_option_value, name, opts or {})
  if ok then return value end
  return nil
end

local function schedule_width_report(label, columns)
  if not debug_enabled then return end
  vim.schedule(function()
    local parts = {}
    for idx, column in ipairs(columns) do
      local rep = column.wins[1]
      local width = 'na'
      if rep and vim.api.nvim_win_is_valid(rep) then
        width = tostring(vim.api.nvim_win_get_width(rep))
      end
      parts[#parts + 1] = string.format('%d=%s', idx, width)
    end
    debug_print(label, 'widths', table.concat(parts, ' '))
  end)
end

local function is_resizable(win)
  if not vim.api.nvim_win_is_valid(win) then return false end

  local cfg = vim.api.nvim_win_get_config(win)
  if cfg.external or (cfg.relative and cfg.relative ~= '') then
    return false
  end

  local fixed = get_option('winfixwidth', {
    scope = 'local',
    win = win,
  })
  if fixed then
    debug_print('skip', win, 'because winfixwidth')
    return false
  end

  local buf = vim.api.nvim_win_get_buf(win)
  local ft = get_option('filetype', {
    scope = 'local',
    buf = buf,
  })
  if ft == 'NvimTree' or ft == 'neo-tree' or ft == 'Outline' then
    debug_print('skip', win, 'sidebar filetype', ft)
    return false
  end

  local buftype = get_option('buftype', {
    scope = 'local',
    buf = buf,
  })
  if buftype == 'quickfix' or buftype == 'help' then
    debug_print('skip', win, 'buftype', buftype)
    return false
  end

  return true
end

local function get_min_width(win)
  local min_width = 1

  local global_min = get_option('winminwidth', {
    scope = 'global',
  })
  if type(global_min) == 'number' then
    min_width = math.max(min_width, global_min)
  end

  local preferred = get_option('winwidth', {
    scope = 'local',
    win = win,
  })
  if type(preferred) == 'number' then
    min_width = math.max(min_width, preferred)
  end

  return min_width
end

local function flatten_leaves(node, acc)
  local kind = node[1]
  if kind == 'leaf' then
    table.insert(acc, node[2])
    return
  end

  for _, child in ipairs(node[2]) do
    flatten_leaves(child, acc)
  end
end

local function locate_row(node, target)
  local kind = node[1]
  if kind == 'leaf' then
    if node[2] == target then
      return true, nil
    end
    return false, nil
  end

  for _, child in ipairs(node[2]) do
    local found, row = locate_row(child, target)
    if found then
      if kind == 'row' then
        return true, node
      else
        return true, row
      end
    end
  end

  return false, nil
end

local function build_columns(row_node, current_win)
  local columns = {}
  local current_idx

  for idx, child in ipairs(row_node[2]) do
    local wins = {}
    flatten_leaves(child, wins)

    local contains_current = false
    local resizable = true
    local min_width = 1

    for _, win in ipairs(wins) do
      if win == current_win then
        contains_current = true
      end

      if resizable and not is_resizable(win) then
        resizable = false
      end

      min_width = math.max(min_width, get_min_width(win))
    end

    local width = 0
    if wins[1] then
      width = vim.api.nvim_win_get_width(wins[1])
    end

    if contains_current then
      current_idx = idx
    end

    columns[idx] = {
      wins = wins,
      width = width,
      min_width = min_width,
      resizable = resizable,
    }
  end

  return columns, current_idx
end

local function refresh_columns(columns)
  for _, column in ipairs(columns) do
    local rep = column.wins[1]
    if rep and vim.api.nvim_win_is_valid(rep) then
      column.width = vim.api.nvim_win_get_width(rep)
    end
  end
end

local function set_winfixwidth(win, value)
  local ok, err = pcall(vim.api.nvim_set_option_value, 'winfixwidth', value, {
    scope = 'local',
    win = win,
  })
  if not ok then
    debug_print('failed to set winfixwidth for', win, err)
  end
end

local function capture_fixwidth(columns)
  local states = {}
  for _, column in ipairs(columns) do
    for _, win in ipairs(column.wins) do
      local state = get_option('winfixwidth', {
        scope = 'local',
        win = win,
      })
      states[win] = state and true or false
    end
  end
  return states
end

local function enforce_fixwidth(columns, states, allowed_map)
  for idx, column in ipairs(columns) do
    local allow = allowed_map[idx]
    for _, win in ipairs(column.wins) do
      local original = states[win]
      local desired = original
      if not allow then
        desired = true
      end
      if desired ~= original then
        set_winfixwidth(win, desired)
      end
    end
  end
end

local function restore_fixwidth(columns, states)
  for _, column in ipairs(columns) do
    for _, win in ipairs(column.wins) do
      local original = states[win]
      set_winfixwidth(win, original)
    end
  end
end

local function apply_targets(columns, current_idx, targets, current_target)
  local states = capture_fixwidth(columns)

  local function protect(allowed)
    enforce_fixwidth(columns, states, allowed)
  end

  local function cleanup()
    restore_fixwidth(columns, states)
  end

  local ok, err = pcall(function()
    local indices = {}
    for idx in pairs(targets) do
      if idx ~= current_idx then
        table.insert(indices, idx)
      end
    end
    table.sort(indices)

    for _, idx in ipairs(indices) do
      local column = columns[idx]
      local target = targets[idx]
      local rep = column and column.wins[1] or nil
      if rep and column.resizable and target and target < column.width then
        debug_print('apply target column', idx, '->', target)
        protect({
          [current_idx] = true,
          [idx] = true,
        })
        vim.api.nvim_win_set_width(rep, target)
        cleanup()
        refresh_columns(columns)
      end
    end

    local current_column = columns[current_idx]
    local current_rep = current_column and current_column.wins[1] or nil
    if current_rep and current_target and current_column.width < current_target then
      debug_print('set current target', current_target)
      protect({
        [current_idx] = true,
      })
      vim.api.nvim_win_set_width(current_rep, current_target)
      cleanup()
      refresh_columns(columns)
    end
  end)

  cleanup()

  if not ok then error(err) end
end

function M.expand_current(opts)
  opts = opts or {}

  if opts.debug ~= nil then
    M.set_debug(opts.debug)
  end

  local current_win = vim.api.nvim_get_current_win()
  local layout = vim.fn.winlayout()
  local found, row_node = locate_row(layout, current_win)
  if not found or not row_node then
    vim.notify('window_resize: could not find row layout for current window', vim.log.levels.WARN)
    return
  end

  local columns, current_idx = build_columns(row_node, current_win)
  local current_col = current_idx and columns[current_idx] or nil
  if not current_col or not current_col.wins[1] then
    vim.notify('window_resize: unable to determine current column', vim.log.levels.WARN)
    return
  end

  if not current_col.resizable then
    vim.notify('window_resize: current window is not resizable', vim.log.levels.INFO)
    return
  end

  local fraction = opts.fraction or (1 / 3)
  local increase = math.max(math.floor(current_col.width * fraction + 0.5), 1)

  debug_print('current column width', current_col.width, 'increase target', increase)

  local total_room = 0
  local rooms = {}

  for idx, column in ipairs(columns) do
    if idx ~= current_idx and column.resizable and column.wins[1] then
      local room = math.max(column.width - column.min_width, 0)
      rooms[idx] = room
      total_room = total_room + room
      debug_print('column', idx, 'width', column.width, 'min', column.min_width, 'room', room)
    else
      rooms[idx] = 0
      if idx ~= current_idx then
        debug_print('skip column', idx, 'resizable', column.resizable)
      end
    end
  end

  if total_room <= 0 then
    vim.notify('No resizable windows available', vim.log.levels.INFO)
    return
  end

  local target_delta = math.min(increase, total_room)
  if target_delta <= 0 then return end

  debug_print('total room', total_room, 'target delta', target_delta)

  schedule_width_report('pre', columns)

  local plan = {}
  local assigned = 0

  for idx, room in pairs(rooms) do
    if room > 0 then
      local share = math.floor(target_delta * room / total_room)
      share = math.min(share, room)
      if share > 0 then
        plan[idx] = share
        assigned = assigned + share
      end
    end
  end

  local remaining = target_delta - assigned
  if remaining > 0 then
    for idx, room in pairs(rooms) do
      if remaining <= 0 then break end
      local taken = plan[idx] or 0
      local available = room - taken
      if available > 0 then
        local extra = math.min(available, remaining)
        plan[idx] = taken + extra
        remaining = remaining - extra
      end
    end
  end

  local targets = {}
  local total_taken = 0

  for idx, column in ipairs(columns) do
    if idx ~= current_idx and column.resizable and column.wins[1] then
      local take = plan[idx] or 0
      if take > 0 then
        local desired = math.max(column.width - take, column.min_width)
        local taken = column.width - desired
        if taken > 0 then
          targets[idx] = desired
          total_taken = total_taken + taken
          debug_print('target column', idx, 'width', column.width, '->', desired)
        end
      end
    end
  end

  if total_taken <= 0 then
    debug_print('no width reallocated')
    schedule_width_report('post', columns)
    return
  end

  local current_target = current_col.width + total_taken
  debug_print('current target width', current_target)

  apply_targets(columns, current_idx, targets, current_target)
  refresh_columns(columns)

  debug_print('final current width', columns[current_idx].width)
  schedule_width_report('post', columns)
end

return M
