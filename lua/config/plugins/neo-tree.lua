-- Neo-tree is a Neovim plugin to browse the file system
-- https://github.com/nvim-neo-tree/neo-tree.nvim

return {
  'nvim-neo-tree/neo-tree.nvim',
  -- Prevent duplicate resize timers in long-running sessions.
  commit = '4d55ed3482da32d1a68a9ed36dca5f4d69ec0ffb',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-tree/nvim-web-devicons', -- not strictly required, but recommended
    'MunifTanjim/nui.nvim',
  },
  lazy = false,
  keys = {
    { '\\', ':Neotree reveal<CR>', desc = 'NeoTree reveal', silent = true },
    { '<F12>', ':Neotree show toggle<CR>', desc = 'NeoTree toggle', silent = true },
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
          ['Y'] = {
            function(state)
              local node = state.tree:get_node()
              local path = vim.fn.fnamemodify(node.path, ':~')
              vim.fn.setreg('+', path)
              vim.notify('Copied: ' .. path)
            end,
            desc = 'Copy path',
          },
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
