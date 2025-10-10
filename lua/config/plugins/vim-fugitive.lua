return {
  { -- A Git wrapper so awesome, it should be illegal
    'tpope/vim-fugitive',
    config = function()
      vim.keymap.set('n', '<c-g><c-g>', ':vert botright Git | horizontal wincmd =<CR>', { desc = 'Git status' })
      vim.keymap.set('n', '<c-g><c-v>', ':vert botright Git | horizontal wincmd =<CR>', { desc = 'Git status' })
      vim.keymap.set('n', '<c-g><c-l>', ':vert botright Git -p log --graph --decorate --date=short --oneline --all --pretty=format:"%h %ad%d %s" | horizontal wincmd =<CR>', { desc = 'Git log graph' })

      if vim.fn.executable('gitk') then
        vim.keymap.set('n', '<c-g><c-k>', ':silent !gitk --all&<CR>', { desc = 'Open gitk' })
      end
    end,
  }
}
