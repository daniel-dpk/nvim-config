return {
  'nvim-telescope/telescope.nvim',
  tag = '0.1.8',
  dependencies = {
    'nvim-lua/plenary.nvim',
    { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
    { 'nvim-telescope/telescope-live-grep-args.nvim', version = '^1.0.0' },
  },
  config = function()
    local lga_actions = require('telescope-live-grep-args.actions')
    require('telescope').setup {
      extensions = {
        fzf = {},
        live_grep_args = {
          auto_quoting = true,
          mappings = { -- extend mappings
            i = {
              ['<C-k>'] = lga_actions.quote_prompt(),
              ['<C-i>'] = lga_actions.quote_prompt({ postfix = ' --iglob ' }),
            },
          },
        },
      },
    }
    require('telescope').load_extension('fzf')
    require('telescope').load_extension('live_grep_args')

    local builtin = require('telescope.builtin')
    vim.keymap.set('n', '<C-p>', builtin.find_files, { desc = 'Telescope find files' })
    vim.keymap.set('n', '<leader>fd', builtin.find_files, { desc = 'Telescope find files' })
    vim.keymap.set('n', '<leader>fw', builtin.grep_string, { desc = 'Telescope grep word' })
    --vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Telescope live grep' })
    vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Telescope buffers' })
    vim.keymap.set('n', '<leader>fq', builtin.quickfix, { desc = 'Telescope quickfix' })
    vim.keymap.set('n', '<leader>fl', builtin.loclist, { desc = 'Telescope location list' })
    vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = 'Telescope help tags' })

    vim.keymap.set('n', '<leader>fB', builtin.builtin, { desc = 'Telescope built-in commands' })
    vim.keymap.set('n', '<leader>fr', builtin.lsp_references, { desc = 'Telescope references (LSP)' })

    local lga = require('telescope').extensions.live_grep_args
    vim.keymap.set('n', '<leader>fg', function()
      lga.live_grep_args()
    end, { desc = 'Telescope live grep' })

    -- Edit Neovim config
    vim.keymap.set('n', '<leader>fn', function()
      builtin.find_files { cwd = vim.fn.stdpath('config') }
    end, { desc = 'Telescope [N]eovim files' })
  end
}
