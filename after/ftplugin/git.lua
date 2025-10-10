local function map(mode, l, r, opts)
  opts = opts or {}
  opts.buffer = 0 -- current buffer
  vim.keymap.set(mode, l, r, opts)
end

map('n', 'q', ':q<CR>', { desc = 'Quit git window' })
map('n', '<tab>', function()
    vim.cmd.normal { '1p', bang = false }
  end,
  { desc = 'Show commit details', noremap = false }
)
map('n', 'K', function()
    vim.cmd.normal { 'k1p', bang = false }
  end,
  { desc = 'Show newer commit details' }
)
map('n', 'J', function()
    vim.cmd.normal { 'j1p', bang = false }
  end,
  { desc = 'Show older commit details' }
)
