local M = {}

local normalizing = false

local function is_uri(name)
  return name:match('^%a[%w+.-]*://') ~= nil
end

local function base_dir()
  return vim.fs.normalize(vim.fn.getcwd())
end

local function should_skip(buf, name)
  return not vim.api.nvim_buf_is_valid(buf)
    or name == ''
    or is_uri(name)
    or vim.bo[buf].buftype ~= ''
end

function M.cwd_relative_name(buf, base)
  base = base or base_dir()

  if not vim.api.nvim_buf_is_valid(buf) then return nil end

  local name = vim.api.nvim_buf_get_name(buf)
  if should_skip(buf, name) then return nil end

  local absolute = vim.fs.normalize(vim.fn.fnamemodify(name, ':p'))
  local relative = vim.fs.relpath(base, absolute)
  if relative == nil or relative == '' then return nil end

  local current_name = vim.fn.bufname(buf)
  if current_name == relative then return nil end

  return relative
end

function M.normalize(buf, base)
  if normalizing then return false end

  local relative = M.cwd_relative_name(buf, base)
  if relative == nil then return false end

  normalizing = true
  local ok = pcall(vim.api.nvim_buf_set_name, buf, relative)
  normalizing = false

  return ok
end

function M.normalize_all()
  local base = base_dir()

  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    M.normalize(buf, base)
  end
end

function M.setup()
  local group = vim.api.nvim_create_augroup(
    'cwd-relative-buffer-names',
    { clear = true }
  )

  vim.api.nvim_create_autocmd({ 'BufAdd', 'BufFilePost' }, {
    desc = 'Use cwd-relative names for buffers under cwd',
    group = group,
    callback = function(args)
      vim.schedule(function()
        M.normalize(args.buf)
      end)
    end,
  })

  vim.api.nvim_create_autocmd({ 'VimEnter', 'SessionLoadPost' }, {
    desc = 'Normalize cwd-relative buffer names',
    group = group,
    callback = function()
      vim.schedule(M.normalize_all)
    end,
  })

  vim.api.nvim_create_autocmd('User', {
    desc = 'Normalize cwd-relative buffer names after persistence.nvim load',
    group = group,
    pattern = 'PersistenceLoadPost',
    callback = function()
      vim.schedule(M.normalize_all)
    end,
  })

  vim.schedule(M.normalize_all)
end

return M
