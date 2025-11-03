return {
  {
    'supermaven-inc/supermaven-nvim',
    event = 'InsertEnter',
    cmd = { 'SupermavenUseFree', 'SupermavenUsePro' },
    opts = {
      keymaps = {
        accept_suggestion = "<Tab>",
        clear_suggestion = "<C-c>",
        accept_word = "<C-,>",
      },
      disable_inline_completions = true,
      ignore_filetypes = {
        'bigfile',
        'snacks_input',
        'snacks_notif',
      },
      condition = function()
        return vim.fn.expand('%:e') == 'gpg'
      end,
    },
    keys = {
      {
        '<C-S-a>',
        function()
          require('supermaven-nvim.api').toggle()
          local status = require('supermaven-nvim.api').is_running() and 'active' or 'inactive'
          vim.api.nvim_echo({ { 'Supermaven is now ' .. status, 'Statement' } }, false, {})
        end,
        desc = 'Toggle supermaven'
      },
    },
    config = function(_, opts)
      -- remove default keymaps interfering with supermaven
      vim.keymap.del({'i', 's'}, '<Tab>')
      vim.keymap.del({'i', 's'}, '<S-Tab>')
      require('supermaven-nvim').setup(opts)
    end,
  },
}
