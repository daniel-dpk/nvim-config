return {
  {
    'NickvanDyke/opencode.nvim',
    dependencies = {
      -- Recommended for `ask()`, and required for `toggle()` - otherwise optional
      { 'folke/snacks.nvim' }, -- needs: opts = { input = { enabled = true } }
    },
    config = function()
      local oc = require('opencode')

      vim.g.opencode_opts = {
        terminal = {
          win = {
            position = "left",
          },
        },
      }

      -- Required for `opts.auto_reload`
      vim.opt.autoread = true

      vim.keymap.set({ 'n', 'x' }, '<leader>oa', function() oc.ask('@this: ', { submit = true }) end, { desc = '[A]sk about this...' })
      vim.keymap.set({ 'n', 'x' }, '<leader>o+', function() oc.prompt('@this') end, { desc = 'Add buffer/selection to prompt' })
      vim.keymap.set({ 'n', 'x' }, '<leader>oe', function() oc.prompt('Explain @this and its context', { submit = true }) end, { desc = '[E]xplain this' })
      vim.keymap.set({ 'n', 'x' }, '<leader>os', function() oc.select() end, { desc = 'Select prompt...' })

      vim.keymap.set({ 'n', 'x' }, '<leader>od', function()
        oc.prompt(
          'Add or update the docstring for the class, method, or function at @this. Keep the docstring concise and to the point. Prefer one-line descriptions even when there are parameters and/or return types for private functions. An exception is non-obvious side-effects, which should always be documented.'
        )
      end, { desc = 'Add/update [D]ocstring' })

      vim.keymap.set('n', '<leader>ot', function() oc.toggle(); vim.cmd('horizontal wincmd =') end, { desc = 'Toggle embedded' })
      vim.keymap.set('n', '<leader>on', function() oc.command('session_new') end, { desc = '[N]ew session' })
      vim.keymap.set('n', '<leader>oi', function() oc.command('session_interrupt') end, { desc = '[I]nterrupt session' })
      vim.keymap.set('n', '<S-C-u>',    function() oc.command('messages_half_page_up') end, { desc = 'Messages half page [U]p' })
      vim.keymap.set('n', '<S-C-d>',    function() oc.command('messages_half_page_down') end, { desc = 'Messages half page [D]own' })
    end,
  },
}
