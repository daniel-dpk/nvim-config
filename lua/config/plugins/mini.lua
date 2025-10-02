return {
  {
    'echasnovski/mini.nvim',
    enabled = true,
    config = function()
      -- Add/delete/replace surroundings (brackets, quotes, etc.)
      --
      -- - saiw) - [S]urround [A]dd [I]nner [W]ord [)]Paren
      -- - sd'   - [S]urround [D]elete [']quotes
      -- - sr)'  - [S]urround [R]eplace [)] [']
      require('mini.surround').setup()

      -- Statusline replacement
      local statusline = require('mini.statusline')
      statusline.setup { use_icons = vim.g.have_nerd_font }
    end,
  },
}
