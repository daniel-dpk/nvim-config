return {
  'nvim-telescope/telescope.nvim',
  dependencies = {
    'nvim-lua/plenary.nvim',
    { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
    { 'nvim-telescope/telescope-live-grep-args.nvim', version = '^1.0.0' },
  },
  config = function()
    local actions = require('telescope.actions')
    local lga_actions = require('telescope-live-grep-args.actions')

    local function feedkeys(keys, mode)
      vim.api.nvim_feedkeys(
        vim.api.nvim_replace_termcodes(keys, true, false, true),
        mode, false
      )
    end

    require('telescope').setup {
      defaults = {
        mappings = {
          i = {
            ['<C-Up>'] = actions.cycle_history_prev,
            ['<C-Down>'] = actions.cycle_history_next,
            ['<C-j>'] = actions.move_selection_next,
            ['<C-k>'] = actions.move_selection_previous,
            ['<C-a>'] = function() feedkeys('<Home>', 'i') end,
            ['<C-e>'] = function() feedkeys('<End>', 'i') end,
            ['<esc>'] = actions.close,
            ['<C-c>'] = false,
          },
          n = {
            ['q'] = actions.close,
            ['<C-c>'] = actions.close,
          },
        },
        cache_picker = {
          num_pickers = 10,
          ignore_empty_prompt = true,
        },
      },
      extensions = {
        fzf = {},
        live_grep_args = {
          auto_quoting = true,
          mappings = { -- extend mappings
            i = {
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
    vim.keymap.set('n', '<leader>fd', function()
      builtin.find_files({ hidden = true })
    end, { desc = 'Telescope find files (+hidden)' })
    vim.keymap.set('n', '<leader>fa', function()
      builtin.find_files({ hidden = true, no_ignore = true })
    end, { desc = 'Telescope find files (+all)' })
    vim.keymap.set('n', '<leader>fw', builtin.grep_string, { desc = 'Telescope grep word' })
    --vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Telescope live grep' })
    vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Telescope buffers' })
    vim.keymap.set('n', '<leader>fq', builtin.quickfix, { desc = 'Telescope quickfix' })
    vim.keymap.set('n', '<leader>fl', builtin.loclist, { desc = 'Telescope location list' })
    vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = 'Telescope help tags' })

    vim.keymap.set('n', '<leader>fB', builtin.builtin, { desc = 'Telescope built-in commands' })
    vim.keymap.set('n', '<leader>fr', builtin.lsp_references, { desc = 'Telescope references (LSP)' })
    vim.keymap.set('n', '<leader>fR', builtin.resume, { desc = 'Telescope [R]esume last' })
    vim.keymap.set('n', '<leader>fp', builtin.resume, { desc = 'Telescope last [p]ickers' })

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
