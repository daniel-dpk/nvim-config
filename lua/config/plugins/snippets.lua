return {
  {
    'L3MON4D3/LuaSnip',
    version = 'v2.*',
    build = 'make install_jsregexp',
    dependencies = {
      {
        'rafamadriz/friendly-snippets',
        config = function()
          require('luasnip.loaders.from_vscode').lazy_load()
        end,
      },
    },
    config = function()
      local ls = require('luasnip')

      ls.config.setup({
        store_selection_keys = '<C-j>',
        update_events = 'TextChanged,TextChangedI',
      })

      vim.keymap.set('i', '<C-j>', function()
        ls.expand({})
        require('blink.cmp')['hide']()
      end, { silent = true, desc = 'Snippet: expand' })

      vim.keymap.set({ 'i', 's' }, '<C-l>', function()
        ls.jump(1)
        require('blink.cmp')['hide']()
      end, { silent = true, desc = 'Snippet: jump forward' })

      vim.keymap.set({ 'i', 's' }, '<C-h>', function()
        ls.jump(-1)
        require('blink.cmp')['hide']()
      end, { silent = true, desc = 'Snippet: jump back' })

      vim.keymap.set({ 'i', 's' }, '<C-e>', function()
        if ls.choice_active() then
          ls.change_choice(1)
        end
      end, { silent = true, desc = 'Snippet: change active choice' })

      vim.keymap.set({ 'i', 's' }, '<C-u>', require('luasnip.extras.select_choice'),
        { silent = true, desc = 'Snippet: change active choice' })

      -- Reloading commands, also loads snippets now
      require('utils.snippets_reload')
    end,
  },
}
