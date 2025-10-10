return {
  { -- Useful plugin to show you pending keybinds.
    'folke/which-key.nvim',
    event = 'VimEnter', -- Sets the loading event to 'VimEnter'
    opts = {
      -- delay between pressing a key and opening which-key (milliseconds)
      -- this setting is independent of vim.o.timeoutlen
      delay = 0,
      icons = {
        -- set icon mappings to true if you have a Nerd Font
        mappings = vim.g.have_nerd_font,
        -- If you are using a Nerd Font: set icons.keys to an empty table which will use the
        -- default which-key.nvim defined Nerd Font icons, otherwise define a string table
        keys = vim.g.have_nerd_font and {} or {
          Up = '<Up> ',
          Down = '<Down> ',
          Left = '<Left> ',
          Right = '<Right> ',
          C = '<C-…> ',
          M = '<M-…> ',
          D = '<D-…> ',
          S = '<S-…> ',
          CR = '<CR> ',
          Esc = '<Esc> ',
          ScrollWheelDown = '<ScrollWheelDown> ',
          ScrollWheelUp = '<ScrollWheelUp> ',
          NL = '<NL> ',
          BS = '<BS> ',
          Space = '<Space> ',
          Tab = '<Tab> ',
          F1 = '<F1>',
          F2 = '<F2>',
          F3 = '<F3>',
          F4 = '<F4>',
          F5 = '<F5>',
          F6 = '<F6>',
          F7 = '<F7>',
          F8 = '<F8>',
          F9 = '<F9>',
          F10 = '<F10>',
          F11 = '<F11>',
          F12 = '<F12>',
        },
      },

      spec = {
        -- Document existing key chains
        { '<leader>s', group = '[S]ession' },
        { '<leader>f', group = '[F]ind (Telescope)' },
        { '<leader>h', group = 'Git [H]unk', mode = { 'n', 'v' } },
        { '<leader>t', group = '[T]oggle' },
        { '<leader>o', group = '[O]penCode', mode = { 'n', 'v' } },
        { 'gr',        group = 'LSP functions' },
        -- Document existing keymaps
        { 'gra',       desc = 'Code [A]ction' },
        { 'gri',       desc = 'List [I]mplementations' },
        { 'grn',       desc = 'Re[N]ame all references' },
        { 'grr',       desc = 'List [R]eferences' },
        { 'grt',       desc = 'Jump to [T]ype definition' },
        { 'gO' ,       desc = 'List symbols in buffer' },
        { 'ys' ,       desc = '[y]ou [s]urround' },
        { 'yss' ,      desc = '[y]ou [s]urround line' },
        { 'ds' ,       desc = '[d]elete [s]urround' },
        { 'cs' ,       desc = '[c]hange [s]urround' },
        { 'S' ,        desc = '[S]urround', mode = { 'x' } },
      },
    },
    keys = {
      {
        '<leader>?',
        function()
          require('which-key').show({ global = false })
        end,
        desc = 'Buffer Local Keymaps (which-key)',
      },
      {
        '<leader>tw',
        require('utils.whichkey_toggle').toggle,
        desc = '[T]oggle [W]hich-key',
      }
    },
  },
}
