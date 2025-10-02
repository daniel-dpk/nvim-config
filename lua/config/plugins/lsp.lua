return {
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      {
        "folke/lazydev.nvim",
        ft = "lua", -- only load on lua files
        opts = {
          library = {
            -- See the configuration section for more details
            -- Load luvit types when the `vim.uv` word is found
            { path = "${3rd}/luv/library", words = { "vim%.uv" } },
          },
        },
      },
    },
    config = function()
      vim.lsp.enable('pyright')
      vim.lsp.enable('lua_ls')

      vim.diagnostic.config({
        severity_sort = true,
        virtual_text = true,
      })

      vim.keymap.set("n", "<localleader>d", function()
        vim.diagnostic.enable(not vim.diagnostic.is_enabled())
      end, { desc = 'Toggle diagnostics' })

      vim.keymap.set("n", "<localleader>F", function()
        vim.lsp.buf.format({ async = false })
      end, { desc = 'Format whole file' })

      vim.keymap.set("n", "<localleader>f", function()
        local line = vim.api.nvim_win_get_cursor(0)[1]
        vim.lsp.buf.format({
          async = false,
          range = {
            ["start"] = { line, 0 },
            ["end"] = { line, vim.v.maxcol },
          },
        })
      end, { desc = 'Format current line' })

      vim.keymap.set("v", "<localleader>f", function()
        vim.lsp.buf.format({ async = false })
        vim.api.nvim_input("<Esc>")
      end, { desc = 'Format selection' })
    end,
  }
}

-- Notes:
--  * Use 'K' to show popup help for symbol under cursor
--  * grr: references
--  * gri: implementation
--  * grn: rename
--  * gra: code actions (e.g., disable certain diagnostics)
--  * CTRL-S: signature help (insert mode)
