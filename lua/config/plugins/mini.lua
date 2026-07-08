return {
  {
    'nvim-mini/mini.nvim',
    version = '*',
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
      pcall(vim.keymap.del, 'n', 'sn')
      pcall(vim.keymap.del, 'x', 'ys')
      vim.keymap.set('x', 'S', [[:<C-u>lua MiniSurround.add('visual')<CR>]], { silent = true })
      vim.keymap.set('n', 'yss', 'ys_', { remap = true })

      -- Statusline replacement
      local statusline = require('mini.statusline')

      function statusline.section_filename()
        if vim.bo.buftype == 'terminal' then return '%t' end

        return '%f%m%r'
      end

      statusline.setup {
        content = {
          inactive = function()
            return '%#MiniStatuslineInactive#%f%='
          end,
        },
        use_icons = vim.g.have_nerd_font,
      }

      require('mini.align').setup()
    end,
  },
}
