vim.g.mapleader = ' '
vim.g.maplocalleader = ','

vim.g.have_nerd_font = true

require('config.lazy')
require('config.options')
require('config.keymaps')

-- Load untracked extra configuration in, e.g.,
--  ./lua/custom/init.lua
pcall(require, 'custom')

--[[
TODO:
  [x] turn off auto-detect of config changes
  [x] better colorscheme
  [x] fuzzy finder
  [x] restore edit location
  [x] session management
  [x] persistent undo/redo
  [x] NERDTree or similar
  [x] surround
  [x] show error message without :lopen
  [x] Tpope's fugitive or similar
  [x] Copy/paste via SSH
  [x] Undo-tree
  [x] work with encrypted files
  [x] Python LSP does not know how to format code; also, no code actions
  [x] modify hybrid colorscheme to clearly show statusline and window borders
  [x] press 'o' in loclist/qfixlist to "view" place (stay in list)
  [x] toggle which-key
  [x] toggle suggestions
  [x] map h/j/k/l for wrapped lines
  [ ] swap two windows
  [x] move between instance methods and classes/functions
  [ ] snippets
      [x] decide on engine
      [ ] port old snippets
  [x] toggle spell
  [ ] vim-test
  [ ] go through old Vim config and port remaining stuff
--]]
