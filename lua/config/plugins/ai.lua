return {
  {
    'NickvanDyke/opencode.nvim',
    dependencies = {
      -- Recommended for `ask()`, and required for `toggle()` — otherwise optional
      { 'folke/snacks.nvim', opts = { input = { enabled = true } } },
    },
    config = function()
      vim.g.opencode_opts = {
        terminal = {
          win = {
            position = "left",
          },
        },
      }

      -- Required for `opts.auto_reload`
      vim.opt.autoread = true

      vim.keymap.set('n', '<leader>ot', function()
        require('opencode').toggle()
        vim.cmd('horizontal wincmd =')
      end, { desc = 'Toggle embedded' })
      vim.keymap.set({ 'n', 'x' }, '<leader>oa', function() require('opencode').ask('@this: ') end,
        { desc = '[A]sk about this...' })
      vim.keymap.set('n', '<leader>o+', function() require('opencode').prompt('@buffer', { append = true }) end,
        { desc = 'Add buffer to prompt' })
      vim.keymap.set('v', '<leader>o+', function() require('opencode').prompt('@selection', { append = true }) end,
        { desc = 'Add selection to prompt' })
      vim.keymap.set({ 'n', 'x' }, '<leader>oe',
        function() require('opencode').prompt('Explain @this and its context') end,
        { desc = '[E]xplain this code' })
      vim.keymap.set({ 'n', 'x' }, '<leader>od',
        function()
          require('opencode').prompt(
            'Add or update the docstring for the class, method, or function at @this. Keep the docstring concise and to the point. Prefer one-line descriptions even when there are parameters and/or return types for private functions. An exception is non-obvious side-effects, which should always be documented.'
          )
        end,
        { desc = 'Add/update [D]ocstring' })
      vim.keymap.set('n', '<leader>on', function() require('opencode').command('session_new') end,
        { desc = '[N]ew session' })
      vim.keymap.set('n', '<S-C-u>', function() require('opencode').command('messages_half_page_up') end,
        { desc = 'Messages half page [U]p' })
      vim.keymap.set('n', '<S-C-d>', function() require('opencode').command('messages_half_page_down') end,
        { desc = 'Messages half page [D]own' })
      vim.keymap.set({ 'n', 'v' }, '<leader>os', function() require('opencode').select() end,
        { desc = 'Select prompt...' })
    end,
  },
}
