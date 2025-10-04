vim.g.mapleader = ' '
vim.g.maplocalleader = ','

vim.g.have_nerd_font = true

require('config.lazy')
require('options')
require('keymaps')

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
  [ ] swap two windows
  [ ] Python LSP does not know how to format code; also, no code actions
  [ ] move between instance methods and classes/functions
  [ ] snippets
  [x] toggle spell
  [ ] vim-test
  [ ] go through old Vim config and port remaining stuff
  [ ] add AI-based completions?
--]]
