-- [[ Basic Keymaps ]]
--  See `:help vim.keymap.set()`

-- Clear highlights on search when pressing <Esc> in normal mode
--  See `:help hlsearch`
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Diagnostic keymaps
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

-- Spell checking
vim.keymap.set('n', '<LocalLeader>s', ':set spell!<CR>', { desc = 'Toggle spell checking' })

-- Exit terminal mode in the builtin terminal with <Esc><Esc> or CTRL+o
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })
vim.keymap.set('t', '<C-o>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-- up/down on wrapped lines
vim.keymap.set({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { desc = "Down", expr = true, silent = true })
vim.keymap.set({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { desc = "Up", expr = true, silent = true })
vim.keymap.set({ "n", "x" }, "_", "v:count == 0 ? 'g^' : '_'", { desc = "Start", expr = true, silent = true })
vim.keymap.set({ "n", "x" }, "$", "v:count == 0 ? 'g$' : '$'", { desc = "End", expr = true, silent = true })

-- Keybinds to make split navigation easier.
--  Use CTRL+<hjkl> to switch between windows
--
--  See `:help wincmd` for a list of all window commands
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

vim.keymap.set('n', '<Leader>w', '<cmd>wincmd =<CR>', { desc = 'Equalize window sizes' })

-- Tab navigation
vim.keymap.set('n', '<C-Left>', ':tabprev<CR>', { desc = 'Go to previous tab' })
vim.keymap.set('n', '<C-Right>', ':tabnext<CR>', { desc = 'Go to next tab' })
vim.keymap.set('n', '<S-Left>', ':tabmove -1<CR>', { desc = 'Move tab left' })
vim.keymap.set('n', '<S-Right>', ':tabmove +1<CR>', { desc = 'Move tab right' })
vim.keymap.set('n', 'tt', ':tab split<CR>', { desc = 'New tab' })
-- " Close current tab leaving us on previous tab (instead of next).
vim.keymap.set('n', 'TT', ':silent! tabmove -1<CR>:tabclose<CR>', { desc = 'Close tab' })

-- Navigate quickfix and location lists
local function nav(cmd)
  local success, err = pcall(cmd)
  if success then
    vim.api.nvim_echo({}, false, {})
  else
    vim.notify(err, vim.log.levels.ERROR)
  end
end
vim.keymap.set("n", "<C-n>", function() nav(vim.cmd.cnext) end, { desc = "Next Quickfix" })
vim.keymap.set("n", "<C-S-n>", function() nav(vim.cmd.cprev) end, { desc = "Previous Quickfix" })
vim.keymap.set("n", "<C-m>", function() nav(vim.cmd.lnext) end, { desc = "Next Location" })
vim.keymap.set("n", "<C-S-m>", function() nav(vim.cmd.lprev) end, { desc = "Previous Location" })

-- [[ Basic Autocommands ]]
--  See `:help lua-guide-autocommands`

-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.hl.on_yank()`
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.hl.on_yank()
  end,
})
