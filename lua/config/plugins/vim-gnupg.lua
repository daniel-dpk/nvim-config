return {
  'jamessan/vim-gnupg',
  config = function()
    vim.g.GPGUsePipes = 1
    vim.g.GPGPreferSign = 1
    --vim.g.GPGDebugLevel = 3
  end,
}
