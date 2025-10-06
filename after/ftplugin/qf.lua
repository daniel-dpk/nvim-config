local set = vim.opt_local

set.wrap = false

vim.keymap.set("n", "q", ":lcl<CR>", { desc = 'Close window', buffer = 0 })
vim.keymap.set("n", "o", function()
  vim.cmd('silent! normal! <CR>')
  vim.cmd('wincmd p')
end, { desc = 'View entry', buffer = 0 })

local function open_list_in_telescope()
  local wininfo = vim.fn.getwininfo(vim.api.nvim_get_current_win())[1]
  if wininfo and wininfo.loclist == 1 then
    require('telescope.builtin').loclist()
  else
    require('telescope.builtin').quickfix()
  end
end

-- In the qf/loclist window: <leader>t opens the current list in Telescope
vim.keymap.set('n', '<localleader>t', open_list_in_telescope,
  { buffer = 0, desc = '[T]elescope list' })
