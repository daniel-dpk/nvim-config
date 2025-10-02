-- Neo-tree is a Neovim plugin to browse the file system
-- https://github.com/nvim-neo-tree/neo-tree.nvim

return {
  'nvim-neo-tree/neo-tree.nvim',
  version = '*',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-tree/nvim-web-devicons', -- not strictly required, but recommended
    'MunifTanjim/nui.nvim',
  },
  lazy = false,
  keys = {
    { '\\', ':Neotree reveal<CR>', desc = 'NeoTree reveal', silent = true },
    { '<F12>', ':Neotree reveal<CR>', desc = 'NeoTree reveal', silent = true },
    --{ '<leader>s', ':Neotree float git_status<CR>', desc = 'NeoTree git status', silent = true },
  },
  opts = {
    filesystem = {
      window = {
        mappings = {
          ['\\'] = 'close_window',
          ['<F12>'] = 'close_window',
          ['o'] = 'toggle_node',
          ['O'] = 'expand_all_subnodes',
          -- disable o* mappings
          ['oc'] = 'noop',
          ['od'] = 'noop',
          ['og'] = 'noop',
          ['om'] = 'noop',
          ['on'] = 'noop',
          ['os'] = 'noop',
          ['ot'] = 'noop',
        },
      },
    },
  },
}
