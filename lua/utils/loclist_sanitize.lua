local M = {}

-- Replace newlines/tabs with spaces and collapse whitespace
local function clean_text(s)
  if type(s) ~= "string" then return s end
  s = s:gsub("\r\n?", " ") -- CRLF/CR → space
  s = s:gsub("\n", " ")    -- LF → space
  s = s:gsub("\t", " ")    -- tabs → space
  s = s:gsub("%s+", " ")   -- collapse whitespace runs
  return s
end

-- Sanitize current window's location list (winid 0)
function M.sanitize_loclist(winid)
  winid = winid or 0
  -- Fetch items+metadata so we can rewrite without losing title/context
  local info = vim.fn.getloclist(winid, { items = 1, title = 1, context = 1 })
  local items = info.items or {}
  if #items == 0 then return end

  local changed = false
  for _, it in ipairs(items) do
    local before = it.text
    local after = clean_text(before)
    if after ~= before then
      it.text = after
      changed = true
    end
  end

  if changed then
    -- 'r' = replace whole list, but keep idx if possible
    vim.fn.setloclist(winid, {}, 'r', {
      items = items,
      title = info.title,
      context = info.context,
    })
  end
end

-- One-shot: populate → sanitize → (optionally) open
function M.populate_and_sanitize(opts)
  opts = vim.tbl_extend("keep", opts or {}, { open = false })
  vim.diagnostic.setloclist(opts)
  M.sanitize_loclist(0)
end

return M
