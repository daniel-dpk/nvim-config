return {
  {
    name = "code-nav",
    dir = vim.fn.stdpath("config") .. "/local/code-nav",
    lazy = false,
    config = function()
      require("code_nav").setup()
    end,
  },
}
