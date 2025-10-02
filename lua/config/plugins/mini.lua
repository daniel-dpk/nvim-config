return {
  {
    'echasnovski/mini.nvim',
    enabled = true,
    config = function()
      local statusline = require 'mini.statusline'
      statusline.setup { use_icons = true }
    end
  }
}

-- vim: ts=2 sts=2 sw=2 et
