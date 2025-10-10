local set = vim.opt_local

set.shiftwidth = 2

-- Create custom surrounding for Lua's block string `[[...]]`
vim.b.minisurround_config = {
  custom_surroundings = {
    ['s'] = {
      input = { '%[%[().-()%]%]' },
      output = { left = '[[', right = ']]' },
    },
  },
}

local function map(mode, l, r, opts)
  opts = opts or {}
  opts.buffer = 0 -- current buffer
  vim.keymap.set(mode, l, r, opts)
end

map('n', '<leader><leader>x', '<cmd>source %<CR>', { desc = 'Source this file' })
map('n', '<leader>x', ':.lua<CR>', { desc = 'Lua this line' })
map('x', '<leader>x', ':lua<CR>', { desc = 'Lua selected lines' })
