return {
  {
    'saghen/blink.cmp',
    -- optional: provides snippets for the snippet source
    dependencies = {
      {
        'L3MON4D3/LuaSnip',
        version = "v2.*",
        build = "make install_jsregexp",
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
          require('utils.snippets_reload')

          vim.keymap.set('i', '<C-j>', ls.expand,
            { silent = true, desc = "Snippet: expand" })

          vim.keymap.set({ 'i', 's' }, '<C-l>', function() ls.jump(1) end,
            { silent = true, desc = "Snippet: jump forward" })

          vim.keymap.set({ 'i', 's' }, '<C-h>', function() ls.jump(-1) end,
            { silent = true, desc = "Snippet: jump back" })

          vim.keymap.set({ 'i', 's' }, '<C-e>', function()
            if ls.choice_active() then
              ls.change_choice(1)
            end
          end, { silent = true, desc = "Snippet: change active choice" })
        end,
      },
    },

    -- use a release tag to download pre-built binaries
    version = '1.*',

    opts = {
      -- 'default' (recommended) for mappings similar to built-in completions (C-y to accept)
      -- 'super-tab' for mappings similar to vscode (tab to accept)
      -- 'enter' for enter to accept
      -- 'none' for no mappings
      --
      -- All presets have the following mappings:
      -- C-space: Open menu or open docs if already open
      -- C-n/C-p or Up/Down: Select next/previous item
      -- C-e: Hide menu
      -- C-k: Toggle signature help (if signature.enabled = true)
      --
      -- See :h blink-cmp-config-keymap for defining your own keymap
      keymap = { preset = 'default' },

      appearance = {
        -- 'mono' (default) for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
        -- Adjusts spacing to ensure icons are aligned
        nerd_font_variant = 'mono'
      },

      -- (Default) Only show the documentation popup when manually triggered
      completion = {
        menu = {
          auto_show = require('utils.blink_toggle').auto_show,
          draw = {
            columns = {
              { "kind_icon" },
              { "label", "label_description", gap = 1 },
              { "kind" },
            },
          },
        },
        --documentation = { auto_show = true, auto_show_delay_ms = 1000 },
        documentation = { auto_show = false },
      },

      -- Default list of enabled providers defined so that you can extend it
      -- elsewhere in your config, without redefining it, due to `opts_extend`
      sources = {
        default = { 'lsp', 'path', 'snippets', 'buffer' },
      },

      -- (Default) Rust fuzzy matcher for typo resistance and significantly better performance
      -- You may use a lua implementation instead by using `implementation = "lua"` or fallback to the lua implementation,
      -- when the Rust fuzzy matcher is not available, by using `implementation = "prefer_rust"`
      --
      -- See the fuzzy documentation for more information
      fuzzy = { implementation = "prefer_rust_with_warning" },

      -- Experimental signature help support
      signature = { enabled = true },
    },

    opts_extend = { "sources.default" },

    config = function(_, opts)
      require('blink.cmp').setup(opts)
      vim.keymap.set('n', '<leader>tc', require('utils.blink_toggle').toggle,
        { desc = '[T]oggle [C]ompletion auto-show' })
    end,

    --event = 'VimEnter',
  },
}
