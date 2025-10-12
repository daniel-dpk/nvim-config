vim.g.mapleader = ' '
vim.g.maplocalleader = ','

vim.g.have_nerd_font = true

require('config.lazy')
require('config.options')
require('config.keymaps')

-- Load untracked extra configuration in, e.g.,
--  ./lua/custom/init.lua
pcall(require, 'custom')
