return {
  {
    'echasnovski/mini.nvim',
    enabled = true,
    config = function()
      -- Add/delete/replace surroundings (brackets, quotes, etc.)
      --
      -- - ysiw) - [Y]ou [S]urround [I]nner [W]ord [)]Paren!
      -- - ds'   - [D]elete [S]urround [']quotes
      -- - cs)'  - [C]hange [S]urrounding [)] to [']
      require('mini.surround').setup({
        mappings = {
          add = 'ys',     -- Add surrounding in Normal and Visual modes
          delete = 'ds',  -- Delete surrounding
          find = '',      -- Find surrounding (to the right)
          find_left = '', -- Find surrounding (to the left)
          highlight = '', -- Highlight surrounding
          replace = 'cs', -- Replace/change surrounding
        },
      })
      vim.keymap.del('x', 'ys')
      vim.keymap.set('x', 'S', [[:<C-u>lua MiniSurround.add('visual')<CR>]], { silent = true })
      vim.keymap.set('n', 'yss', 'ys_', { remap = true })

      -- Statusline replacement
      local statusline = require('mini.statusline')
      statusline.setup { use_icons = vim.g.have_nerd_font }

      require('mini.align').setup()
    end,
  },
}
