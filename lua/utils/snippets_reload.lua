local loader = require("luasnip.loaders.from_lua")
local ls = require("luasnip")

-- initial load
local paths = { vim.fn.stdpath("config") .. "/lua/snippets" }
loader.lazy_load({ paths = paths })

-- Helper: reload all snippet files
local function reload_all()
  -- Clear existing snippets so re-definitions don't stack
  if ls.cleanup then
    ls.cleanup() -- LuaSnip >= 1.0
  end
  if loader.clear_snippets then
    loader.clear_snippets() -- politely clear from this loader if available
  end
  loader.load({ paths = paths })
  vim.notify("LuaSnip: snippets reloaded", vim.log.levels.INFO)
end

-- Command to reload on demand
vim.api.nvim_create_user_command("SnippetsReload", reload_all,
  { desc = "Reload all LuaSnip snippets" })

-- Auto-reload whenever you save a snippet file
vim.api.nvim_create_autocmd("BufWritePost", {
  pattern = {
    vim.fn.stdpath("config") .. "/lua/snippets/*.lua",
    vim.fn.stdpath("config") .. "/lua/snippets/**/*.lua",
  },
  callback = function()
    reload_all()
  end,
  desc = "Reload LuaSnip snippets on save",
})
