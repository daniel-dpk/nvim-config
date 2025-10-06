local function map(mode, l, r, opts)
  opts = opts or {}
  opts.buffer = 0 -- current buffer
  vim.keymap.set(mode, l, r, opts)
end

map('t', '<C-h>', '<C-\\><C-n><C-w><C-h>', { desc = 'Move focus to the left window' })
map('t', '<C-l>', '<C-\\><C-n><C-w><C-l>', { desc = 'Move focus to the right window' })
