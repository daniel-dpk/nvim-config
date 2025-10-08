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
      -- [[ General config ]]
      local diagnostic_config = {
        severity_sort = true,
        virtual_text = true,
        virtual_lines = false,
      }
      vim.diagnostic.config(diagnostic_config)

      -- [[ Key maps ]]
      vim.keymap.set("n", "<localleader>d", function()
        vim.diagnostic.enable(not vim.diagnostic.is_enabled())
      end, { desc = 'Toggle [d]iagnostics' })

      vim.keymap.set("n", "<localleader>D", function()
        if not diagnostic_config.virtual_lines then
          diagnostic_config.virtual_lines = { current_line = true }
          vim.notify("virtual-lines: enabled")
        else
          diagnostic_config.virtual_lines = false
          vim.notify("virtual-lines: disabled")
        end
        vim.diagnostic.config(diagnostic_config)
      end, { desc = 'Toggle virtual-lines [D]iagnostics' })

      vim.keymap.set("n", "<localleader>F", function()
        vim.lsp.buf.format({ async = false })
      end, { desc = '[F]ormat whole file' })

      vim.keymap.set("n", "<localleader>f", function()
        local line = vim.api.nvim_win_get_cursor(0)[1]
        vim.lsp.buf.format({
          async = false,
          range = {
            ["start"] = { line, 0 },
            ["end"] = { line, vim.v.maxcol },
          },
        })
      end, { desc = '[F]ormat current line' })

      vim.keymap.set("v", "<localleader>f", function()
        vim.lsp.buf.format({ async = false })
        vim.api.nvim_input("<Esc>")
      end, { desc = '[F]ormat selection' })

      -- [[ Configure servers ]]
      -- Common on_attach callback
      ---@diagnostic disable-next-line: unused-local
      local function on_attach(client, bufnr)
        local map = function(mode, lhs, rhs, desc)
          vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
        end
        map("n", "grd", vim.lsp.buf.definition, 'Jump to [D]efinition')
        map("n", "grs", function()
          print(vim.inspect(vim.diagnostic.get(0, { lnum = vim.fn.line('.') - 1 })))
        end, '[S]how diagnostic under cursor')
      end

      -- Individual configs
      local orig_on_attach = vim.lsp.config.pyright.on_attach
      vim.lsp.config("pyright", {
        on_attach = function(client, bufnr)
          if orig_on_attach then orig_on_attach(client, bufnr) end
          on_attach(client, bufnr)
        end,
        settings = {
          pyright = { disableOrganizeImports = true },
        },
      })

      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup('lsp_attach_disable_ruff_hover', { clear = true }),
        callback = function(args)
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          if client == nil then
            return
          end
          if client.name == 'ruff' then
            -- Disable hover in favor of Pyright
            client.server_capabilities.hoverProvider = false
          end
        end,
        desc = 'LSP: Disable hover capability from Ruff',
      })

      -- [[ Enable servers ]]
      vim.lsp.enable({ 'pyright', 'ruff' })
      vim.lsp.enable('lua_ls')
    end,
  }
}

-- Notes:
--  * Use 'K' to show popup help for symbol under cursor
--  * grr: references
--  * gri: implementation
--  * grn: rename
--  * gra: code actions (e.g., disable certain diagnostics)
--  * grt: go to type definition
--  * grd: go to definition
--  * CTRL-S: signature help (insert mode)
