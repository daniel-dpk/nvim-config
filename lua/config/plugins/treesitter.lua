return {
  {
    'nvim-treesitter/nvim-treesitter',
    branch = 'main',
    lazy = false,
    build = ':TSUpdate',
    config = function()
      local parser_languages = {
        'c', 'cpp', 'python', 'requirements', 'make', 'cmake',
        'bash', 'tmux', 'ssh_config',
        'perl', 'gap', 'fortran', 'julia',
        'latex', 'bibtex',
        'html', 'php', 'rst', 'toml', 'markdown', 'markdown_inline',
        'lua', 'vim', 'vimdoc', 'query',
        'json', 'css', 'dockerfile', 'doxygen', 'editorconfig',
        'git_config', 'git_rebase', 'gitattributes', 'gitignore', 'gitcommit',
      }
      local indent_disabled = {
        latex = true,
        bibtex = true,
        markdown = true,
        markdown_inline = true,
      }
      local max_filesize = 100 * 1024
      local treesitter = require('nvim-treesitter')

      -- Skip Treesitter startup for large files to keep previews and edits
      -- snappy.
      local function is_large_file(bufnr)
        local name = vim.api.nvim_buf_get_name(bufnr)
        if name == '' then
          return false
        end

        local ok, stats = pcall(vim.uv.fs_stat, name)
        return ok and stats and stats.size > max_filesize or false
      end

      local function get_lang(bufnr)
        local ft = vim.bo[bufnr].filetype
        if ft == '' then
          return nil
        end

        return vim.treesitter.language.get_lang(ft) or ft
      end

      local function parser_exists(lang)
        local parser_files = vim.api.nvim_get_runtime_file(
          'parser/' .. lang .. '.so',
          false
        )
        return parser_files[1] ~= nil
      end

      -- Install parsers into Neovim's site directory and register FT aliases.
      treesitter.setup {
        install_dir = vim.fn.stdpath('data') .. '/site',
      }
      vim.treesitter.language.register('json', { 'jsonc' })
      local install = treesitter.install(parser_languages)
      if install and #vim.api.nvim_list_uis() == 0 then
        install:wait(300000)
      end

      -- Enable core Treesitter highlighting on buffers that actually have a
      -- parser.
      vim.api.nvim_create_autocmd('FileType', {
        group = vim.api.nvim_create_augroup('treesitter_start', { clear = true }),
        callback = function(args)
          if is_large_file(args.buf) then
            return
          end

          local lang = get_lang(args.buf)
          if not lang then
            return
          end

          if not parser_exists(lang) then
            return
          end

          local ok = pcall(vim.treesitter.start, args.buf, lang)
          if not ok then
            return
          end

          if not indent_disabled[lang] then
            vim.bo[args.buf].indentexpr =
              "v:lua.require'nvim-treesitter'.indentexpr()"
          end
        end,
      })
    end
  }
}
