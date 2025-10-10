return {
  {
    'Vimjas/vim-python-pep8-indent',
    -- Currently disabled. If you enable it, turn off
    --    indent = { enable = true },
    -- in lua/config/plugins/treesitter.lua.
    enabled = false,
    event = 'BufEnter *.py',
    ft = {'python', 'pyrex'},
  }
}
