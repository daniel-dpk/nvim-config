return {
  'jamessan/vim-gnupg',
  init = function()
    vim.g.GPGUsePipes = 1
    vim.g.GPGPreferSign = 1
    --vim.g.GPGDebugLevel = 3
  end,
}
