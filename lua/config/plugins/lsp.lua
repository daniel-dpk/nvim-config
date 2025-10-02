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
    end,
  }
}

-- Notes:
--  * Use 'K' to show popup help for symbol under cursor
--  * grr: references
--  * gri: implementation
--  * grn: rename
--  * CTRL-S: signature help
