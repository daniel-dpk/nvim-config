local M = { enabled = true }

local function get_cfg()
  local ok_cfg, cfg = pcall(require, 'which-key.config')
  if not ok_cfg then
    vim.notify("which-key: config not found (is the plugin loaded?)", vim.log.levels.WARN)
    return nil
  end
  return cfg
end

function M.disable()
  if not M.enabled then return end
  local cfg = get_cfg()
  if not cfg then return end
  local opts = cfg.options or {}
  opts.delay = 10^9
  M.enabled = false
  vim.notify("which-key: disabled")
end

function M.enable()
  if M.enabled then return end
  local cfg = get_cfg()
  if not cfg then return end
  local opts = cfg.options or {}
  opts.delay = 0
  M.enabled = true
  vim.notify("which-key: enabled")
end

function M.toggle()
  if M.enabled then M.disable() else M.enable() end
end

return M
