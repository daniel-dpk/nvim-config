local function map(mode, l, r, opts)
  opts = opts or {}
  opts.buffer = 0 -- current buffer
  vim.keymap.set(mode, l, r, opts)
end

map("n", "q", ":q<CR>", { desc = 'Quit git window' })
map("n", "<tab>", function()
    vim.cmd.normal { "=", bang = false }
  end,
  { desc = 'Open/close diff etc.', noremap = false }
)
map("n", "<space><space>", function()
    vim.cmd.normal { "1p", bang = false }
  end,
  { desc = 'View item' }
)
