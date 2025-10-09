local lua_loader = require('luasnip.loaders.from_lua')
local vscode_loader = require('luasnip.loaders.from_vscode')
local snipmate_loader = require('luasnip.loaders.from_snipmate')
local ls = require('luasnip')

-- initial load
local lua_paths = { vim.fn.stdpath('config') .. '/lua/snippets' }
lua_loader.lazy_load({ paths = lua_paths })
vscode_loader.lazy_load()
snipmate_loader.lazy_load()

-- Helper: reload all snippet files
local function reload_all()
  -- Clear existing snippets so re-definitions don't stack
  if ls.cleanup then
    ls.cleanup() -- LuaSnip >= 1.0
  end
  if lua_loader.clear_snippets then
    lua_loader.clear_snippets() -- politely clear from this loader if available
  end
  lua_loader.load({ paths = lua_paths })
  snipmate_loader.load()
  vscode_loader.load()
  vim.notify('LuaSnip: snippets reloaded', vim.log.levels.INFO)
end

-- Command to reload on demand
vim.api.nvim_create_user_command('SnippetsReload', reload_all,
  { desc = 'Reload all LuaSnip snippets' })

-- Auto-reload whenever you save a snippet file
vim.api.nvim_create_autocmd('BufWritePost', {
  pattern = {
    vim.fn.stdpath('config') .. '/lua/snippets/*.lua',
    vim.fn.stdpath('config') .. '/lua/snippets/**/*.lua',
    vim.fn.stdpath('config') .. '/snippets/*.snippets',
  },
  callback = function()
    reload_all()
  end,
  desc = 'Reload LuaSnip snippets on save',
})
