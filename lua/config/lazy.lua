-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end

-- Put lazy into the runtimepath
vim.opt.runtimepath:prepend(lazypath)

-- Setup lazy.nvim
require("lazy").setup({
  spec = {
    -- [[ Colorscheme ]]
    --{ "folke/tokyonight.nvim", config = function() vim.cmd.colorscheme("tokyonight") end },
    --{
    --  "shaunsingh/nord.nvim", config = function()
    --    vim.g.nord_contrast = true
    --    vim.g.nord_borders = true
    --    --vim.g.nord_cursorline_transparent = true
    --    vim.cmd.colorscheme("nord")
    --  end
    --},
    --{ "ramojus/mellifluous.nvim", config = function() vim.cmd.colorscheme("mellifluous") end },
    { "HoNamDuong/hybrid.nvim", config = function() vim.cmd.colorscheme("hybrid") end },

    -- import all plugins from config/plugins/*
    { import = "config.plugins" },
  },
  ui = {
    border = "solid",
  },
  change_detection = {
    -- automatically check for config file changes and reload the ui
    enabled = false,
  },
})

-- vim: ts=2 sts=2 sw=2 et
