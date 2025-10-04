local Targets = require("code_nav.targets")

local M = {
  _cfg = {
    filetypes = { "python", "lua", "c", "cpp" }, -- which FTs should auto-attach
    wrap = true,                                 -- wrap-around like Vim's 'W'
    keymaps = {
      same = { prev = "<A-k>", next = "<A-j>" },
      top  = { prev = "<C-Up>", next = "<C-Down>" },
    },
  }
}

local function get_targets_for(ft)
  return Targets[ft] or Targets["*"] or {}
end

local function node_is_one_of(node, wanted)
  local ty = node:type()
  for _, w in ipairs(wanted) do
    if ty == w then return true end
  end
  return false
end

local function get_root(bufnr, lang)
  local ok, parser = pcall(vim.treesitter.get_parser, bufnr, lang)
  if not ok or not parser then return nil end
  local tree = parser:parse()[1]
  return tree and tree:root() or nil
end

local function get_node_at_cursor()
  local ok, ts_utils = pcall(require, "nvim-treesitter.ts_utils")
  if ok and ts_utils.get_node_at_cursor then
    return ts_utils.get_node_at_cursor()
  end
  return nil
end

local function collect_items_in_scope(scope, wanted)
  local items = {}
  for child in scope:iter_children() do
    if child:named() and node_is_one_of(child, wanted) then
      table.insert(items, child)
    end
  end
  table.sort(items, function(a, b)
    local ar, ac = a:range()
    local br, bc = b:range()
    return (ar == br and ac < bc) or (ar < br)
  end)
  return items
end

local function find_current_index(items, row)
  for i, node in ipairs(items) do
    local sr, sc, er, _ = node:range()
    if row >= sr and row <= er then return i, sr, sc end
  end
  return nil
end

local function resolve_scope(node, root, wanted)
  local scope = node
  while scope and scope ~= root do
    local items = collect_items_in_scope(scope, wanted)
    if #items > 0 then return scope, items end
    scope = scope:parent()
  end

  local root_items = collect_items_in_scope(root, wanted)
  return root, root_items
end

local function move_to_node_start(node)
  local name = node:field("name")
  local target = (name and name[1]) and name[1] or node
  local row, col = target:range()
  vim.api.nvim_win_set_cursor(0, { row + 1, col })
  vim.cmd("normal! zv")
end

-- direction: "next" | "prev"; level: "same" | "top"
function M.jump(direction, level)
  local bufnr = 0
  local ft = vim.bo[bufnr].filetype
  local lang = vim.treesitter.language.get_lang(ft) or ft
  local root = get_root(bufnr, lang)
  if not root then return end

  local wanted = get_targets_for(ft)
  if #wanted == 0 then return end

  local scope
  local items
  if level == "top" then
    scope = root
    items = collect_items_in_scope(scope, wanted)
  else
    local node = get_node_at_cursor()
    scope, items = resolve_scope(node, root, wanted)
  end

  if not items then items = collect_items_in_scope(scope, wanted) end
  if #items == 0 then return end

  local crow, ccol = unpack(vim.api.nvim_win_get_cursor(0))
  crow = crow - 1

  local current_idx, current_start, current_start_col = find_current_index(items, crow)
  local cmp_col = ccol
  if current_idx and crow == current_start then cmp_col = current_start_col end
  local idx
  if direction == "next" then
    if current_idx and current_idx < #items then
      idx = current_idx + 1
    else
      for i, n in ipairs(items) do
        local r, c = n:range()
        if crow < r or (crow == r and cmp_col < c) then idx = i; break end
      end
      if not idx and M._cfg.wrap then idx = 1 end
    end
  else
    if current_idx then
      if crow > current_start then
        idx = current_idx
      elseif current_idx > 1 then
        idx = current_idx - 1
      end
    end
    if not idx then
      for i = #items, 1, -1 do
        local r, c = items[i]:range()
        if crow > r or (crow == r and cmp_col > c) then idx = i; break end
      end
      if not idx and M._cfg.wrap then idx = #items end
    end
  end

  if idx then move_to_node_start(items[idx]) end
end

function M.attach(bufnr)
  local nopts = { buffer = bufnr, silent = true }
  local same, top = M._cfg.keymaps.same, M._cfg.keymaps.top

  vim.keymap.set("n", same.prev, function() M.jump("prev", "same") end, nopts)
  vim.keymap.set("n", same.next, function() M.jump("next", "same") end, nopts)
  vim.keymap.set("n", top.prev,  function() M.jump("prev", "top")  end, nopts)
  vim.keymap.set("n", top.next,  function() M.jump("next", "top")  end, nopts)

  -- Visual mode: restore selection after jump
  local vopts = { buffer = bufnr, silent = true }
  vim.keymap.set("x", same.prev, function() M.jump("prev", "same"); vim.cmd("normal! gv") end, vopts)
  vim.keymap.set("x", same.next, function() M.jump("next", "same"); vim.cmd("normal! gv") end, vopts)
  vim.keymap.set("x", top.prev,  function() M.jump("prev", "top");  vim.cmd("normal! gv") end, vopts)
  vim.keymap.set("x", top.next,  function() M.jump("next", "top");  vim.cmd("normal! gv") end, vopts)
end

function M.setup(opts)
  M._cfg = vim.tbl_deep_extend("force", M._cfg, opts or {})

  -- Auto-attach on the filetypes you specify
  if M._cfg.filetypes and #M._cfg.filetypes > 0 then
    vim.api.nvim_create_autocmd("FileType", {
      pattern = M._cfg.filetypes,
      callback = function(args)
        -- Only attach if parser exists, to avoid noise
        local ft = vim.bo[args.buf].filetype
        local lang = vim.treesitter.language.get_lang(ft) or ft
        local ok = pcall(vim.treesitter.get_parser, args.buf, lang)
        if ok then M.attach(args.buf) end
      end,
    })
  end
end

-- adding/updating languages at runtime
function M.register_language(ft, node_types)
  Targets[ft] = node_types
end

return M
