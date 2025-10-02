vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

vim.g.have_nerd_font = false

require('config.lazy')
require('options')
require('keymaps')

--[[
TODO:
  [x] turn off auto-detect of config changes
  [x] better colorscheme
  [ ] fuzzy finder
  [ ] session management
  [ ] pin plugin versions
  [ ] NERDTree or similar
  [ ] set hidden
  [ ] surround
  [ ] convenient way to close quickfix and location lists
  [ ] show error message without :lopen
  [ ] Tpope's fugitive or similar
  [ ] work with encrypted files
  [ ] go through old Vim config an port remaining stuff
--]]
