local M = {}

function M.yank(with_context)
  local name = vim.api.nvim_buf_get_name(0)
  if name == '' or vim.bo.buftype ~= '' or name:match('^%w+://') then
    vim.notify('Open a live file to copy its location', vim.log.levels.WARN)
    return
  end

  local first = vim.fn.line('.')
  local last = first
  local mode = vim.fn.mode()
  if mode == 'v' or mode == 'V' or mode == '\22' then
    first = math.min(first, vim.fn.line('v'))
    last = math.max(last, vim.fn.line('v'))
  end

  local path = vim.fn.fnamemodify(name, ':.')
  local location = path .. ':' .. first
  if last ~= first then
    location = location .. '-' .. last
  end

  local text = location
  if with_context then
    local lines = vim.api.nvim_buf_get_lines(0, first - 1, last, true)
    text = text .. '\n' .. table.concat(lines, '\n')
  end
  vim.fn.setreg('+', text)
end

return M
