local M = {}

-- State at startup:
M.state = true

-- To be used as callback for completion.menu.auto_show
---@diagnostic disable-next-line: unused-local
function M.auto_show(ctx, items)
  return M.state
end

function M.toggle()
  M.state = not M.state
  local state_str = M.state and 'enabled' or 'disabled'
  vim.notify('completions auto-show: ' .. state_str)
end

return M
