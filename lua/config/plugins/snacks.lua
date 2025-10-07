return {
  {
    'folke/snacks.nvim',
    --enabled = false,
    --version = 'v2.*',
    priority = 1000,
    lazy = false,
    opts = {
      bigfile = { enabled = true },
      input = {
        enabled = true,
        -- This fixes the "cursor stuck to first column" bug. Might be related
        -- to SSH+tmux, not sure though.
        expand = false,
        win = {
          width = 120,
        },
      },
    },
  },
}
