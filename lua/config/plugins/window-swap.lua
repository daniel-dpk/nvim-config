return {
  {
    'wesQ3/vim-windowswap',
    init = function()
      vim.g.windowswap_map_keys = false
    end,
    config = function()
      vim.keymap.set('n', '<leader>W', '<cmd>call WindowSwap#EasyWindowSwap()<CR>',
        { desc = 'Swap two [W]indows' })
    end,
  },
}
